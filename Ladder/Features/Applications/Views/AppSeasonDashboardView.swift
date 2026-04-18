import SwiftUI
import SwiftData

// MARK: - App Season Dashboard View
// Transforms the experience for 12th graders during application season (Sep–Jan)

struct AppSeasonDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = AppSeasonDashboardViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerSection
                    progressRing
                    quickActionGrid
                    statusBreakdown
                    urgencyList
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Application Season")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task {
            viewModel.loadData(context: context)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.error)
                    Text("Application Season")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                }

                HStack(spacing: 0) {
                    Rectangle().fill(LadderColors.outlineVariant.opacity(0.4)).frame(height: 1)
                }

                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.error)
                    Text("\(viewModel.daysUntilRD) days until Regular Decision deadlines")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        LadderCard {
            HStack(spacing: LadderSpacing.xl) {
                CircularProgressView(
                    progress: viewModel.submissionProgress,
                    label: "\(viewModel.submittedCount)/\(viewModel.totalCount)",
                    sublabel: "Submitted",
                    size: 90
                )

                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Submission Progress")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    if viewModel.totalCount == 0 {
                        Text("Add applications to track your progress")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    } else if viewModel.submittedCount == viewModel.totalCount {
                        Text("All applications submitted!")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.accentLime)
                    } else {
                        Text("\(viewModel.totalCount - viewModel.submittedCount) remaining")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Quick Action Grid

    private var quickActionGrid: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("QUICK ACTIONS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: LadderSpacing.sm),
                GridItem(.flexible(), spacing: LadderSpacing.sm),
            ], spacing: LadderSpacing.sm) {
                ForEach(viewModel.quickActions) { action in
                    Button {
                        coordinator.navigate(to: action.route)
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: action.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(LadderColors.primary)
                                .frame(width: 36, height: 36)
                                .background(LadderColors.primaryContainer.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                            Text(action.title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(LadderSpacing.md)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Status Breakdown

    private var statusBreakdown: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Status Breakdown")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                HStack(spacing: LadderSpacing.md) {
                    statusChip("Not Started", count: viewModel.notStartedCount, color: LadderColors.error)
                    statusChip("In Progress", count: viewModel.inProgressCount, color: Color(red: 0.75, green: 0.60, blue: 0.10))
                    statusChip("Submitted", count: viewModel.submittedStatusCount, color: LadderColors.primary)
                    statusChip("Decided", count: viewModel.decidedCount, color: Color(red: 0.15, green: 0.50, blue: 0.70))
                }
            }
        }
    }

    private func statusChip(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Text("\(count)")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(color)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.sm)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
    }

    // MARK: - Urgency List

    private var urgencyList: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("UPCOMING DEADLINES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            if viewModel.urgencyList.isEmpty {
                LadderCard {
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LadderColors.accentLime)
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text("All caught up!")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("No pending application deadlines")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                    }
                }
            } else {
                ForEach(viewModel.urgencyList) { app in
                    urgencyRow(app)
                }
            }
        }
    }

    private func urgencyRow(_ app: ApplicationModel) -> some View {
        Button {
            if let id = app.supabaseId ?? app.collegeId {
                coordinator.navigate(to: .applicationDetail(applicationId: id))
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                // Deadline countdown badge
                if let days = viewModel.daysUntilDeadline(for: app) {
                    VStack(spacing: 2) {
                        Text("\(days)")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(days <= 7 ? LadderColors.error : days <= 30 ? Color(red: 0.75, green: 0.60, blue: 0.10) : LadderColors.primary)
                        Text("days")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(width: 52)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(app.collegeName)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(1)

                    HStack(spacing: LadderSpacing.xs) {
                        if let type = app.deadlineType {
                            Text(type)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        Text(viewModel.statusLabel(for: app.status))
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(viewModel.statusColor(for: app.status))
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(viewModel.statusColor(for: app.status).opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.md)
            .background(
                viewModel.daysUntilDeadline(for: app).map { $0 <= 7 } == true
                    ? LadderColors.error.opacity(0.06)
                    : LadderColors.surfaceContainerLow
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AppSeasonDashboardView()
            .environment(AppCoordinator())
    }
    .modelContainer(for: [ApplicationModel.self, StudentProfileModel.self])
}
