import Foundation

public protocol NamazAPIServiceProtocol {
    func fetchPrayerTimes(city: String, country: String, date: Date) async throws -> (timings: Timings, dateContainer: AladhanDateContainer)
}

public enum NamazAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int)
    case emptyData

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid prayer API URL configuration."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse prayer times JSON: \(error.localizedDescription)"
        case .serverError(let code):
            return "Prayer times server returned error code \(code)."
        case .emptyData:
            return "No prayer times data received."
        }
    }
}

public final class NamazAPIService: NamazAPIServiceProtocol {
    public static let shared = NamazAPIService()

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchPrayerTimes(
        city: String = "London",
        country: String = "United Kingdom",
        date: Date = Date()
    ) async throws -> (timings: Timings, dateContainer: AladhanDateContainer) {

        // Build URL for Aladhan REST API
        // Endpoint: https://api.aladhan.com/v1/timingsByCity/{DD-MM-YYYY}?city={city}&country={country}&method=2
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date)

        var components = URLComponents(string: "https://api.aladhan.com/v1/timingsByCity/\(dateString)")
        components?.queryItems = [
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "method", value: "2") // ISNA method
        ]

        guard let url = components?.url else {
            throw NamazAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        do {
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw NamazAPIError.serverError(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                throw NamazAPIError.emptyData
            }

            // MARK: - JSON Parsing with JSONDecoder
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode(AladhanResponse.self, from: data)
                return (apiResponse.data.timings, apiResponse.data.date)
            } catch {
                print("❌ [NamazAPIService] JSONDecoder decoding error: \(error)")
                throw NamazAPIError.decodingError(error)
            }
        } catch let apiError as NamazAPIError {
            throw apiError
        } catch {
            print("❌ [NamazAPIService] Network error: \(error)")
            throw NamazAPIError.networkError(error)
        }
    }

    /// Provides safe default prayer times when device is completely offline
    public static var offlineFallbackTimings: Timings {
        Timings(
            fajr: "05:15",
            sunrise: "06:40",
            dhuhr: "12:30",
            asr: "15:45",
            sunset: "18:15",
            maghrib: "18:20",
            isha: "19:45",
            imsak: "05:05",
            midnight: "00:00"
        )
    }
}
