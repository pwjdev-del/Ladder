import SwiftUI
import SwiftData

// MARK: - Tasks Tab Root View

struct TasksView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]
    @State private var viewModel = TasksViewModel()
    @State private var showCompleted = false
    @State private var selectedTaskId: UUID?

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .navigationBarHidden(sizeClass != .regular)
        .navigationTitle(sizeClass == .regular ? "Tasks" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTasks(for: profiles.first?.grade ?? 10)
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
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
    }

    // MARK: - iPad Layout (Master-Detail)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(spacing: 0) {
                masterColumn
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .background(LadderColors.surface)

                Rectangle()
                    .fill(LadderColors.outlineVariant)
                    .frame(width: 1)
                    .ignoresSafeArea()

                detailColumn
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .background(LadderColors.surfaceContainerLow.opacity(0.4))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if selectedTaskId == nil {
                selectedTaskId = viewModel.pendingTasks.first?.id ?? viewModel.tasks.first?.id
            }
        }
    }

    private var masterColumn: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                    .frame(maxWidth: .infinity)

                filterChips

                iPadTasksList
            }
            .padding(.bottom, LadderSpacing.xxxl)
        }
    }

    private var iPadTasksList: some View {
        VStack(spacing: LadderSpacing.md) {
            if !viewModel.pendingTasks.isEmpty {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("TO DO")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.md)

                    ForEach(viewModel.pendingTasks) { task in
                        iPadTaskRow(task: task)
                    }
                }
            }

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
                            iPadTaskRow(task: task)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    private func iPadTaskRow(task: TaskItem) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTaskId = task.id
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.toggleTask(task)
                    }
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(task.isCompleted ? LadderColors.accentLime : LadderColors.outline)
                }
                .buttonStyle(.plain)

                Image(systemName: task.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(task.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.primary)
                    .frame(width: 32, height: 32)
                    .background(
                        task.isCompleted
                            ? LadderColors.surfaceContainerHighest
                            : LadderColors.primaryContainer.opacity(0.3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(task.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(task.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                        .strikethrough(task.isCompleted)
                        .lineLimit(1)

                    if let due = task.dueDateFormatted {
                        Text(due)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(task.isOverdue ? LadderColors.error : LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()

                if !task.isCompleted && task.priority == .high {
                    Circle()
                        .fill(LadderColors.error)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(LadderSpacing.md)
            .background(
                selectedTaskId == task.id
                    ? LadderColors.primaryContainer.opacity(0.35)
                    : LadderColors.surfaceContainerLow
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .strokeBorder(
                        selectedTaskId == task.id ? LadderColors.primary : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .opacity(task.isCompleted ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var detailColumn: some View {
        Group {
            if let selected = viewModel.tasks.first(where: { $0.id == selectedTaskId }) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            HStack(spacing: LadderSpacing.sm) {
                                LadderTagChip(selected.category, icon: selected.icon)
                                if let due = selected.dueDateFormatted {
                                    Text(due)
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(selected.isOverdue ? LadderColors.error : LadderColors.onSurfaceVariant)
                                }
                                Spacer()
                                if selected.priority == .high {
                                    LadderTagChip("High Priority", icon: "exclamationmark.triangle")
                                }
                            }

                            Text(selected.title)
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .strikethrough(selected.isCompleted)

                            if let description = selected.description {
                                Text(description)
                                    .font(LadderTypography.bodyLarge)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }

                        LadderPrimaryButton(
                            selected.isCompleted ? "Mark Incomplete" : "Mark Complete",
                            icon: selected.isCompleted ? "arrow.uturn.left" : "checkmark"
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleTask(selected)
                            }
                        }

                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("CHECKLIST")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .labelTracking()

                                ForEach(detailChecklist(for: selected), id: \.self) { step in
                                    HStack(spacing: LadderSpacing.sm) {
                                        Image(systemName: "circle")
                                            .font(.system(size: 16))
                                            .foregroundStyle(LadderColors.outline)
                                        Text(step)
                                            .font(LadderTypography.bodyMedium)
                                            .foregroundStyle(LadderColors.onSurface)
                                        Spacer()
                                    }
                                    .padding(.vertical, LadderSpacing.xxs)
                                }
                            }
                        }

                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("ATTACHMENTS")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .labelTracking()

                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 14))
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Text("No attachments yet")
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Spacer()
                                }
                                .padding(.vertical, LadderSpacing.xs)
                            }
                        }

                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                HStack(spacing: LadderSpacing.xs) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12))
                                        .foregroundStyle(LadderColors.accentLime)
                                    Text("AI TIPS")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                        .labelTracking()
                                }

                                Text(aiTip(for: selected))
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                        }

                        Spacer(minLength: LadderSpacing.xxxl)
                    }
                    .padding(LadderSpacing.xl)
                }
            } else {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "checklist")
                        .font(.system(size: 48))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("Select a task")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("Choose a task from the list to view details, checklist, and AI tips.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LadderSpacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func detailChecklist(for task: TaskItem) -> [String] {
        [
            "Review requirements and deadlines",
            "Gather required materials",
            "Complete the main task",
            "Double-check before submitting"
        ]
    }

    private func aiTip(for task: TaskItem) -> String {
        "Break this task into 20-minute focus blocks. Start with the most specific step — momentum builds from small wins."
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
