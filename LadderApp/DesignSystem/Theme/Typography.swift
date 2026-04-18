import SwiftUI
import UIKit

// LadderTypography — scales with Dynamic Type.
//
// Phase 4 design review: the previous implementation used `Font.custom(_, size:)`
// with fixed point sizes. That DOES NOT respond to Dynamic Type. K-8 students
// and admins reading dense tables need XL–AX5; this migration fixes that.
//
// We bind each custom font to a UIFont text style via UIFontMetrics so users'
// preferred content-size category scales the font. Dense surfaces
// (counselor queue, admin tables) should still clamp to .xxxLarge via
// `.dynamicTypeSize(...)` at the call site.

enum LadderTypography {

    // MARK: - Display (Noto Serif)

    static let displayLarge  = scaled("NotoSerif-Bold", size: 56, style: .largeTitle)
    static let displayMedium = scaled("NotoSerif-Bold", size: 45, style: .largeTitle)
    static let displaySmall  = scaled("NotoSerif-Bold", size: 36, style: .largeTitle)

    // MARK: - Headline (Noto Serif)

    static let headlineLarge  = scaled("NotoSerif-Bold",     size: 32, style: .title)
    static let headlineMedium = scaled("NotoSerif-SemiBold", size: 28, style: .title2)
    static let headlineSmall  = scaled("NotoSerif-Medium",   size: 24, style: .title3)

    // MARK: - Title (Manrope)

    static let titleLarge  = scaled("Manrope-Bold",     size: 22, style: .headline)
    static let titleMedium = scaled("Manrope-SemiBold", size: 16, style: .subheadline)
    static let titleSmall  = scaled("Manrope-SemiBold", size: 14, style: .subheadline)

    // MARK: - Body (Manrope)

    static let bodyLarge  = scaled("Manrope-Regular", size: 16, style: .body)
    static let bodyMedium = scaled("Manrope-Regular", size: 14, style: .callout)
    static let bodySmall  = scaled("Manrope-Regular", size: 12, style: .footnote)

    // MARK: - Label (Manrope)

    static let labelLarge  = scaled("Manrope-Bold",     size: 14, style: .caption)
    static let labelMedium = scaled("Manrope-Bold",     size: 12, style: .caption2)
    static let labelSmall  = scaled("Manrope-SemiBold", size: 10, style: .caption2)

    // MARK: - Italic variants

    static let displayLargeItalic = scaled("NotoSerif-BoldItalic", size: 56, style: .largeTitle)
    static let headlineMediumItalic = scaled("NotoSerif-Italic", size: 28, style: .title2)
    static let bodyLargeItalic = scaled("NotoSerif-Italic", size: 16, style: .body)

    // MARK: - Dynamic Type helper

    private static func scaled(_ fontName: String,
                               size: CGFloat,
                               style: UIFont.TextStyle) -> Font {
        let base = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        let metrics = UIFontMetrics(forTextStyle: style)
        let scaled = metrics.scaledFont(for: base)
        return Font(scaled)
    }
}

// MARK: - Editorial tracking

struct EditorialTrackingModifier: ViewModifier {
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content.tracking(tracking)
    }
}

extension View {
    func editorialTracking() -> some View {
        modifier(EditorialTrackingModifier(tracking: -0.5))
    }

    func labelTracking() -> some View {
        modifier(EditorialTrackingModifier(tracking: 2.0))
    }

    /// For dense surfaces (counselor queue, admin tables, founder cards).
    /// Clamps Dynamic Type to keep tables legible without overflow.
    func denseDynamicType() -> some View {
        dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
