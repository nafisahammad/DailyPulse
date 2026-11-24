import Foundation
import Combine

@MainActor
public final class HydrationViewModel: ObservableObject {
    @Published public var customAmountML: Int = 250
    @Published public var goalPresets: [Int] = [1500, 2000, 2500, 3000, 3500]
    @Published public var showingGoalSheet: Bool = false

    private let recordStore: DailyRecordStore
    private var lastAdditionML: Int = 0

    public init(recordStore: DailyRecordStore = DailyRecordStore.shared) {
        self.recordStore = recordStore
    }

    public var currentIntakeML: Int {
        recordStore.currentRecord.waterIntakeML
    }

    public var goalML: Int {
        recordStore.currentRecord.waterGoalML
    }

    public var progressFraction: Double {
        guard goalML > 0 else { return 0.0 }
        return min(Double(currentIntakeML) / Double(goalML), 1.0)
    }

    public var percentageString: String {
        guard goalML > 0 else { return "0%" }
        let percent = Int((Double(currentIntakeML) / Double(goalML)) * 100)
        return "\(percent)%"
    }

    public var remainingML: Int {
        max(goalML - currentIntakeML, 0)
    }

    public var motivationalMessage: String {
        let fraction = progressFraction
        if fraction >= 1.0 {
            return "🎉 Fantastic! Daily hydration goal completed!"
        } else if fraction >= 0.75 {
            return "💧 Almost there! Just a couple of glasses left."
        } else if fraction >= 0.50 {
            return "🌊 Halfway through! Keep hydrating."
        } else if fraction >= 0.25 {
            return "🌱 Good start! Remember to drink water regularly."
        } else {
            return "☀️ Start your day with a fresh glass of water!"
        }
    }

    public func addWater(_ amountML: Int) {
        lastAdditionML = amountML
        recordStore.addWater(amountML: amountML)
    }

    public func undoLastAddition() {
        if lastAdditionML > 0 {
            recordStore.addWater(amountML: -lastAdditionML)
            lastAdditionML = 0
        }
    }

    public func resetWater() {
        recordStore.resetWater()
        lastAdditionML = 0
    }

    public func updateGoal(_ newGoalML: Int) {
        recordStore.setWaterGoal(goalML: newGoalML)
    }
}
