import Foundation
import Combine

public struct LocationPreset: Identifiable, Hashable {
    public var id: String { "\(city), \(country)" }
    public let city: String
    public let country: String

    public static let defaults: [LocationPreset] = [
        LocationPreset(city: "London", country: "United Kingdom"),
        LocationPreset(city: "New York", country: "United States"),
        LocationPreset(city: "Makkah", country: "Saudi Arabia"),
        LocationPreset(city: "Madinah", country: "Saudi Arabia"),
        LocationPreset(city: "Cairo", country: "Egypt"),
        LocationPreset(city: "Istanbul", country: "Turkey"),
        LocationPreset(city: "Dubai", country: "United Arab Emirates"),
        LocationPreset(city: "Dhaka", country: "Bangladesh"),
        LocationPreset(city: "Karachi", country: "Pakistan"),
        LocationPreset(city: "Jakarta", country: "Indonesia"),
        LocationPreset(city: "Toronto", country: "Canada"),
        LocationPreset(city: "Sydney", country: "Australia")
    ]
}

@MainActor
public final class NamazViewModel: ObservableObject {
    @Published public var selectedCity: String = "London"
    @Published public var selectedCountry: String = "United Kingdom"

    @Published public var timings: Timings?
    @Published public var hijriDateString: String = ""
    @Published public var gregorianDateString: String = ""

    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var nextPrayerName: String = "Loading..."
    @Published public var nextPrayerTime: String = "--:--"
    @Published public var timeRemainingString: String = ""

    private let apiService: NamazAPIServiceProtocol
    private let recordStore: DailyRecordStore
    private var timerCancellable: AnyCancellable?

    public init(
        apiService: NamazAPIServiceProtocol = NamazAPIService.shared,
        recordStore: DailyRecordStore = DailyRecordStore.shared
    ) {
        self.apiService = apiService
        self.recordStore = recordStore

        // Restore saved city
        if let savedCity = UserDefaults.standard.string(forKey: "DailyPulse_SavedCity"),
           let savedCountry = UserDefaults.standard.string(forKey: "DailyPulse_SavedCountry") {
            self.selectedCity = savedCity
            self.selectedCountry = savedCountry
        }

        startTimer()
    }

    public func setLocation(city: String, country: String) {
        self.selectedCity = city
        self.selectedCountry = country
        UserDefaults.standard.set(city, forKey: "DailyPulse_SavedCity")
        UserDefaults.standard.set(country, forKey: "DailyPulse_SavedCountry")
        Task {
            await fetchTimings()
        }
    }

    public func fetchTimings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await apiService.fetchPrayerTimes(
                city: selectedCity,
                country: selectedCountry,
                date: recordStore.selectedDate
            )
            self.timings = result.timings
            if let hijri = result.dateContainer.hijri {
                self.hijriDateString = "\(hijri.day) \(hijri.month.en) \(hijri.year) AH"
            }
            if let gregorian = result.dateContainer.gregorian {
                self.gregorianDateString = "\(gregorian.weekday.en), \(gregorian.day) \(gregorian.month.en) \(gregorian.year)"
            } else {
                self.gregorianDateString = result.dateContainer.readable
            }

            calculateNextPrayer()
        } catch {
            print("⚠️ [NamazViewModel] API Error, using fallback timings: \(error)")
            self.errorMessage = "Using offline prayer timetable (\(error.localizedDescription))"
            self.timings = NamazAPIService.offlineFallbackTimings
            self.gregorianDateString = recordStore.selectedDate.friendlyDateString
            calculateNextPrayer()
        }
    }

    public func isPrayerCompleted(_ prayerType: PrayerType) -> Bool {
        recordStore.currentRecord.prayersCompleted[prayerType.rawValue] ?? false
    }

    public func togglePrayer(_ prayerType: PrayerType) {
        recordStore.togglePrayerCompletion(prayerType: prayerType)
    }

    public var completedCount: Int {
        PrayerType.allCases.filter { isPrayerCompleted($0) }.count
    }

    public var progressFraction: Double {
        Double(completedCount) / Double(PrayerType.allCases.count)
    }

    public func timeString(for prayerType: PrayerType) -> String {
        guard let timings = timings else { return "--:--" }
        switch prayerType {
        case .fajr: return cleanTimeString(timings.fajr)
        case .dhuhr: return cleanTimeString(timings.dhuhr)
        case .asr: return cleanTimeString(timings.asr)
        case .maghrib: return cleanTimeString(timings.maghrib)
        case .isha: return cleanTimeString(timings.isha)
        }
    }

    private func cleanTimeString(_ time: String) -> String {
        // Aladhan sometimes returns "05:15 (BST)", strip the timezone suffix
        return time.components(separatedBy: " ").first ?? time
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.calculateNextPrayer()
            }
    }

    public func calculateNextPrayer() {
        guard let timings = timings else { return }

        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: now)

        let prayerList: [(PrayerType, String)] = [
            (.fajr, cleanTimeString(timings.fajr)),
            (.dhuhr, cleanTimeString(timings.dhuhr)),
            (.asr, cleanTimeString(timings.asr)),
            (.maghrib, cleanTimeString(timings.maghrib)),
            (.isha, cleanTimeString(timings.isha))
        ]

        var upcoming: (type: PrayerType, date: Date)? = nil

        for item in prayerList {
            let timeParts = item.1.components(separatedBy: ":")
            if timeParts.count >= 2,
               let hour = Int(timeParts[0]),
               let min = Int(timeParts[1]) {
                var comp = currentComponents
                comp.hour = hour
                comp.minute = min
                comp.second = 0
                if let prayerDate = calendar.date(from: comp), prayerDate > now {
                    upcoming = (item.0, prayerDate)
                    break
                }
            }
        }

        // If all prayers today have passed, the next prayer is Fajr tomorrow
        if let next = upcoming {
            self.nextPrayerName = next.type.name
            self.nextPrayerTime = timeString(for: next.type)

            let diffMinutes = Int(next.date.timeIntervalSince(now) / 60)
            let hours = diffMinutes / 60
            let mins = diffMinutes % 60
            if hours > 0 {
                self.timeRemainingString = "in \(hours)h \(mins)m"
            } else {
                self.timeRemainingString = "in \(mins) mins"
            }
        } else {
            self.nextPrayerName = "Fajr (Tomorrow)"
            self.nextPrayerTime = cleanTimeString(timings.fajr)
            self.timeRemainingString = "Tomorrow morning"
        }
    }
}
