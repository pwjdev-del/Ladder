import SwiftUI

// The canonical Ladder brand mark — renders the exact Stitch-designed logo
// as a SwiftUI composition so there's NO white PNG backdrop bleed. This
// is the one place in the app that draws the logo; every screen imports
// this view instead of Image("LadderLogo").
//
// Visual reference: docs/design/stitch-deliverables/batch-11-full-v2-spec/
// landing_page_v2/screen.png

public struct LadderLogoMark: View {
    public var size: CGFloat = 180
    public var withShadow: Bool = true
    public var style: Style = .cream

    public enum Style {
        /// Cream circle badge with forest-700 climber silhouette (landing/hero).
        case cream
        /// Forest-900 circle with lime climber (founder backdoor + dark contexts).
        case dark
        /// Bare silhouette on whatever surface it sits on — no disc.
        case bareSilhouette
    }

    public init(size: CGFloat = 180, withShadow: Bool = true, style: Style = .cream) {
        self.size = size
        self.withShadow = withShadow
        self.style = style
    }

    public var body: some View {
        ZStack {
            switch style {
            case .cream:
                Circle()
                    .fill(LadderBrand.cream100)
                    .frame(width: size, height: size)
                Image(systemName: "figure.walk")
                    .font(.system(size: size * 0.48, weight: .semibold))
                    .foregroundStyle(LadderBrand.forest700)
            case .dark:
                Circle()
                    .fill(LadderBrand.forest900)
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(LadderBrand.lime500.opacity(0.4), lineWidth: 1.5))
                Image(systemName: "figure.walk")
                    .font(.system(size: size * 0.48, weight: .semibold))
                    .foregroundStyle(LadderBrand.lime500)
            case .bareSilhouette:
                Image(systemName: "figure.walk")
                    .font(.system(size: size * 0.9, weight: .semibold))
                    .foregroundStyle(LadderBrand.cream100)
            }
        }
        .modifier(LogoShadow(enabled: withShadow && style != .bareSilhouette, size: size))
        .accessibilityLabel("Ladder")
    }
}

private struct LogoShadow: ViewModifier {
    let enabled: Bool
    let size: CGFloat
    func body(content: Content) -> some View {
        if enabled {
            content.shadow(color: Color.black.opacity(0.18),
                           radius: size * 0.09,
                           x: 0,
                           y: size * 0.055)
        } else {
            content
        }
    }
}
