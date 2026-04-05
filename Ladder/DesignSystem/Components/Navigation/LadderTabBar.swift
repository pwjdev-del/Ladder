import SwiftUI

// MARK: - Custom Tab Bar
// Glassmorphism: surface at 70% + ultraThinMaterial backdrop blur
// 5 tabs: Home, Tasks, Colleges (center FAB), Advisor, Profile

struct LadderTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    if tab == .colleges {
                        // Center FAB-style college tab
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? tab.iconFilled : tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(
                                    LinearGradient(
                                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                                .ladderShadow(LadderElevation.primaryGlow)

                            Text(tab.title)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? tab.iconFilled : tab.icon)
                                .font(.system(size: 22))
                                .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)
                                .frame(height: 28)

                            Text(tab.title)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, LadderSpacing.sm)
        .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : LadderSpacing.sm)
        .background(
            Rectangle()
                .fill(LadderColors.surface.opacity(0.85))
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        )
    }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - Tab Enum

enum Tab: Int, CaseIterable {
    case home = 0
    case tasks
    case colleges
    case advisor
    case profile

    var title: String {
        switch self {
        case .home: "Home"
        case .tasks: "Tasks"
        case .colleges: "Colleges"
        case .advisor: "Advisor"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .tasks: "checkmark.circle"
        case .colleges: "graduationcap"
        case .advisor: "sparkles"
        case .profile: "person"
        }
    }

    var iconFilled: String {
        switch self {
        case .home: "house.fill"
        case .tasks: "checkmark.circle.fill"
        case .colleges: "graduationcap.fill"
        case .advisor: "sparkles"
        case .profile: "person.fill"
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        LadderColors.surface
            .ignoresSafeArea()

        LadderTabBar(selectedTab: .constant(.home))
    }
}
