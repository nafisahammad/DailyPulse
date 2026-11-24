import SwiftUI

public struct HydrationTrackerView: View {
    @EnvironmentObject var hydrationVM: HydrationViewModel
    @State private var showingGoalPicker = false

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                // Live Progress Bar Section
                Section("Daily Water Intake Goal") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("\(hydrationVM.currentIntakeML) ml")
                                .font(.title.bold())
                                .foregroundColor(.blue)

                            Text("of \(hydrationVM.goalML) ml goal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(hydrationVM.percentageString)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        // Native SwiftUI Live Progress Bar
                        ProgressView(
                            value: min(Double(hydrationVM.currentIntakeML), Double(hydrationVM.goalML)),
                            total: Double(hydrationVM.goalML)
                        )
                        .tint(.blue)

                        if hydrationVM.remainingML > 0 {
                            Text("\(hydrationVM.remainingML) ml remaining today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Goal reached! Great job!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Quick-Add Buttons Section
                Section("Quick Add") {
                    HStack(spacing: 12) {
                        Button("+250 ml") {
                            hydrationVM.addWater(250)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        Button("+500 ml") {
                            hydrationVM.addWater(500)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        Button("+750 ml") {
                            hydrationVM.addWater(750)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                }

                // Custom Amount Section
                Section("Custom Intake") {
                    Stepper(
                        "Amount: \(hydrationVM.customAmountML) ml",
                        value: $hydrationVM.customAmountML,
                        in: 50...1500,
                        step: 50
                    )

                    Button("Add \(hydrationVM.customAmountML) ml") {
                        hydrationVM.addWater(hydrationVM.customAmountML)
                    }
                }

                // Options & Goal
                Section("Settings & Reset") {
                    Picker("Daily Target Goal", selection: Binding(
                        get: { hydrationVM.goalML },
                        set: { hydrationVM.updateGoal($0) }
                    )) {
                        ForEach(hydrationVM.goalPresets, id: \.self) { amount in
                            Text("\(amount) ml").tag(amount)
                        }
                    }

                    Button("Reset Today's Intake", role: .destructive) {
                        hydrationVM.resetWater()
                    }
                }

                // Firestore Sync Note
                Section {
                    HStack {
                        Image(systemName: "checkmark.icloud")
                            .foregroundColor(.green)
                        Text("Hydration records automatically update in Firestore")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Hydration Tracker")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
