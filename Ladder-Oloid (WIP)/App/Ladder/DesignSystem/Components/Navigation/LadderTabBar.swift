import SwiftUI

// MARK: - Custom Tab Bar
// Glassmorphism: surfaceVariant at 70% + 20px backdrop blur
// 5 tabs: Home, Tasks, Colleges, Advisor, Profile

struct LadderTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .colleges {
                    // Center FAB-style college tab
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(
                                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }
                    }
                } else {
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: selectedTab == tab ? tab.iconFilled : tab.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)

                            Text(tab.title)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.top, LadderSpacing.sm)
        .padding(.bottom, LadderSpacing.sm + safeAreaBottom)
        .background(
            LadderColors.surface
                .opacity(0.7)
                .background(.ultraThinMaterial)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
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
