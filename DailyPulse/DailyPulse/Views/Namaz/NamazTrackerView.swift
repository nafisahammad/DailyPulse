import SwiftUI

public struct NamazTrackerView: View {
    @EnvironmentObject var namazVM: NamazViewModel
    @State private var showingLocationSheet = false
    @State private var customCity = ""
    @State private var customCountry = ""

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color.cardBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Location & Date Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Button {
                                    showingLocationSheet = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.namazPrimary)
                                        Text("\(namazVM.selectedCity), \(namazVM.selectedCountry)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                if !namazVM.gregorianDateString.isEmpty {
                                    Text(namazVM.gregorianDateString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if !namazVM.hijriDateString.isEmpty {
                                Text(namazVM.hijriDateString)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.namazPrimary.opacity(0.12))
                                    .foregroundColor(.namazPrimary)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 4)

                        // Next Prayer Banner Card
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("UPCOMING PRAYER")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.namazPrimary)
                                        .tracking(1)

                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text(namazVM.nextPrayerName)
                                            .font(.title2)
                                            .fontWeight(.bold)

                                        Text(namazVM.nextPrayerTime)
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }

                                    Text(namazVM.timeRemainingString)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.namazPrimary, .namazLight],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 56, height: 56)

                                    Image(systemName: "clock.badge.checkmark.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        // Daily Progress Card
                        CardView {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Today's Prayers")
                                        .font(.headline)

                                    Spacer()

                                    Text("\(namazVM.completedCount) of 5 Completed")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.namazPrimary)
                                }

                                LinearProgressBar(
                                    progress: namazVM.progressFraction,
                                    height: 10,
                                    tintColor: .namazPrimary
                                )
                            }
                        }

                        // Prayers List
                        CardView {
                            VStack(spacing: 0) {
                                ForEach(PrayerType.allCases) { prayer in
                                    PrayerRowView(
                                        prayerType: prayer,
                                        timeString: namazVM.timeString(for: prayer),
                                        isCompleted: namazVM.isPrayerCompleted(prayer)
                                    ) {
                                        withAnimation(.spring()) {
                                            namazVM.togglePrayer(prayer)
                                        }
                                    }

                                    if prayer != PrayerType.allCases.last {
                                        Divider()
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                        }

                        // API Error notice if any
                        if let error = namazVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await namazVM.fetchTimings()
                }
            }
            .navigationTitle("Namaz Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await namazVM.fetchTimings()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingLocationSheet) {
                locationSelectionSheet
            }
            .task {
                if namazVM.timings == nil {
                    await namazVM.fetchTimings()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Location Selection Sheet
    private var locationSelectionSheet: some View {
        NavigationView {
            List {
                Section(header: Text("Popular Cities")) {
                    ForEach(LocationPreset.defaults) { preset in
                        Button {
                            namazVM.setLocation(city: preset.city, country: preset.country)
                            showingLocationSheet = false
                        } label: {
                            HStack {
                                Text("\(preset.city), \(preset.country)")
                                    .foregroundColor(.primary)
                                Spacer()
                                if namazVM.selectedCity == preset.city && namazVM.selectedCountry == preset.country {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.namazPrimary)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Custom Location")) {
                    TextField("City (e.g. Chicago)", text: $customCity)
                    TextField("Country (e.g. United States)", text: $customCountry)

                    Button("Apply Custom Location") {
                        if !customCity.trimmingCharacters(in: .whitespaces).isEmpty &&
                           !customCountry.trimmingCharacters(in: .whitespaces).isEmpty {
                            namazVM.setLocation(city: customCity, country: customCountry)
                            showingLocationSheet = false
                        }
                    }
                    .disabled(customCity.isEmpty || customCountry.isEmpty)
                }
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingLocationSheet = false
                    }
                }
            }
        }
    }
}
