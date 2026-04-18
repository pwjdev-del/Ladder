import SwiftUI
import SwiftData

// MARK: - First 100 Days View
// Guides accepted students through their first college semester milestones

struct First100DaysView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel = First100DaysViewModel()
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerCard
                    dayCounter
                    progressOverview

                    ForEach(viewModel.milestones) { phase in
                        phaseSection(phase)
                    }

                    shareButton
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
                Text("First 100 Days")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task {
            viewModel.loadData(context: context)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LadderColors.accentLime)
                    Spacer()
                }

                Text("First 100 Days at \(viewModel.collegeName)")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Track your transition milestones and make the most of your first semester")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Day Counter

    private var dayCounter: some View {
        LadderCard {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Day \(viewModel.currentDay) of 100")
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    if let phase = viewModel.currentPhase {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: phase.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(phase.color)
                            Text(phase.title)
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(phase.color)
                        }
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xs)
                        .background(phase.color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }

                Spacer()

                // Day progress ring
                CircularProgressView(
                    progress: Double(viewModel.currentDay) / 100.0,
                    label: "\(viewModel.currentDay)",
                    sublabel: "of 100",
                    size: 72
                )
            }
        }
    }

    // MARK: - Progress Overview

    private var progressOverview: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text("Overall Progress")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text("\(viewModel.completedCount)/\(viewModel.totalCount)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                LinearProgressBar(progress: viewModel.overallProgress)

                if viewModel.overallProgress >= 1.0 {
                    Text("You completed all milestones! Amazing start to college life.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.accentLime)
                }
            }
        }
    }

    // MARK: - Phase Section

    private func phaseSection(_ phase: MilestonePhase) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            // Phase header
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: phase.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(phase.color)
                    .frame(width: 32, height: 32)
                    .background(phase.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(phase.title)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        Text("\(phase.completedCount)/\(phase.items.count)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Text(phase.dayRange)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            Text(phase.subtitle)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            // Milestone items
            ForEach(phase.items) { item in
                milestoneRow(item, phase: phase)
            }
        }
    }

    private func milestoneRow(_ item: MilestoneItem, phase: MilestonePhase) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleItem(phaseId: phase.id, itemId: item.id)
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.isCompleted ? LadderColors.accentLime : LadderColors.outline)

                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(phase.color)
                    .frame(width: 32, height: 32)
                    .background(phase.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                Text(item.title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(item.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                    .strikethrough(item.isCompleted)

                Spacer()
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .opacity(item.isCompleted ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            shareProgress()
        } label: {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                Text("Share My Progress")
                    .font(LadderTypography.labelLarge)
            }
            .foregroundStyle(LadderColors.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func shareProgress() {
        let text = "Day \(viewModel.currentDay) of my first 100 days at \(viewModel.collegeName)! \(viewModel.completedCount)/\(viewModel.totalCount) milestones completed. Tracked with Ladder."
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        First100DaysView()
            .environment(AppCoordinator())
    }
    .modelContainer(for: [ApplicationModel.self, StudentProfileModel.self])
}
