import SwiftUI

// MARK: - PrivacyOverlayModifier
//
// S3-1 fix: iOS snapshots the frontmost view when the app enters background or
// inactive state (task-switcher, ambient screen capture). Without a cover, SIA
// chat, crisis resources, grades, and essays are visible to anyone who swipes
// up on the device without unlocking.
//
// This modifier listens to @Environment(\.scenePhase). When the phase leaves
// .active it overlays a near-opaque branded screen that replaces sensitive
// content in the iOS snapshot. The overlay fades in with a short animation so
// the transition is visually clean; it disappears immediately on re-activation
// so it never interferes with the user's own experience of the app.
//
// Usage (root scene, LadderApp.swift):
//   AppRootView()
//       .privacyOverlay()
//
// The modifier is safe to attach at any view level, but applying it at the
// root WindowGroup content view ensures 100 % coverage regardless of which
// screen is frontmost.

struct PrivacyOverlayModifier: ViewModifier {
    @Environment(\.scenePhase) private var phase

    func body(content: Content) -> some View {
        content.overlay {
            if phase != .active {
                privacyScreen
                    .transition(.opacity)
            }
        }
        // Animate state transitions so the cover fades in rather than snapping.
        .animation(.easeInOut(duration: 0.15), value: phase)
    }

    // MARK: - Overlay content

    @ViewBuilder
    private var privacyScreen: some View {
        ZStack {
            Color.black.opacity(0.95)

            VStack(spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))

                Text("Ladder")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - View extension

extension View {
    /// Covers the view with a branded privacy screen whenever the scene is not
    /// active (`.inactive` or `.background`). Prevents iOS task-switcher
    /// snapshots from capturing sensitive student data. Apply at the root scene.
    func privacyOverlay() -> some View {
        modifier(PrivacyOverlayModifier())
    }
}
