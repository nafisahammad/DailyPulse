import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

public struct DailyRecord: Identifiable, Codable, Equatable {
    /// Date key format: "yyyy-MM-dd"
    public var id: String
    public var userId: String
    public var date: Date

    // 1. Namaz Tracker: completion status of each prayer
    public var prayersCompleted: [String: Bool]

    // 2. Hydration Tracker: current intake and daily target
    public var waterIntakeML: Int
    public var waterGoalML: Int

    // 3. Sleep Tracker: duration and quality
    public var sleepHours: Double
    public var sleepQuality: String
    public var bedtime: Date?
    public var wakeTime: Date?

    public var updatedAt: Date

    public init(
        id: String = DailyRecord.dateFormatter.string(from: Date()),
        userId: String = "",
        date: Date = Date(),
        prayersCompleted: [String: Bool] = [
            PrayerType.fajr.rawValue: false,
            PrayerType.dhuhr.rawValue: false,
            PrayerType.asr.rawValue: false,
            PrayerType.maghrib.rawValue: false,
            PrayerType.isha.rawValue: false
        ],
        waterIntakeML: Int = 0,
        waterGoalML: Int = 2500,
        sleepHours: Double = 7.0,
        sleepQuality: String = SleepQuality.good.rawValue,
        bedtime: Date? = nil,
        wakeTime: Date? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.prayersCompleted = prayersCompleted
        self.waterIntakeML = waterIntakeML
        self.waterGoalML = waterGoalML
        self.sleepHours = sleepHours
        self.sleepQuality = sleepQuality
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.updatedAt = updatedAt
    }

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    // MARK: - Firestore Dictionary Mapping
    public var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "date": date.timeIntervalSince1970,
            "prayersCompleted": prayersCompleted,
            "waterIntakeML": waterIntakeML,
            "waterGoalML": waterGoalML,
            "sleepHours": sleepHours,
            "sleepQuality": sleepQuality,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
        if let bedtime = bedtime {
            dict["bedtime"] = bedtime.timeIntervalSince1970
        }
        if let wakeTime = wakeTime {
            dict["wakeTime"] = wakeTime.timeIntervalSince1970
        }
        return dict
    }

    public static func from(dictionary: [String: Any]) -> DailyRecord? {
        guard let id = dictionary["id"] as? String else { return nil }
        let userId = dictionary["userId"] as? String ?? ""

        var recordDate = Date()
        #if canImport(FirebaseFirestore)
        if let ts = dictionary["date"] as? Timestamp {
            recordDate = ts.dateValue()
        } else if let num = (dictionary["date"] as? NSNumber)?.doubleValue {
            recordDate = Date(timeIntervalSince1970: num)
        }
        #else
        if let num = (dictionary["date"] as? NSNumber)?.doubleValue {
            recordDate = Date(timeIntervalSince1970: num)
        }
        #endif

        let prayersCompleted = dictionary["prayersCompleted"] as? [String: Bool] ?? [:]
        let waterIntakeML = (dictionary["waterIntakeML"] as? NSNumber)?.intValue ?? (dictionary["waterIntakeML"] as? Int) ?? 0
        let waterGoalML = (dictionary["waterGoalML"] as? NSNumber)?.intValue ?? (dictionary["waterGoalML"] as? Int) ?? 2500
        let sleepHours = (dictionary["sleepHours"] as? NSNumber)?.doubleValue ?? (dictionary["sleepHours"] as? Double) ?? 7.0
        let sleepQuality = dictionary["sleepQuality"] as? String ?? SleepQuality.good.rawValue

        var bedtimeDate: Date? = nil
        #if canImport(FirebaseFirestore)
        if let bedtimeTS = dictionary["bedtime"] as? Timestamp {
            bedtimeDate = bedtimeTS.dateValue()
        } else if let bedtimeNum = (dictionary["bedtime"] as? NSNumber)?.doubleValue {
            bedtimeDate = Date(timeIntervalSince1970: bedtimeNum)
        }
        #else
        if let bedtimeNum = (dictionary["bedtime"] as? NSNumber)?.doubleValue {
            bedtimeDate = Date(timeIntervalSince1970: bedtimeNum)
        }
        #endif

        var wakeTimeDate: Date? = nil
        #if canImport(FirebaseFirestore)
        if let wakeTS = dictionary["wakeTime"] as? Timestamp {
            wakeTimeDate = wakeTS.dateValue()
        } else if let wakeNum = (dictionary["wakeTime"] as? NSNumber)?.doubleValue {
            wakeTimeDate = Date(timeIntervalSince1970: wakeNum)
        }
        #else
        if let wakeNum = (dictionary["wakeTime"] as? NSNumber)?.doubleValue {
            wakeTimeDate = Date(timeIntervalSince1970: wakeNum)
        }
        #endif

        var updatedDate = Date()
        #if canImport(FirebaseFirestore)
        if let updatedTS = dictionary["updatedAt"] as? Timestamp {
            updatedDate = updatedTS.dateValue()
        } else if let updatedNum = (dictionary["updatedAt"] as? NSNumber)?.doubleValue {
            updatedDate = Date(timeIntervalSince1970: updatedNum)
        }
        #else
        if let updatedNum = (dictionary["updatedAt"] as? NSNumber)?.doubleValue {
            updatedDate = Date(timeIntervalSince1970: updatedNum)
        }
        #endif

        return DailyRecord(
            id: id,
            userId: userId,
            date: recordDate,
            prayersCompleted: prayersCompleted,
            waterIntakeML: waterIntakeML,
            waterGoalML: waterGoalML,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            bedtime: bedtimeDate,
            wakeTime: wakeTimeDate,
            updatedAt: updatedDate
        )
    }

    // Helper statistics
    public var completedPrayerCount: Int {
        prayersCompleted.values.filter { $0 }.count
    }

    public var waterProgressPercent: Int {
        guard waterGoalML > 0 else { return 0 }
        return Int((Double(waterIntakeML) / Double(waterGoalML)) * 100)
    }
}
