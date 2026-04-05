import SwiftUI

// MARK: - Ladder Typography
// Headlines: Noto Serif (editorial feel)
// Body/UI: Manrope (clean geometric)
// Register fonts in Info.plist under "Fonts provided by application"

enum LadderTypography {

    // MARK: - Display (Noto Serif)

    static let displayLarge = Font.custom("NotoSerif-Bold", size: 56)
        .leading(.tight)
    static let displayMedium = Font.custom("NotoSerif-Bold", size: 45)
        .leading(.tight)
    static let displaySmall = Font.custom("NotoSerif-Bold", size: 36)
        .leading(.tight)

    // MARK: - Headline (Noto Serif)

    static let headlineLarge = Font.custom("NotoSerif-Bold", size: 32)
    static let headlineMedium = Font.custom("NotoSerif-SemiBold", size: 28)
    static let headlineSmall = Font.custom("NotoSerif-Medium", size: 24)

    // MARK: - Title (Manrope)

    static let titleLarge = Font.custom("Manrope-Bold", size: 22)
    static let titleMedium = Font.custom("Manrope-SemiBold", size: 16)
    static let titleSmall = Font.custom("Manrope-SemiBold", size: 14)

    // MARK: - Body (Manrope)

    static let bodyLarge = Font.custom("Manrope-Regular", size: 16)
    static let bodyMedium = Font.custom("Manrope-Regular", size: 14)
    static let bodySmall = Font.custom("Manrope-Regular", size: 12)

    // MARK: - Label (Manrope)

    static let labelLarge = Font.custom("Manrope-Bold", size: 14)
    static let labelMedium = Font.custom("Manrope-Bold", size: 12)
    static let labelSmall = Font.custom("Manrope-SemiBold", size: 10)
}

// MARK: - Italic variants for editorial emphasis

extension LadderTypography {
    static let displayLargeItalic = Font.custom("NotoSerif-BoldItalic", size: 56)
        .leading(.tight)
    static let headlineMediumItalic = Font.custom("NotoSerif-Italic", size: 28)
    static let bodyLargeItalic = Font.custom("NotoSerif-Italic", size: 16)
}

// MARK: - View Modifier for editorial letter spacing

struct EditorialTrackingModifier: ViewModifier {
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content.tracking(tracking)
    }
}

extension View {
    /// Tight letter-spacing for display headlines (-2%)
    func editorialTracking() -> some View {
        modifier(EditorialTrackingModifier(tracking: -0.5))
    }

    /// Wide letter-spacing for small caps labels
    func labelTracking() -> some View {
        modifier(EditorialTrackingModifier(tracking: 2.0))
    }
}
