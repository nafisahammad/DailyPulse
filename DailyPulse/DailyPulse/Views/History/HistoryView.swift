import SwiftUI

public struct HistoryView: View {
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedRecordForDetail: DailyRecord?

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color.cardBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Filter Picker
                        Picker("Filter", selection: $historyVM.selectedFilter) {
                            ForEach(HistoryFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: historyVM.selectedFilter) { newFilter in
                            historyVM.setFilter(newFilter)
                        }

                        // Summary Statistics Cards
                        HStack(spacing: 12) {
                            statCard(
                                title: "Avg Sleep",
                                value: String(format: "%.1fh", historyVM.averageSleepHours),
                                icon: "bed.double.fill",
                                color: .sleepPrimary
                            )

                            statCard(
                                title: "Avg Water",
                                value: "\(historyVM.averageWaterML)ml",
                                icon: "drop.fill",
                                color: .hydrationPrimary
                            )

                            statCard(
                                title: "Namaz Rate",
                                value: "\(historyVM.prayerCompletionRate)%",
                                icon: "hands.sparkles.fill",
                                color: .namazPrimary
                            )
                        }

                        // Cloud Sync Status Pill
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.icloud.fill")
                                .foregroundColor(.green)
                            Text("Synced with Cloud Firestore")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            if historyVM.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.horizontal, 4)

                        // Records Section Header
                        HStack {
                            Text("Daily Logs (\(historyVM.records.count))")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.top, 4)

                        // Records List
                        if historyVM.records.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No records found for this period")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Start logging prayers, water, and sleep today to build your history!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                            .frame(maxWidth: .infinity)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(historyVM.records) { record in
                                    recordRowCard(record: record)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await historyVM.loadHistory()
                }
            }
            .navigationTitle("History & Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        authVM.signOut()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .task {
                await historyVM.loadHistory()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.subheadline)
                    Spacer()
                }
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func recordRowCard(record: DailyRecord) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.date.friendlyDateString)
                            .font(.headline)
                        Text(record.date.dayOfWeekString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(record.id)
                        .font(.caption2)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(6)
                }

                Divider()

                HStack(spacing: 16) {
                    // Namaz badge
                    HStack(spacing: 4) {
                        Image(systemName: "hands.sparkles.fill")
                            .foregroundColor(.namazPrimary)
                            .font(.caption)
                        Text("\(record.completedPrayerCount)/5")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    // Water badge
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.hydrationPrimary)
                            .font(.caption)
                        Text("\(record.waterIntakeML)ml")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    // Sleep badge
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .foregroundColor(.sleepPrimary)
                            .font(.caption)
                        Text(String(format: "%.1fh", record.sleepHours))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        if let q = SleepQuality(rawValue: record.sleepQuality) {
                            Text(q.emoji)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}
