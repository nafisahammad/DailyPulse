import SwiftUI

public struct TodayDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var namazVM: NamazViewModel
    @EnvironmentObject var hydrationVM: HydrationViewModel
    @EnvironmentObject var sleepVM: SleepViewModel
    @EnvironmentObject var recordStore: DailyRecordStore

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color.cardBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // User Welcome Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello, \(authVM.currentUser?.displayName.isEmpty == false ? authVM.currentUser!.displayName : "Friend") 👋")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(Date().dayOfWeekString + ", " + Date().friendlyDateString)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(Color.namazPrimary.opacity(0.12))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.namazPrimary)
                            }
                        }
                        .padding(.horizontal, 4)

                        // 3-Pillar Quick Summary Cards
                        VStack(spacing: 14) {
                            // 1. Namaz Card
                            NavigationLink {
                                NamazTrackerView()
                            } label: {
                                CardView {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.namazPrimary.opacity(0.15))
                                                .frame(width: 50, height: 50)
                                            Image(systemName: "hands.sparkles.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.namazPrimary)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Namaz Prayers")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text("\(namazVM.completedCount)/5 Completed")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.namazPrimary)
                                            }

                                            Text("Next: \(namazVM.nextPrayerName) at \(namazVM.nextPrayerTime)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            LinearProgressBar(
                                                progress: namazVM.progressFraction,
                                                height: 6,
                                                tintColor: .namazPrimary
                                            )
                                            .padding(.top, 2)
                                        }

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            // 2. Hydration Card
                            NavigationLink {
                                HydrationTrackerView()
                            } label: {
                                CardView {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.hydrationPrimary.opacity(0.15))
                                                .frame(width: 50, height: 50)
                                            Image(systemName: "drop.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.hydrationPrimary)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Hydration")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text("\(hydrationVM.currentIntakeML)/\(hydrationVM.goalML) ml")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.hydrationPrimary)
                                            }

                                            Text("\(hydrationVM.remainingML) ml to reach goal • \(hydrationVM.percentageString)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            LinearProgressBar(
                                                progress: hydrationVM.progressFraction,
                                                height: 6,
                                                tintColor: .hydrationPrimary
                                            )
                                            .padding(.top, 2)
                                        }

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            // 3. Sleep Card
                            NavigationLink {
                                SleepTrackerView()
                            } label: {
                                CardView {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.sleepPrimary.opacity(0.15))
                                                .frame(width: 50, height: 50)
                                            Image(systemName: "bed.double.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.sleepPrimary)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Sleep Tracker")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text(sleepVM.formattedDuration)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.sleepPrimary)
                                            }

                                            Text("Quality: \(sleepVM.selectedQuality.emoji) \(sleepVM.selectedQuality.rawValue)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            Text(sleepVM.sleepAssessment)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Sync Status Indicator
                        HStack(spacing: 8) {
                            Image(systemName: "icloud.and.arrow.up.fill")
                                .foregroundColor(.namazPrimary)
                            Text("Automatic Cloud Sync Active")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.top, 4)
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("DailyPulse")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
