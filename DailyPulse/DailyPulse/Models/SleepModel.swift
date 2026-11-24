import Foundation
import SwiftUI

public enum SleepQuality: String, CaseIterable, Codable, Identifiable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .poor: return "🥱"
        case .fair: return "😐"
        case .good: return "😊"
        case .excellent: return "✨"
        }
    }

    public var description: String {
        switch self {
        case .poor: return "Restless, interrupted sleep"
        case .fair: return "Slightly tired, adequate sleep"
        case .good: return "Rested and refreshed"
        case .excellent: return "Deep, fully restorative sleep"
        }
    }

    public var score: Int {
        switch self {
        case .poor: return 1
        case .fair: return 2
        case .good: return 3
        case .excellent: return 4
        }
    }

    public var accentColor: Color {
        switch self {
        case .poor: return .orange
        case .fair: return .yellow
        case .good: return .green
        case .excellent: return .purple
        }
    }
}

public struct SleepRecord: Codable, Equatable {
    public var durationHours: Double
    public var quality: SleepQuality
    public var bedtime: Date
    public var wakeTime: Date
    public var notes: String

    public var formattedDuration: String {
        let hours = Int(durationHours)
        let minutes = Int((durationHours - Double(hours)) * 60)
        if minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(hours)h"
        }
    }

    public init(
        durationHours: Double = 7.5,
        quality: SleepQuality = .good,
        bedtime: Date = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date(),
        wakeTime: Date = Date(),
        notes: String = ""
    ) {
        self.durationHours = durationHours
        self.quality = quality
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.notes = notes
    }
}
