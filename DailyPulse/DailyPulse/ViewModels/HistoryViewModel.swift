import Foundation
import Combine

public enum HistoryFilter: String, CaseIterable, Identifiable {
    case week = "7 Days"
    case month = "30 Days"
    case all = "All Time"

    public var id: String { rawValue }

    public var dayLimit: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .all: return 180
        }
    }
}

@MainActor
public final class HistoryViewModel: ObservableObject {
    @Published public var records: [DailyRecord] = []
    @Published public var selectedFilter: HistoryFilter = .week
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    @Published public var averageSleepHours: Double = 0.0
    @Published public var averageWaterML: Int = 0
    @Published public var prayerCompletionRate: Int = 0

    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol

    public init(
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }

    public func loadHistory() async {
        guard let userId = authService.currentUser?.id else {
            self.records = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched = try await firestoreService.fetchHistory(
                userId: userId,
                limitDays: selectedFilter.dayLimit
            )
            self.records = fetched
            computeStatistics()
        } catch {
            self.errorMessage = "Failed to load history: \(error.localizedDescription)"
        }
    }

    public func setFilter(_ filter: HistoryFilter) {
        self.selectedFilter = filter
        Task {
            await loadHistory()
        }
    }

    private func computeStatistics() {
        guard !records.isEmpty else {
            averageSleepHours = 0.0
            averageWaterML = 0
            prayerCompletionRate = 0
            return
        }

        let totalSleep = records.reduce(0.0) { $0 + $1.sleepHours }
        self.averageSleepHours = (totalSleep / Double(records.count) * 10).rounded() / 10

        let totalWater = records.reduce(0) { $0 + $1.waterIntakeML }
        self.averageWaterML = totalWater / records.count

        let totalPossiblePrayers = records.count * 5
        let totalCompletedPrayers = records.reduce(0) { $0 + $1.completedPrayerCount }
        if totalPossiblePrayers > 0 {
            self.prayerCompletionRate = Int((Double(totalCompletedPrayers) / Double(totalPossiblePrayers)) * 100)
        } else {
            self.prayerCompletionRate = 0
        }
    }
}
