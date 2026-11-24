import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

public final class FirebaseManager {
    public static let shared = FirebaseManager()

    public var isConfigured: Bool {
        #if canImport(FirebaseCore)
        return FirebaseApp.app() != nil
        #else
        return false
        #endif
    }

    private init() {}

    public func configure() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() != nil {
            print("🟢 [DailyPulse] Firebase is already configured.")
            return
        }

        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil ||
           Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
            FirebaseApp.configure()
            print("🟢 [DailyPulse] Firebase successfully initialized with GoogleService-Info.plist")
        } else {
            print("⚠️ [DailyPulse] GoogleService-Info.plist not found in bundle. Running in Demo / Offline mode.")
        }
        #else
        print("ℹ️ [DailyPulse] Firebase SDK not imported yet. Running in Demo / Offline mode.")
        #endif
    }
}
