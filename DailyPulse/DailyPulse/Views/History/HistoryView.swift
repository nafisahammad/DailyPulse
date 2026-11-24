import SwiftUI

public struct HistoryView: View {
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var authVM: AuthViewModel

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                // Cloud Sync & Account Status
                Section("Firestore & Account") {
                    if let user = authVM.currentUser {
                        HStack {
                            Text("Account:")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundColor(.green)
                        Text("Cloud Firestore Synced")
                        Spacer()
                        if historyVM.isLoading {
                            ProgressView()
                        }
                    }

                    Button("Sign Out", role: .destructive) {
                        authVM.signOut()
                    }
                }

                // Summary Averages
                Section("Recent Averages") {
                    HStack {
                        Text("Average Sleep:")
                        Spacer()
                        Text(String(format: "%.1f hrs", historyVM.averageSleepHours))
                            .bold()
                    }

                    HStack {
                        Text("Average Water:")
                        Spacer()
                        Text("\(historyVM.averageWaterML) ml")
                            .bold()
                    }

                    HStack {
                        Text("Prayer Consistency:")
                        Spacer()
                        Text("\(historyVM.prayerCompletionRate)%")
                            .bold()
                    }
                }

                // Saved Daily Records List
                Section("Past Days (\(historyVM.records.count))") {
                    if historyVM.records.isEmpty {
                        Text("No records found in Firestore yet. Complete some prayers, log water, or sleep today to start your history!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(historyVM.records) { record in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(record.date.friendlyDateString)
                                        .font(.headline)
                                    Spacer()
                                    Text(record.id)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                HStack(spacing: 14) {
                                    Text("🕌 \(record.completedPrayerCount)/5")
                                    Text("💧 \(record.waterIntakeML) ml")
                                    Text("😴 \(String(format: "%.1f", record.sleepHours))h (\(record.sleepQuality))")
                                }
                                .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("History & Cloud Sync")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await historyVM.loadHistory()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await historyVM.loadHistory()
            }
            .task {
                await historyVM.loadHistory()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
