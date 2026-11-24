import SwiftUI

public struct SleepTrackerView: View {
    @EnvironmentObject var sleepVM: SleepViewModel

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color.cardBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Success Toast Banner
                        if sleepVM.showSavedBanner {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.icloud.fill")
                                    .foregroundColor(.white)
                                Text("Sleep record synced to Firestore!")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Hero Sleep Card
                        CardView {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TOTAL SLEEP")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.sleepPrimary)
                                            .tracking(1)

                                        Text(sleepVM.formattedDuration)
                                            .font(.system(size: 38, weight: .bold, design: .rounded))
                                    }

                                    Spacer()

                                    // Quality badge
                                    VStack(spacing: 4) {
                                        Text(sleepVM.selectedQuality.emoji)
                                            .font(.system(size: 36))

                                        Text(sleepVM.selectedQuality.rawValue)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(sleepVM.selectedQuality.accentColor)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(sleepVM.selectedQuality.accentColor.opacity(0.12))
                                    .cornerRadius(12)
                                }

                                Divider()

                                Text(sleepVM.selectedQuality.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        // Sleep Duration Stepper Card
                        CardView {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Sleep Duration (Hours)")
                                    .font(.headline)

                                Stepper(value: $sleepVM.sleepHours, in: 1.0...16.0, step: 0.5) {
                                    HStack {
                                        Image(systemName: "bed.double.fill")
                                            .foregroundColor(.sleepPrimary)
                                        Text(String(format: "%.1f Hours", sleepVM.sleepHours))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // Rest Quality Picker Card
                        CardView {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Rest Quality")
                                    .font(.headline)

                                // SwiftUI Picker for Sleep Quality
                                Picker("Rest Quality", selection: $sleepVM.selectedQuality) {
                                    ForEach(SleepQuality.allCases) { quality in
                                        Text("\(quality.emoji) \(quality.rawValue)")
                                            .tag(quality)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 4)
                            }
                        }

                        // Sleep Times (Bedtime & Wake Up)
                        CardView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sleep Schedule")
                                    .font(.headline)

                                DatePicker(
                                    selection: $sleepVM.bedtime,
                                    displayedComponents: [.hourAndMinute]
                                ) {
                                    HStack {
                                        Image(systemName: "moon.fill")
                                            .foregroundColor(.sleepPrimary)
                                        Text("Bedtime")
                                    }
                                }

                                Divider()

                                DatePicker(
                                    selection: $sleepVM.wakeTime,
                                    displayedComponents: [.hourAndMinute]
                                ) {
                                    HStack {
                                        Image(systemName: "sun.max.fill")
                                            .foregroundColor(.orange)
                                        Text("Wake Up")
                                    }
                                }

                                Button {
                                    withAnimation {
                                        sleepVM.calculateHoursFromTimes()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                        Text("Auto-Calculate Duration from Times")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.sleepPrimary)
                                }
                                .padding(.top, 4)
                            }
                        }

                        // Sleep Insight Card
                        CardView {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "heart.text.square")
                                    .font(.title2)
                                    .foregroundColor(.sleepPrimary)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sleep Insight")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    Text(sleepVM.sleepAssessment)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Save Button
                        Button {
                            sleepVM.saveSleepRecord()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                                Text("Save & Sync Sleep Record")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.sleepPrimary, .sleepLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Sleep Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
