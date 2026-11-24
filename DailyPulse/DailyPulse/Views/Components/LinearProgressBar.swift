import SwiftUI

public struct LinearProgressBar: View {
    public let progress: Double
    public let height: CGFloat
    public let tintColor: Color

    public init(progress: Double, height: CGFloat = 8, tintColor: Color = .namazPrimary) {
        self.progress = min(max(progress, 0.0), 1.0)
        self.height = height
        self.tintColor = tintColor
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.18))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(tintColor)
                    .frame(width: geometry.size.width * CGFloat(progress), height: height)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}
