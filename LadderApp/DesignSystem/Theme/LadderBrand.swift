import SwiftUI

// Canonical Ladder brand tokens. Extracted from Stitch deliverables at
// docs/design/stitch-deliverables/batch-11-full-v2-spec/landing_page_v2/code.html
// See also docs/design/stitch-batches/_shared-header.md for the token rationale.

public enum LadderBrand {

    // MARK: - Color (mapped to Stitch tailwind tokens where applicable)

    /// `primary-container` in Stitch. Forest green, primary background.
    public static let forest700 = Color(red: 0x52 / 255.0, green: 0x70 / 255.0, blue: 0x50 / 255.0) // #527050

    /// `primary` in Stitch. Deeper forest, used for on-dark-surface elements.
    public static let forest900 = Color(red: 0x3A / 255.0, green: 0x57 / 255.0, blue: 0x39 / 255.0) // #3A5739

    /// `tertiary-container` — secondary forest.
    public static let forest500 = Color(red: 0x54 / 255.0, green: 0x70 / 255.0, blue: 0x4E / 255.0) // #54704E

    /// `secondary-fixed-dim` / lime CTA fill.
    public static let lime500 = Color(red: 0xA8 / 255.0, green: 0xD2 / 255.0, blue: 0x34 / 255.0) // #A8D234

    /// Focus glow.
    public static let lime300 = Color(red: 0xCC / 255.0, green: 0xE6 / 255.0, blue: 0x8A / 255.0) // #CCE68A

    /// Cream — logo badge + on-dark headings.
    public static let cream100 = Color(red: 0xF5 / 255.0, green: 0xF0 / 255.0, blue: 0xE5 / 255.0) // #F5F0E5

    /// Paper — light-surface cards.
    public static let paper = Color(red: 0xFF / 255.0, green: 0xFF / 255.0, blue: 0xFF / 255.0) // #FFFFFF

    /// Stone — muted input fill, inactive chip, sign-up-as-student button.
    public static let stone200 = Color(red: 0xE8 / 255.0, green: 0xE2 / 255.0, blue: 0xD8 / 255.0) // #E8E2D8

    /// Ink — primary text on light surfaces, primary CTA text on lime.
    public static let ink900 = Color(red: 0x1B / 255.0, green: 0x1F / 255.0, blue: 0x1B / 255.0) // #1B1F1B

    public static let ink600 = Color(red: 0x4A / 255.0, green: 0x53 / 255.0, blue: 0x46 / 255.0) // #4A5346
    public static let ink400 = Color(red: 0x8A / 255.0, green: 0x90 / 255.0, blue: 0x82 / 255.0) // #8A9082

    public static let statusRed = Color(red: 0xC9 / 255.0, green: 0x4A / 255.0, blue: 0x3F / 255.0) // #C94A3F
    public static let statusAmber = Color(red: 0xD9 / 255.0, green: 0xA5 / 255.0, blue: 0x4A / 255.0) // #D9A54A

    // MARK: - Radii

    public static let radiusCard: CGFloat = 12
    public static let radiusInput: CGFloat = 8
    public static let radiusChip: CGFloat = 8
    public static let radiusModal: CGFloat = 24

    // MARK: - Shadows

    public static func cardShadowOnDark<V: View>(_ view: V) -> some View {
        view.shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    public static func cardShadowOnLight<V: View>(_ view: V) -> some View {
        view.shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Font convenience

public extension Font {
    /// Playfair Display semibold — headlines / display. Scales with Dynamic Type.
    static func ladderDisplay(_ size: CGFloat, relativeTo style: Font.TextStyle = .largeTitle) -> Font {
        Font.custom("PlayfairDisplay-SemiBold", size: size, relativeTo: style)
    }

    static func ladderSerif(_ size: CGFloat, relativeTo style: Font.TextStyle = .title2) -> Font {
        Font.custom("PlayfairDisplay-SemiBold", size: size, relativeTo: style)
    }

    /// Manrope regular — body.
    static func ladderBody(_ size: CGFloat = 16, relativeTo style: Font.TextStyle = .body) -> Font {
        Font.custom("Manrope-Regular", size: size, relativeTo: style)
    }

    /// Manrope semibold — button labels, emphasized body.
    static func ladderLabel(_ size: CGFloat = 14, relativeTo style: Font.TextStyle = .callout) -> Font {
        Font.custom("Manrope-SemiBold", size: size, relativeTo: style)
    }

    /// Manrope 11pt upper tracking — caps labels.
    static func ladderCaps(_ size: CGFloat = 11) -> Font {
        Font.custom("Manrope-SemiBold", size: size, relativeTo: .caption2)
    }
}
