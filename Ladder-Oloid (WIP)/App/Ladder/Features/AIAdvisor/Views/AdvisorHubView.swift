import SwiftUI
import SwiftData

// MARK: - AI Advisor Tab Root

struct AdvisorHubView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var viewModel = AdvisorChatViewModel()
    @Query private var profiles: [StudentProfileModel]
    private var userGrade: Int { profiles.first?.grade ?? 10 }

    var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    private var iPhoneLayout: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    quickActionsGrid
                    recentChats
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                    iPadHeroCard
                    iPadFeatureGrid
                    iPadQuickPromptsSection
                }
                .padding(LadderSpacing.xl)
                .frame(maxWidth: 1200)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("AI Advisor")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var iPadHeroCard: some View {
        HStack(alignment: .center, spacing: LadderSpacing.xl) {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("AI ADVISOR")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed)
                    .labelTracking()

                Text("Your College Advisor")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(.white)
                    .editorialTracking()

                Text("Ask me anything about college prep, essays, applications, or SAT strategies.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.8))

                HStack(spacing: LadderSpacing.sm) {
                    Circle()
                        .fill(LadderColors.accentLime)
                        .frame(width: 8, height: 8)
                    Text("AI Online")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.9))
                        .labelTracking()
                }
                .padding(.top, LadderSpacing.xs)

                LadderPrimaryButton("Start New Chat", icon: "bubble.left.and.text.bubble.right") {
                    coordinator.navigate(to: .advisorChat(sessionId: nil))
                }
                .padding(.top, LadderSpacing.md)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 112, height: 112)
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundStyle(LadderColors.secondaryFixed)
            }
        }
        .padding(LadderSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xxxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .ladderShadow(LadderElevation.ambient)
    }

    private var iPadFeatureGrid: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("ADVISOR TOOLS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: LadderSpacing.lg),
                GridItem(.flexible(), spacing: LadderSpacing.lg),
                GridItem(.flexible(), spacing: LadderSpacing.lg)
            ], spacing: LadderSpacing.lg) {
                iPadFeatureCard(
                    title: "AI Chat",
                    description: "Ask anything about college prep, applications, and strategy.",
                    icon: "bubble.left.and.text.bubble.right",
                    buttonTitle: "Open Chat"
                ) {
                    coordinator.navigate(to: .advisorChat(sessionId: nil))
                }

                if GradeGate.isUnlocked(.essayHub, grade: userGrade) {
                    iPadFeatureCard(
                        title: "Essay Hub",
                        description: "Brainstorm, draft, and refine essays with AI feedback.",
                        icon: "text.alignleft",
                        buttonTitle: "Open Essays"
                    ) {
                        coordinator.navigate(to: .essayHub)
                    }
                } else {
                    LockedFeatureCard(title: "Essay Hub", icon: "doc.text.fill", feature: .essayHub, userGrade: userGrade)
                }

                if GradeGate.isUnlocked(.mockInterview, grade: userGrade) {
                    iPadFeatureCard(
                        title: "Mock Interview",
                        description: "Practice common college interview questions.",
                        icon: "person.wave.2",
                        buttonTitle: "Start Practice"
                    ) {
                        coordinator.navigate(to: .interviewPrepHub)
                    }
                } else {
                    LockedFeatureCard(title: "Mock Interview", icon: "person.wave.2", feature: .mockInterview, userGrade: userGrade)
                }

                if GradeGate.isUnlocked(.scoreImprovement, grade: userGrade) {
                    iPadFeatureCard(
                        title: "Score Improvement",
                        description: "Personalized SAT/ACT study plan and resources.",
                        icon: "chart.line.uptrend.xyaxis",
                        buttonTitle: "View Plan"
                    ) {
                        coordinator.navigate(to: .scoreImprovement)
                    }
                } else {
                    LockedFeatureCard(title: "Score Improvement", icon: "chart.line.uptrend.xyaxis", feature: .scoreImprovement, userGrade: userGrade)
                }

                iPadFeatureCard(
                    title: "Career Quiz",
                    description: "Discover your ideal career path through guided assessment.",
                    icon: "sparkle.magnifyingglass",
                    buttonTitle: "Take Quiz"
                ) {
                    coordinator.navigate(to: .careerQuiz)
                }
            }
        }
    }

    private func iPadFeatureCard(title: String, description: String, icon: String, buttonTitle: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.md)
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(LadderColors.primary)
            }

            Text(title)
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)

            Text(description)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: LadderSpacing.sm)

            Button(action: action) {
                HStack(spacing: LadderSpacing.xs) {
                    Text(buttonTitle)
                        .font(LadderTypography.labelLarge)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(LadderColors.primary)
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primaryContainer.opacity(0.25))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .ladderShadow(LadderElevation.ambient)
    }

    private var iPadQuickPromptsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("QUICK PROMPTS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: LadderSpacing.md),
                GridItem(.flexible(), spacing: LadderSpacing.md),
                GridItem(.flexible(), spacing: LadderSpacing.md)
            ], spacing: LadderSpacing.md) {
                ForEach(AdvisorChatViewModel.defaultQuickPrompts) { prompt in
                    quickActionCard(prompt)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("AI ADVISOR")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.secondaryFixed)
                .labelTracking()

            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Your College Advisor")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(.white)

                    Text("Ask me anything about college prep")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                // AI avatar
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.secondaryFixed)
                }
            }
        }
        .padding(LadderSpacing.lg)
        .padding(.top, LadderSpacing.xxl)
        .padding(.bottom, LadderSpacing.xxxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xxxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Quick Actions

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            // Start new chat button
            LadderPrimaryButton("Start New Chat", icon: "bubble.left.and.text.bubble.right") {
                coordinator.navigate(to: .advisorChat(sessionId: nil))
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.top, -LadderSpacing.xl)

            Text("QUICK ACTIONS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
                .padding(.horizontal, LadderSpacing.md)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: LadderSpacing.md),
                GridItem(.flexible(), spacing: LadderSpacing.md)
            ], spacing: LadderSpacing.md) {
                ForEach(AdvisorChatViewModel.defaultQuickPrompts) { prompt in
                    quickActionCard(prompt)
                }
            }
            .padding(.horizontal, LadderSpacing.md)
        }
    }

    private func quickActionCard(_ prompt: QuickPrompt) -> some View {
        Button {
            coordinator.navigate(to: .advisorChat(sessionId: nil))
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Image(systemName: prompt.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 44, height: 44)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

                Text(prompt.title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text(prompt.subtitle)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tools Section

    private var recentChats: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("TOOLS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
                .padding(.horizontal, LadderSpacing.md)

            if GradeGate.isUnlocked(.essayHub, grade: userGrade) {
                toolRow("Essay Hub", icon: "text.alignleft", description: "Brainstorm, draft, and refine your essays") {
                    coordinator.navigate(to: .essayHub)
                }
            } else {
                LockedFeatureCard(title: "Essay Hub", icon: "doc.text.fill", feature: .essayHub, userGrade: userGrade)
                    .padding(.horizontal, LadderSpacing.md)
            }
            if GradeGate.isUnlocked(.mockInterview, grade: userGrade) {
                toolRow("Mock Interview", icon: "person.wave.2", description: "Practice college interview questions") {
                    coordinator.navigate(to: .interviewPrepHub)
                }
            } else {
                LockedFeatureCard(title: "Mock Interview", icon: "person.wave.2", feature: .mockInterview, userGrade: userGrade)
                    .padding(.horizontal, LadderSpacing.md)
            }
            if GradeGate.isUnlocked(.scoreImprovement, grade: userGrade) {
                toolRow("Score Strategy", icon: "chart.line.uptrend.xyaxis", description: "Personalized SAT/ACT improvement plan") {
                    coordinator.navigate(to: .scoreImprovement)
                }
            } else {
                LockedFeatureCard(title: "Score Strategy", icon: "chart.line.uptrend.xyaxis", feature: .scoreImprovement, userGrade: userGrade)
                    .padding(.horizontal, LadderSpacing.md)
            }
            toolRow("Career Quiz", icon: "sparkle.magnifyingglass", description: "Discover your ideal career path") {
                coordinator.navigate(to: .careerQuiz)
            }
        }
        .padding(.top, LadderSpacing.md)
    }

    private func toolRow(_ title: String, icon: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 40, height: 40)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AdvisorHubView()
        .environment(AppCoordinator())
}
