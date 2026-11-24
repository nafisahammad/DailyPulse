import SwiftUI

public struct SleepTrackerView: View {
    @EnvironmentObject var sleepVM: SleepViewModel

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                // Sleep Hours Section with Stepper
                Section("Sleep Duration") {
                    HStack {
                        Text("Hours Slept:")
                        Spacer()
                        Text(String(format: "%.1f Hours", sleepVM.sleepHours))
                            .bold()
                            .foregroundColor(.purple)
                    }

                    // SwiftUI Stepper for sleep duration
                    Stepper(
                        "Adjust: \(String(format: "%.1f", sleepVM.sleepHours)) hrs",
                        value: $sleepVM.sleepHours,
                        in: 0.0...16.0,
                        step: 0.5
                    )
                }

                // Sleep Quality Section with Picker
                Section("Rest Quality") {
                    // SwiftUI Picker for rest quality
                    Picker("Quality", selection: $sleepVM.selectedQuality) {
                        ForEach(SleepQuality.allCases) { quality in
                            Text("\(quality.emoji) \(quality.rawValue)").tag(quality)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(sleepVM.selectedQuality.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Schedule Section (Bedtime & Wake Up)
                Section("Schedule") {
                    DatePicker("Bedtime", selection: $sleepVM.bedtime, displayedComponents: .hourAndMinute)
                    DatePicker("Wake-Up Time", selection: $sleepVM.wakeTime, displayedComponents: .hourAndMinute)

                    Button("Calculate Duration From Times") {
                        sleepVM.calculateHoursFromTimes()
                    }
                    .font(.subheadline)
                }

                // Save Action Section
                Section {
                    Button {
                        sleepVM.saveSleepRecord()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "icloud.and.arrow.up.fill")
                            Text("Save Sleep Record to Firestore")
                                .bold()
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)

                    if sleepVM.showSavedBanner {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Successfully updated in Cloud Firestore!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Sleep Tracker")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
