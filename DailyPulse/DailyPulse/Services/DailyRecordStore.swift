import Foundation
import Combine

@MainActor
public final class DailyRecordStore: ObservableObject {
    public static let shared = DailyRecordStore()

    @Published public var currentRecord: DailyRecord
    @Published public var selectedDate: Date = Date()
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncError: String?

    private var cancellables = Set<AnyCancellable>()
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol

    public init(
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
        self.currentRecord = DailyRecord()

        // Listen for user changes to reload records
        authService.userPublisher
            .sink { [weak self] user in
                Task { @MainActor [weak self] in
                    await self?.loadRecordForCurrentDate()
                }
            }
            .store(in: &cancellables)
    }

    public func setDate(_ newDate: Date) {
        selectedDate = newDate
        Task {
            await loadRecordForCurrentDate()
        }
    }

    public func loadRecordForCurrentDate() async {
        guard let userId = authService.currentUser?.id else {
            return
        }

        let dateKey = selectedDate.toDayKey
        isSyncing = true
        defer { isSyncing = false }

        do {
            if let existing = try await firestoreService.fetchDailyRecord(userId: userId, dateKey: dateKey) {
                self.currentRecord = existing
            } else {
                // Initialize fresh record for this day
                self.currentRecord = DailyRecord(
                    id: dateKey,
                    userId: userId,
                    date: selectedDate
                )
            }
        } catch {
            self.lastSyncError = error.localizedDescription
            print("⚠️ [DailyRecordStore] Error loading record: \(error)")
        }
    }

    // MARK: - Update Namaz
    public func togglePrayerCompletion(prayerType: PrayerType) {
        guard let userId = authService.currentUser?.id else { return }
        var updated = currentRecord
        updated.userId = userId

        let currentVal = updated.prayersCompleted[prayerType.rawValue] ?? false
        updated.prayersCompleted[prayerType.rawValue] = !currentVal
        updated.updatedAt = Date()

        self.currentRecord = updated
        persistCurrentRecord()
    }

    // MARK: - Update Hydration
    public func addWater(amountML: Int) {
        guard let userId = authService.currentUser?.id else { return }
        var updated = currentRecord
        updated.userId = userId
        updated.waterIntakeML = max(0, updated.waterIntakeML + amountML)
        updated.updatedAt = Date()

        self.currentRecord = updated
        persistCurrentRecord()
    }

    public func setWaterGoal(goalML: Int) {
        guard let userId = authService.currentUser?.id else { return }
        var updated = currentRecord
        updated.userId = userId
        updated.waterGoalML = goalML
        updated.updatedAt = Date()

        self.currentRecord = updated
        persistCurrentRecord()
    }

    public func resetWater() {
        guard let userId = authService.currentUser?.id else { return }
        var updated = currentRecord
        updated.userId = userId
        updated.waterIntakeML = 0
        updated.updatedAt = Date()

        self.currentRecord = updated
        persistCurrentRecord()
    }

    // MARK: - Update Sleep
    public func updateSleep(hours: Double, quality: SleepQuality, bedtime: Date? = nil, wakeTime: Date? = nil) {
        guard let userId = authService.currentUser?.id else { return }
        var updated = currentRecord
        updated.userId = userId
        updated.sleepHours = hours
        updated.sleepQuality = quality.rawValue
        if let bedtime = bedtime { updated.bedtime = bedtime }
        if let wakeTime = wakeTime { updated.wakeTime = wakeTime }
        updated.updatedAt = Date()

        self.currentRecord = updated
        persistCurrentRecord()
    }

    // MARK: - Persistence
    private func persistCurrentRecord() {
        let recordToSave = currentRecord
        Task {
            do {
                try await firestoreService.saveDailyRecord(recordToSave)
            } catch {
                await MainActor.run {
                    self.lastSyncError = error.localizedDescription
                }
                print("❌ [DailyRecordStore] Sync error: \(error)")
            }
        }
    }
}
