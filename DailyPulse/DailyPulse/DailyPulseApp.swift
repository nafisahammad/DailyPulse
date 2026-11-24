import SwiftUI

@main
struct DailyPulseApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var recordStore = DailyRecordStore()
    @StateObject private var namazViewModel = NamazViewModel()
    @StateObject private var hydrationViewModel = HydrationViewModel()
    @StateObject private var sleepViewModel = SleepViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()

    init() {
        // Initialize Firebase safely
        FirebaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(recordStore)
                .environmentObject(namazViewModel)
                .environmentObject(hydrationViewModel)
                .environmentObject(sleepViewModel)
                .environmentObject(historyViewModel)
        }
    }
}
