import SwiftUI

// Brand gradient backdrops — every auth surface uses these instead of white.
// Direction: bright lime rim light at the top → deep forest sink at the bottom,
// so the Ladder logo sits in a halo of brand color. Cards float above with a
// cream / frosted scrim so type stays readable.

public enum BrandGradient {

    /// Default auth-screen backdrop. Bright forest with a subtle lime halo near
    /// the top, sinking to forest-900 at the bottom.
    public static var auth: some View {
        LinearGradient(
            stops: [
                .init(color: LadderBrand.lime500.opacity(0.25), location: 0.0),
                .init(color: LadderBrand.forest700,               location: 0.28),
                .init(color: LadderBrand.forest700,               location: 0.72),
                .init(color: LadderBrand.forest900,               location: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    /// Lighter variant for list/picker screens (school picker, invite flows).
    /// Still no white — cream-tinted forest glow.
    public static var list: some View {
        LinearGradient(
            stops: [
                .init(color: LadderBrand.forest500, location: 0.0),
                .init(color: LadderBrand.forest700, location: 0.45),
                .init(color: LadderBrand.forest900, location: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    /// Accent glow used at the top of hero strips — lime halo behind the logo.
    public static var heroGlow: some View {
        RadialGradient(
            colors: [LadderBrand.lime500.opacity(0.35), .clear],
            center: .top,
            startRadius: 0,
            endRadius: 240
        )
        .ignoresSafeArea()
    }
}
