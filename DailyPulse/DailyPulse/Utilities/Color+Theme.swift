import SwiftUI

extension Color {
    // Theme Accents
    public static let namazPrimary = Color(red: 0.08, green: 0.65, blue: 0.45)
    public static let namazLight = Color(red: 0.20, green: 0.80, blue: 0.58)

    public static let hydrationPrimary = Color(red: 0.12, green: 0.53, blue: 0.90)
    public static let hydrationLight = Color(red: 0.35, green: 0.75, blue: 0.98)

    public static let sleepPrimary = Color(red: 0.36, green: 0.30, blue: 0.78)
    public static let sleepLight = Color(red: 0.58, green: 0.48, blue: 0.95)

    public static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0)
            : UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0)
    })

    public static let secondaryCardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.19, blue: 0.22, alpha: 1.0)
            : UIColor.white
    })
}
