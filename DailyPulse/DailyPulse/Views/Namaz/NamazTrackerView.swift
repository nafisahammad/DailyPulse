import SwiftUI

public struct NamazTrackerView: View {
    @EnvironmentObject var namazVM: NamazViewModel
    @EnvironmentObject var recordStore: DailyRecordStore
    @State private var showingCitySheet = false
    @State private var customCity = ""
    @State private var customCountry = ""

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                // Location & Status Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(namazVM.selectedCity), \(namazVM.selectedCountry)")
                                .font(.headline)
                            if !namazVM.hijriDateString.isEmpty {
                                Text(namazVM.hijriDateString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Button("Change City") {
                            showingCitySheet = true
                        }
                        .font(.subheadline)
                    }

                    HStack {
                        Text("Next Prayer:")
                            .foregroundColor(.secondary)
                        Text("\(namazVM.nextPrayerName) (\(namazVM.nextPrayerTime))")
                            .bold()
                        Spacer()
                        Text(namazVM.timeRemainingString)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(
                            "Completed: \(namazVM.completedCount) of 5",
                            value: Double(namazVM.completedCount),
                            total: 5.0
                        )
                    }
                }

                // Daily Prayers Section
                Section("Today's Prayers (Check off to save)") {
                    ForEach(PrayerType.allCases) { prayer in
                        let isDone = namazVM.isPrayerCompleted(prayer)

                        Toggle(isOn: Binding(
                            get: { isDone },
                            set: { _ in
                                namazVM.togglePrayer(prayer)
                            }
                        )) {
                            HStack {
                                Image(systemName: prayer.iconName)
                                    .foregroundColor(isDone ? .green : .secondary)
                                    .frame(width: 24)

                                VStack(alignment: .leading) {
                                    Text(prayer.name)
                                        .font(.body)
                                        .strikethrough(isDone, color: .secondary)

                                    Text(prayer.arabicName)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(namazVM.timeString(for: prayer))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Firestore Sync Confirmation
                Section {
                    HStack {
                        Image(systemName: "checkmark.icloud")
                            .foregroundColor(.green)
                        Text("Prayer checkoffs automatically sync to Firestore")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Namaz Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await namazVM.fetchTimings()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await namazVM.fetchTimings()
            }
            .sheet(isPresented: $showingCitySheet) {
                citySelectionSheet
            }
            .task {
                if namazVM.timings == nil {
                    await namazVM.fetchTimings()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var citySelectionSheet: some View {
        NavigationView {
            List {
                Section("Popular Cities") {
                    ForEach(LocationPreset.defaults) { preset in
                        Button {
                            namazVM.setLocation(city: preset.city, country: preset.country)
                            showingCitySheet = false
                        } label: {
                            HStack {
                                Text("\(preset.city), \(preset.country)")
                                    .foregroundColor(.primary)
                                Spacer()
                                if namazVM.selectedCity == preset.city {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section("Custom City") {
                    TextField("City name (e.g. Mecca)", text: $customCity)
                    TextField("Country (e.g. Saudi Arabia)", text: $customCountry)

                    Button("Set Custom City") {
                        if !customCity.isEmpty && !customCountry.isEmpty {
                            namazVM.setLocation(city: customCity, country: customCountry)
                            showingCitySheet = false
                        }
                    }
                    .disabled(customCity.isEmpty || customCountry.isEmpty)
                }
            }
            .navigationTitle("Select City")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        showingCitySheet = false
                    }
                }
            }
        }
    }
}
