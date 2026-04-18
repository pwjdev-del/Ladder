import SwiftUI

// MARK: - Ladder Spacing
// "Double the whitespace you think you need" — Evergreen Ascent Design System

enum LadderSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    static let xxxxl: CGFloat = 80
}

// MARK: - Corner Radius
// "Soft, sophisticated curves" — xl (24px) or lg (16px) for premium feel

enum LadderRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let pill: CGFloat = 9999
}

// MARK: - Elevation / Shadows
// "Ambient shadows at 6% opacity, green-gray tinted, never pure black"

struct LadderShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum LadderElevation {
    /// Subtle ambient shadow for cards
    static let ambient = LadderShadow(
        color: Color(red: 0.12, green: 0.11, blue: 0.08).opacity(0.06),
        radius: 20,
        x: 0,
        y: 4
    )

    /// Floating elements (modals, sheets)
    static let floating = LadderShadow(
        color: Color(red: 0.12, green: 0.11, blue: 0.08).opacity(0.06),
        radius: 30,
        x: 0,
        y: 10
    )

    /// Signature lime glow for Ladder Tracker and CTAs
    static let glow = LadderShadow(
        color: Color(red: 0.79, green: 0.95, blue: 0.30).opacity(0.3),
        radius: 15,
        x: 0,
        y: 0
    )

    /// Primary button hover shadow
    static let primaryGlow = LadderShadow(
        color: Color(red: 0.26, green: 0.38, blue: 0.25).opacity(0.15),
        radius: 20,
        x: 0,
        y: 4
    )
}

// MARK: - Shadow View Modifier

extension View {
    func ladderShadow(_ shadow: LadderShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}
