import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            TodayDashboardView()
                .tabItem {
                    Label("Today", systemImage: "sparkles")
                }
                .tag(0)

            NamazTrackerView()
                .tabItem {
                    Label("Namaz", systemImage: "hands.sparkles.fill")
                }
                .tag(1)

            HydrationTrackerView()
                .tabItem {
                    Label("Hydration", systemImage: "drop.fill")
                }
                .tag(2)

            SleepTrackerView()
                .tabItem {
                    Label("Sleep", systemImage: "bed.double.fill")
                }
                .tag(3)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.xaxis")
                }
                .tag(4)
        }
        .accentColor(.namazPrimary)
    }
}
