import SwiftUI

public struct CircularProgressBar: View {
    public let progress: Double
    public let lineWidth: CGFloat
    public let gradientColors: [Color]

    public init(
        progress: Double,
        lineWidth: CGFloat = 16,
        gradientColors: [Color] = [.hydrationPrimary, .hydrationLight]
    ) {
        self.progress = min(max(progress, 0.0), 1.0)
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: lineWidth
                )

            // Animated progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
        }
    }
}
