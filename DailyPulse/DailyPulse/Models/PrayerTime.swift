import Foundation

// MARK: - Aladhan API Response Models

public struct AladhanResponse: Codable {
    public let code: Int
    public let status: String
    public let data: AladhanData
}

public struct AladhanData: Codable {
    public let timings: Timings
    public let date: AladhanDateContainer
    public let meta: AladhanMeta
}

public struct Timings: Codable {
    public let fajr: String
    public let sunrise: String
    public let dhuhr: String
    public let asr: String
    public let sunset: String
    public let maghrib: String
    public let isha: String
    public let imsak: String?
    public let midnight: String?

    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case sunset = "Sunset"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case imsak = "Imsak"
        case midnight = "Midnight"
    }
}

public struct AladhanDateContainer: Codable {
    public let readable: String
    public let timestamp: String
    public let gregorian: GregorianDate?
    public let hijri: HijriDate?
}

public struct GregorianDate: Codable {
    public let date: String
    public let format: String
    public let day: String
    public let weekday: WeekdayInfo
    public let month: MonthInfo
    public let year: String
}

public struct HijriDate: Codable {
    public let date: String
    public let format: String
    public let day: String
    public let weekday: WeekdayInfo
    public let month: MonthInfo
    public let year: String
    public let designation: DesignationInfo?
}

public struct WeekdayInfo: Codable {
    public let en: String
    public let ar: String?
}

public struct MonthInfo: Codable {
    public let number: Int
    public let en: String
    public let ar: String?
}

public struct DesignationInfo: Codable {
    public let abbreviated: String
    public let expanded: String
}

public struct AladhanMeta: Codable {
    public let latitude: Double
    public let longitude: Double
    public let timezone: String
    public let method: CalculationMethod
}

public struct CalculationMethod: Codable {
    public let id: Int
    public let name: String
}

// MARK: - App Domain Models for Namaz

public enum PrayerType: String, CaseIterable, Codable, Identifiable {
    case fajr = "fajr"
    case dhuhr = "dhuhr"
    case asr = "asr"
    case maghrib = "maghrib"
    case isha = "isha"

    public var id: String { rawValue }

    public var name: String {
        switch self {
        case .fajr: return "Fajr"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }

    public var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    public var iconName: String {
        switch self {
        case .fajr: return "sun.and.horizon.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.dust.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.stars.fill"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .fajr: return 1
        case .dhuhr: return 2
        case .asr: return 3
        case .maghrib: return 4
        case .isha: return 5
        }
    }
}

public struct PrayerItem: Identifiable, Codable, Equatable {
    public var id: String { prayerType.rawValue }
    public let prayerType: PrayerType
    public var scheduledTime: String
    public var isCompleted: Bool
    public var completedAt: Date?

    public init(
        prayerType: PrayerType,
        scheduledTime: String,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.prayerType = prayerType
        self.scheduledTime = scheduledTime
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}
