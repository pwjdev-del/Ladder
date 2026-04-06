import SwiftUI

// MARK: - Tasks Tab Root View

struct TasksView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = TasksViewModel()
    @State private var showCompleted = false

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    filterChips
                    tasksList
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("TASKS & CHECKLIST")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.secondaryFixed)
                .labelTracking()

            Text("Your Tasks")
                .font(LadderTypography.headlineLarge)
                .foregroundStyle(.white)

            // Progress summary
            HStack(spacing: LadderSpacing.lg) {
                CircularProgressView(
                    progress: viewModel.overallProgress,
                    label: "\(Int(viewModel.overallProgress * 100))%",
                    size: 56
                )

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("\(viewModel.tasks.filter(\.isCompleted).count) of \(viewModel.tasks.count) tasks done")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(.white)

                    Text("\(viewModel.pendingTasks.count) remaining")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            // Search bar
            LadderSearchBar(placeholder: "Search tasks...", text: $viewModel.searchText)
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

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(TasksViewModel.TaskFilter.allCases, id: \.self) { filter in
                    LadderFilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, LadderSpacing.md)
        }
        .padding(.top, -LadderSpacing.xl)
        .padding(.bottom, LadderSpacing.md)
    }

    // MARK: - Tasks List

    private var tasksList: some View {
        VStack(spacing: LadderSpacing.md) {
            // Pending tasks
            if !viewModel.pendingTasks.isEmpty {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("TO DO")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.md)

                    ForEach(viewModel.pendingTasks) { task in
                        TaskRowView(task: task) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleTask(task)
                            }
                        }
                    }
                }
            }

            // Completed section (collapsible)
            if !viewModel.completedTasks.isEmpty {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Button {
                        withAnimation { showCompleted.toggle() }
                    } label: {
                        HStack {
                            Text("COMPLETED (\(viewModel.completedTasks.count))")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .padding(.horizontal, LadderSpacing.md)
                    }

                    if showCompleted {
                        ForEach(viewModel.completedTasks) { task in
                            TaskRowView(task: task) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.toggleTask(task)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: LadderSpacing.md) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(task.isCompleted ? LadderColors.accentLime : LadderColors.outline)
            }

            // Icon
            Image(systemName: task.icon)
                .font(.system(size: 16))
                .foregroundStyle(task.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.primary)
                .frame(width: 36, height: 36)
                .background(
                    task.isCompleted
                        ? LadderColors.surfaceContainerHighest
                        : LadderColors.primaryContainer.opacity(0.3)
                )
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

            // Content
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(task.title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(task.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                    .strikethrough(task.isCompleted)

                if let description = task.description, !task.isCompleted {
                    Text(description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .lineLimit(2)
                }

                HStack(spacing: LadderSpacing.sm) {
                    LadderTagChip(task.category)

                    if let due = task.dueDateFormatted {
                        Text(due)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(task.isOverdue ? LadderColors.error : LadderColors.onSurfaceVariant)
                    }
                }
            }

            Spacer()

            // Priority indicator
            if !task.isCompleted && task.priority == .high {
                Circle()
                    .fill(LadderColors.error)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .opacity(task.isCompleted ? 0.7 : 1.0)
    }
}

#Preview {
    TasksView()
        .environment(AppCoordinator())
}
