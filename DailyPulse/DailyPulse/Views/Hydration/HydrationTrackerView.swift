import SwiftUI

public struct HydrationTrackerView: View {
    @EnvironmentObject var hydrationVM: HydrationViewModel
    @State private var showingGoalSheet = false
    @State private var tempGoalML = 2500

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color.cardBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Circular Progress Meter
                        CardView {
                            VStack(spacing: 20) {
                                ZStack {
                                    CircularProgressBar(
                                        progress: hydrationVM.progressFraction,
                                        lineWidth: 20,
                                        gradientColors: [.hydrationPrimary, .hydrationLight]
                                    )
                                    .frame(width: 220, height: 220)

                                    VStack(spacing: 6) {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.hydrationPrimary)

                                        Text("\(hydrationVM.currentIntakeML)")
                                            .font(.system(size: 40, weight: .bold, design: .rounded))

                                        Text("of \(hydrationVM.goalML) ml")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Text(hydrationVM.percentageString)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.hydrationPrimary.opacity(0.12))
                                            .foregroundColor(.hydrationPrimary)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.vertical, 12)

                                // Remaining indicator & motivational message
                                VStack(spacing: 6) {
                                    if hydrationVM.remainingML > 0 {
                                        Text("\(hydrationVM.remainingML) ml remaining")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Daily target reached!")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                    }

                                    Text(hydrationVM.motivationalMessage)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Quick-Add Buttons Grid
                        CardView {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Quick Add")
                                    .font(.headline)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    quickAddButton(amount: 150, title: "Cup", icon: "cup.and.saucer.fill")
                                    quickAddButton(amount: 250, title: "Glass", icon: "waterbottle")
                                    quickAddButton(amount: 500, title: "Bottle", icon: "waterbottle.fill")
                                    quickAddButton(amount: 750, title: "Large Flask", icon: "mug.fill")
                                }
                            }
                        }

                        // Custom Amount Stepper Card
                        CardView {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Custom Amount")
                                    .font(.headline)

                                HStack {
                                    Stepper(value: $hydrationVM.customAmountML, in: 50...1500, step: 50) {
                                        HStack {
                                            Image(systemName: "slider.horizontal.3")
                                                .foregroundColor(.hydrationPrimary)
                                            Text("\(hydrationVM.customAmountML) ml")
                                                .font(.headline)
                                        }
                                    }
                                }

                                Button {
                                    withAnimation(.spring()) {
                                        hydrationVM.addWater(hydrationVM.customAmountML)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add \(hydrationVM.customAmountML) ml")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.hydrationPrimary)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }

                        // Controls: Undo & Reset
                        HStack(spacing: 12) {
                            Button {
                                withAnimation {
                                    hydrationVM.undoLastAddition()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward")
                                    Text("Undo")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.secondaryCardBackground)
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }

                            Button {
                                showingGoalSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "target")
                                    Text("Goal")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.secondaryCardBackground)
                                .foregroundColor(.hydrationPrimary)
                                .cornerRadius(12)
                            }

                            Button {
                                withAnimation {
                                    hydrationVM.resetWater()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.secondaryCardBackground)
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Hydration Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingGoalSheet) {
                goalSelectionSheet
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func quickAddButton(amount: Int, title: String, icon: String) -> some View {
        Button {
            withAnimation(.spring()) {
                hydrationVM.addWater(amount)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.hydrationPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("+\(amount) ml")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var goalSelectionSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Daily Target")) {
                    ForEach(hydrationVM.goalPresets, id: \.self) { preset in
                        Button {
                            hydrationVM.updateGoal(preset)
                            showingGoalSheet = false
                        } label: {
                            HStack {
                                Text("\(preset) ml")
                                    .foregroundColor(.primary)
                                Spacer()
                                if hydrationVM.goalML == preset {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.hydrationPrimary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Hydration Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        showingGoalSheet = false
                    }
                }
            }
        }
    }
}
