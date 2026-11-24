import Foundation

public struct HydrationLog: Identifiable, Codable, Equatable {
    public let id: UUID
    public let amountML: Int
    public let timestamp: Date

    public init(id: UUID = UUID(), amountML: Int, timestamp: Date = Date()) {
        self.id = id
        self.amountML = amountML
        self.timestamp = timestamp
    }
}

public struct HydrationRecord: Codable, Equatable {
    public var currentIntakeML: Int
    public var targetGoalML: Int
    public var logs: [HydrationLog]

    public var progressFraction: Double {
        guard targetGoalML > 0 else { return 0.0 }
        return min(Double(currentIntakeML) / Double(targetGoalML), 1.5)
    }

    public var percentageString: String {
        let percent = Int(progressFraction * 100)
        return "\(percent)%"
    }

    public var remainingML: Int {
        max(targetGoalML - currentIntakeML, 0)
    }

    public init(currentIntakeML: Int = 0, targetGoalML: Int = 2500, logs: [HydrationLog] = []) {
        self.currentIntakeML = currentIntakeML
        self.targetGoalML = targetGoalML
        self.logs = logs
    }
}
