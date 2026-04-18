import SwiftUI

// The canonical Ladder brand mark. Uses the actual Ladder logo PNG
// (climber + ladder + green hills inside a dark-green circle), processed
// to have a transparent background. No backdrop disc, no Circle() behind
// it — the PNG IS the shape.
//
// Asset: LadderApp/Resources/Assets.xcassets/LadderLogo.imageset
// (background already flood-filled to alpha 0).

public struct LadderLogoMark: View {
    public var size: CGFloat
    public var withShadow: Bool

    public init(size: CGFloat = 180, withShadow: Bool = true) {
        self.size = size
        self.withShadow = withShadow
    }

    public var body: some View {
        Image("LadderLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .modifier(LogoShadow(enabled: withShadow, size: size))
            .accessibilityLabel("Ladder")
    }
}

private struct LogoShadow: ViewModifier {
    let enabled: Bool
    let size: CGFloat
    func body(content: Content) -> some View {
        if enabled {
            content.shadow(color: Color.black.opacity(0.22),
                           radius: size * 0.08,
                           x: 0,
                           y: size * 0.04)
        } else {
            content
        }
    }
}
