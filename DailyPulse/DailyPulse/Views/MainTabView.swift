import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            NamazTrackerView()
                .tabItem {
                    Label("Namaz", systemImage: "clock.fill")
                }
                .tag(0)

            HydrationTrackerView()
                .tabItem {
                    Label("Hydration", systemImage: "drop.fill")
                }
                .tag(1)

            SleepTrackerView()
                .tabItem {
                    Label("Sleep", systemImage: "bed.double.fill")
                }
                .tag(2)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(3)
        }
    }
}
