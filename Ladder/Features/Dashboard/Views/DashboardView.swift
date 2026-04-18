import SwiftUI

// MARK: - Student Home Dashboard (Simplified 3-Section Layout)

struct DashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var context
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Green header
                    headerSection

                    // Content sections
                    VStack(spacing: LadderSpacing.md) {
                        if viewModel.showMajorPrompt {
                            majorPromptBanner
                        }
                        welcomeProgressCard
                        actionsThisWeek
                        upcomingDeadlinesSection
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.top, -LadderSpacing.xl)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadDashboard(context: context)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Text("STUDENT DASHBOARD")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed)
                    .labelTracking()

                Spacer()

                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                        )

                    if viewModel.streak > 0 {
                        Text("\(viewModel.streak) \u{1F525}")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(LadderColors.accentLime)
                            .clipShape(Capsule())
                            .offset(x: 8, y: 4)
                    }
                }
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("\(viewModel.greetingText), \(viewModel.studentName)")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(.white)

                Text("\(viewModel.careerPath) \u{00B7} Grade \(viewModel.grade)")
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

    // MARK: - Section 1: Welcome + Progress Card

    private var welcomeProgressCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                // Progress row
                HStack(spacing: LadderSpacing.lg) {
                    CircularProgressView(
                        progress: viewModel.checklistProgress,
                        label: "\(Int(viewModel.checklistProgress * 100))%",
                        sublabel: "Complete",
                        size: 72
                    )

                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Your Progress")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("\(viewModel.completedTasks) of \(viewModel.totalTasks) tasks done")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()
                }

                // Next Up row
                Button {
                    coordinator.navigate(to: .activityChecklist)
                } label: {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.accentLime)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("NEXT UP")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            Text(viewModel.nextTaskTitle)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(LadderColors.outlineVariant)
                    }
                    .padding(LadderSpacing.sm)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Section 2: Your Actions This Week

    private var actionsThisWeek: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("YOUR ACTIONS THIS WEEK")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: LadderSpacing.xs) {
                ForEach(viewModel.gradeActions) { action in
                    actionCard(action)
                }
            }
        }
    }

    private func actionCard(_ action: DashboardAction) -> some View {
        Button {
            coordinator.navigate(to: action.route)
        } label: {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                        .fill(LadderColors.primaryContainer.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: action.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(action.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(action.subtitle)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(LadderColors.outlineVariant)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section 3: Upcoming Deadlines

    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("UPCOMING DEADLINES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            if viewModel.upcomingDeadlines.isEmpty {
                HStack(spacing: LadderSpacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.accentLime)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("No upcoming deadlines")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Add colleges to track their deadlines")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            } else {
                VStack(spacing: LadderSpacing.xs) {
                    ForEach(viewModel.upcomingDeadlines) { deadline in
                        deadlineRow(deadline)
                    }
                }

                Button {
                    coordinator.navigate(to: .deadlinesCalendar)
                } label: {
                    HStack {
                        Spacer()
                        Text("See All Deadlines")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundStyle(LadderColors.primary)
                        Spacer()
                    }
                    .padding(.vertical, LadderSpacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Junior Year Major Prompt

    private var majorPromptBanner: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.accentLime)

                    Text("You're in 11th grade \u{2014} time to pick your major direction")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                }

                Text("Colleges you'll apply to this fall care about this.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                Button {
                    coordinator.navigate(to: .careerExplorer)
                } label: {
                    HStack(spacing: LadderSpacing.xs) {
                        Text("Choose My Major")
                            .font(LadderTypography.titleSmall)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, LadderSpacing.lg)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(LadderColors.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                .fill(LadderColors.primaryContainer.opacity(0.25))
        )
    }

    private func deadlineRow(_ deadline: DashboardDeadline) -> some View {
        HStack(spacing: LadderSpacing.md) {
            // Urgency indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(deadline.daysRemaining <= 7 ? LadderColors.error : deadline.daysRemaining <= 30 ? Color.orange : LadderColors.primary)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(deadline.collegeName)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(1)
                Text(deadline.deadlineType)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(deadline.daysRemaining)d")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(deadline.daysRemaining <= 7 ? LadderColors.error : LadderColors.onSurface)
                Text(deadline.dateFormatted)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .environment(AppCoordinator())
}
