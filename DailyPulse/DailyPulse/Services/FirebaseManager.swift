import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

public final class FirebaseManager {
    public static let shared = FirebaseManager()

    public private(set) var isConfigured: Bool = false

    private init() {}

    public func configure() {
        #if canImport(FirebaseCore)
        // Check if GoogleService-Info.plist is bundled
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            isConfigured = true
            print("🟢 [DailyPulse] Firebase successfully initialized with GoogleService-Info.plist")
        } else {
            isConfigured = false
            print("⚠️ [DailyPulse] GoogleService-Info.plist not found in bundle. Running in Demo / Offline mode.")
        }
        #else
        isConfigured = false
        print("ℹ️ [DailyPulse] Firebase SDK not imported yet. Running in Demo / Offline mode.")
        #endif
    }
}
