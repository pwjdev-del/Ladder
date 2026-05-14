import SwiftUI

// D-005 / DECISIONS.md D-004 — Parent multi-child digest deferred to v1.1.
// The previous implementation shipped a sibling switcher with hardcoded mock
// children (Maya / Noah). That mock surface was removed per FIX_PLAN_2026-05-14
// decision D2. Replace with a calm placeholder so the .parent role routes to
// something intentional rather than fake data.
//
// Sign-out: delegates to `onLogout` closure injected by SignedInRouter, which
// calls SupabaseAuthService.shared.signOut() and then dismiss(). No direct
// auth coupling needed here.

public struct ParentDashboardView: View {
    public let session: SignedInSession
    public let onLogout: () -> Void

    public init(session: SignedInSession, onLogout: @escaping () -> Void = {}) {
        self.session = session
        self.onLogout = onLogout
    }

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            MaxWidthContainer(maxWidth: 480) {
                VStack(spacing: 0) {
                    // Top bar: consistent with other role dashboards
                    HStack {
                        Spacer()
                        LogoutButton(action: onLogout)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()

                    // Placeholder body
                    VStack(spacing: 24) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 56))
                            .foregroundStyle(LadderBrand.lime500)

                        Text("Parent dashboard coming soon")
                            .font(.ladderDisplay(24, relativeTo: .title2))
                            .foregroundStyle(LadderBrand.cream100)

                        Text("We're working on a way to keep you connected to your student's progress. For now, please ask your student to share their journey directly with you.")
                            .font(.ladderBody(15))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(LadderBrand.cream100.opacity(0.72))
                            .padding(.horizontal, 32)
                    }

                    Spacer()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
        .requireNonStaff()
    }
}

// MARK: - Previews

#if DEBUG
private let _previewSession = SignedInSession(
    role: .parent,
    displayName: "Alex.Parent",
    tenantName: "Demo High"
)

#Preview("iPhone 15 Pro", traits: .sizeThatFitsLayout) {
    ParentDashboardView(session: _previewSession)
        .frame(width: 393, height: 852)
}

#Preview("iPad Air 10.9 portrait", traits: .sizeThatFitsLayout) {
    ParentDashboardView(session: _previewSession)
        .frame(width: 820, height: 1180)
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad Pro 12.9 landscape", traits: .sizeThatFitsLayout) {
    ParentDashboardView(session: _previewSession)
        .frame(width: 1366, height: 1024)
        .environment(\.horizontalSizeClass, .regular)
}
#endif
