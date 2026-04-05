import SwiftUI

// MARK: - Student Home Dashboard
// Matches student_home_dashboard Stitch mockup

struct DashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Green header
                    headerSection

                    // Content cards (overlap the header slightly)
                    VStack(spacing: LadderSpacing.md) {
                        checklistProgressCard
                        quickActionsSection
                        nextUpCard
                        urgentDeadlineCard
                        dailyTipCard
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.top, -LadderSpacing.xl)
                    .padding(.bottom, 120) // Space for tab bar
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            // Top row: label + avatar
            HStack {
                Text("STUDENT DASHBOARD")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed)
                    .labelTracking()

                Spacer()

                // Profile avatar with streak
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                        )

                    // Streak badge
                    Text("\(viewModel.streak) 🔥")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(LadderColors.accentLime)
                        .clipShape(Capsule())
                        .offset(x: 8, y: 4)
                }
            }

            // Greeting
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("\(viewModel.greetingText), \(viewModel.studentName) 👋")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(.white)

                Text("\(viewModel.careerPath) · Grade \(viewModel.grade)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xxs)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(LadderSpacing.lg)
        .padding(.top, LadderSpacing.xxl)
        .padding(.bottom, LadderSpacing.xxxxl)
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

    // MARK: - Checklist Progress Card

    private var checklistProgressCard: some View {
        LadderCard(elevated: true) {
            HStack(spacing: LadderSpacing.lg) {
                CircularProgressView(
                    progress: viewModel.checklistProgress,
                    label: "\(Int(viewModel.checklistProgress * 100))%",
                    sublabel: "Complete",
                    size: 80
                )

                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Your Checklist")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("\(viewModel.completedTasks) of \(viewModel.totalTasks) tasks done")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Button {
                        coordinator.navigate(to: .activityChecklist)
                    } label: {
                        Text("View Tasks")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("QUICK ACTIONS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            HStack(spacing: LadderSpacing.sm) {
                quickActionTile(
                    title: "Career\nRadar",
                    icon: "scope",
                    color: LadderColors.accentLime,
                    route: .wheelOfCareer
                )
                quickActionTile(
                    title: "Upload\nTranscript",
                    icon: "doc.text.magnifyingglass",
                    color: LadderColors.primary,
                    route: .transcriptUpload
                )
                quickActionTile(
                    title: "Bright\nFutures",
                    icon: "star.circle.fill",
                    color: Color(red: 0.55, green: 0.30, blue: 0.10),
                    route: .brightFuturesTracker
                )
                quickActionTile(
                    title: "4-Year\nRoadmap",
                    icon: "map.fill",
                    color: Color(red: 0.15, green: 0.35, blue: 0.55),
                    route: .roadmap
                )
            }
        }
    }

    private func quickActionTile(title: String, icon: String, color: Color, route: Route) -> some View {
        Button {
            coordinator.navigate(to: route)
        } label: {
            VStack(spacing: LadderSpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(LadderColors.onSurface)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Next Up Card

    private var nextUpCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    LadderTagChip("Next Up", icon: "arrow.right.circle")

                    Spacer()

                    Text(viewModel.nextTaskCategory)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Text(viewModel.nextTaskTitle)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                LinearProgressBar(progress: viewModel.nextTaskProgress)

                HStack {
                    Text("\(Int(viewModel.nextTaskProgress * 100))% complete")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Spacer()

                    LadderTertiaryButton("Continue") {
                        // TODO: Navigate to task
                    }
                }
            }
        }
    }

    // MARK: - Urgent Deadline Card

    private var urgentDeadlineCard: some View {
        HStack(spacing: LadderSpacing.md) {
            Rectangle()
                .fill(LadderColors.error)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("URGENT")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.error)
                    .labelTracking()

                Text(viewModel.urgentDeadlineTitle)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text(viewModel.urgentDeadlineDate)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            Text("\(viewModel.daysUntilDeadline)")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.error)
            +
            Text("\ndays")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Daily Tip Card

    private var dailyTipCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary.opacity(0.8), LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)

            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("DAILY TIP")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed)
                    .labelTracking()

                Text(viewModel.dailyTip)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(LadderSpacing.lg)
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppCoordinator())
}
