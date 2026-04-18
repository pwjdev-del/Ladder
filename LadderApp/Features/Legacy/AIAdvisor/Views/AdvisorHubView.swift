import SwiftUI

// MARK: - Sia Tab Root

struct AdvisorHubView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = AdvisorChatViewModel()

    var body: some View {
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("SIA")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.secondaryFixed)
                .labelTracking()

            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Sia")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(.white)

                    Text("Your personal college counselor")
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
            LadderPrimaryButton("Chat with Sia", icon: "bubble.left.and.text.bubble.right") {
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
                ForEach(AdvisorChatViewModel.quickPrompts) { prompt in
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

            toolRow("Essay Hub", icon: "text.alignleft", description: "Brainstorm, draft, and refine your essays") {
                coordinator.navigate(to: .essayHub)
            }
            toolRow("Mock Interview", icon: "person.wave.2", description: "Practice college interview questions with AI") {
                coordinator.navigate(to: .mockInterviewFull(collegeId: nil))
            }
            toolRow("LOCI Generator", icon: "envelope.open", description: "Letter of Continued Interest for waitlists") {
                coordinator.navigate(to: .lociGenerator(collegeId: nil))
            }
            toolRow("Thank You Notes", icon: "heart.text.square", description: "Thank interviewers, teachers, counselors") {
                coordinator.navigate(to: .thankYouNote(collegeId: ""))
            }
            toolRow("Activity Impact", icon: "pencil.line", description: "AI writes 150-char Common App descriptions") {
                coordinator.navigate(to: .activityImpact)
            }
            toolRow("Academic Resume", icon: "doc.richtext", description: "Build and export your academic resume") {
                coordinator.navigate(to: .academicResume)
            }
            toolRow("Score Strategy", icon: "chart.line.uptrend.xyaxis", description: "Personalized SAT/ACT improvement plan") {
                coordinator.navigate(to: .scoreImprovement)
            }
            toolRow("Career Quiz", icon: "sparkle.magnifyingglass", description: "Discover your ideal career path") {
                coordinator.navigate(to: .careerQuiz)
            }
            toolRow("CSS Profile Guide", icon: "building.columns", description: "Step-by-step CSS Profile walkthrough") {
                coordinator.navigate(to: .cssProfileGuide)
            }
            toolRow("NCAA Track", icon: "figure.run", description: "NCAA eligibility and recruitment guide") {
                coordinator.navigate(to: .ncaaTrack)
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
