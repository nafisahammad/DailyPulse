import SwiftUI

public struct PrayerRowView: View {
    public let prayerType: PrayerType
    public let timeString: String
    public let isCompleted: Bool
    public let onToggle: () -> Void

    public init(
        prayerType: PrayerType,
        timeString: String,
        isCompleted: Bool,
        onToggle: @escaping () -> Void
    ) {
        self.prayerType = prayerType
        self.timeString = timeString
        self.isCompleted = isCompleted
        self.onToggle = onToggle
    }

    public var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.namazPrimary.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: prayerType.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isCompleted ? .namazPrimary : .secondary)
            }

            // Prayer Name & Arabic
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(prayerType.name)
                        .font(.headline)
                        .foregroundColor(isCompleted ? .primary : .primary)

                    Text(prayerType.arabicName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(timeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Completion Toggle Button
            Button(action: onToggle) {
                ZStack {
                    if isCompleted {
                        Circle()
                            .fill(Color.namazPrimary)
                            .frame(width: 36, height: 36)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}
