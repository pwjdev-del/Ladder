import SwiftUI
import SwiftData

// MARK: - Activities Portfolio View
// Main hub showing all extracurricular activities grouped by category.
// Includes a "Your Activity Goals" section (4 general + 6 career-specific).

struct ActivitiesPortfolioView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ActivitiesPortfolioViewModel()
    @State private var goalSheetSuggestion: ActivitySuggestionEngine.ActivitySuggestion?
    @State private var showGoalAddSheet = false
    @State private var expandedGoalId: UUID?

    private let engine = ActivitySuggestionEngine.shared

    private var careerPath: String {
        viewModel.studentProfile?.careerPath ?? ""
    }

    private var allGoals: [ActivitySuggestionEngine.ActivitySuggestion] {
        engine.allSuggestions(for: careerPath)
    }

    private var startedGoalCount: Int {
        allGoals.filter { isGoalStarted($0) }.count
    }

    private func isGoalStarted(_ suggestion: ActivitySuggestionEngine.ActivitySuggestion) -> Bool {
        viewModel.activities.contains { activity in
            activity.category == suggestion.category &&
            (activity.name.localizedCaseInsensitiveContains(suggestion.name) ||
             suggestion.name.localizedCaseInsensitiveContains(activity.name) ||
             activity.category == suggestion.category)
        }
    }

    /// More precise match: checks if there is a logged activity whose category
    /// matches AND whose name shares keywords with the suggestion name.
    private func hasMatchingActivity(for suggestion: ActivitySuggestionEngine.ActivitySuggestion) -> Bool {
        let suggestionWords = Set(suggestion.name.lowercased().split(separator: " ").map(String.init))
        return viewModel.activities.contains { activity in
            guard activity.category == suggestion.category else { return false }
            let activityWords = Set(activity.name.lowercased().split(separator: " ").map(String.init))
            // At least one meaningful word in common, or exact category match for general goals
            let common = suggestionWords.intersection(activityWords)
            return !common.isEmpty || suggestion.isGeneral
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Activity Goals (4 general + 6 career-specific)
                    activityGoalsSection

                    // Stats summary
                    statsSection

                    // Filter chips
                    filterChipsSection

                    // Activities list
                    if viewModel.filteredActivities.isEmpty {
                        emptyState
                    } else {
                        activitiesListSection
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }

            // FAB
            addButton
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Activities Portfolio")
                    .font(LadderTypography.titleSmall)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { viewModel.showingExportSheet = true } label: {
                    Image(systemName: "doc.text")
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            viewModel.fetchAll()
        } content: {
            AddActivityView(modelContext: modelContext)
        }
        .sheet(item: $viewModel.editingActivity, onDismiss: {
            viewModel.fetchAll()
        }) { activity in
            AddActivityView(modelContext: modelContext, activity: activity)
        }
        .sheet(isPresented: $showGoalAddSheet, onDismiss: {
            viewModel.fetchAll()
        }) {
            if let suggestion = goalSheetSuggestion {
                AddActivityView(
                    modelContext: modelContext,
                    prefillCategory: suggestion.category,
                    prefillName: suggestion.name
                )
            }
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            CommonAppExportView(activities: viewModel.activities)
        }
    }

    // MARK: - Activity Goals Section

    private var activityGoalsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text("Your Activity Goals")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("\(startedGoalCount)/\(allGoals.count) started")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(LadderColors.surfaceContainerHighest, lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: allGoals.isEmpty ? 0 : CGFloat(startedGoalCount) / CGFloat(allGoals.count))
                        .stroke(LadderColors.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 36, height: 36)
            }

            // General activities header
            Text("ESSENTIALS FOR EVERY STUDENT")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .padding(.top, LadderSpacing.xs)

            // 4 General goals
            ForEach(engine.generalActivities) { suggestion in
                goalCard(suggestion)
            }

            // Career-specific header
            if !careerPath.isEmpty {
                Text("\(careerPath.uppercased()) PATH ACTIVITIES")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.top, LadderSpacing.sm)
            } else {
                Text("CAREER-SPECIFIC ACTIVITIES")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.top, LadderSpacing.sm)
            }

            // 6 Career-specific goals
            ForEach(engine.careerActivities(for: careerPath)) { suggestion in
                goalCard(suggestion)
            }
        }
    }

    // MARK: - Goal Card

    private func goalCard(_ suggestion: ActivitySuggestionEngine.ActivitySuggestion) -> some View {
        let started = hasMatchingActivity(for: suggestion)
        let isExpanded = expandedGoalId == suggestion.id

        return Button {
            if started {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedGoalId = isExpanded ? nil : suggestion.id
                }
            } else {
                goalSheetSuggestion = suggestion
                showGoalAddSheet = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: LadderSpacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderSpacing.sm)
                            .fill(started ? LadderColors.primary.opacity(0.15) : LadderColors.surfaceContainerHigh)
                            .frame(width: 40, height: 40)
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(started ? LadderColors.primary : LadderColors.onSurfaceVariant)
                    }

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(suggestion.name)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineLimit(1)

                        Text(suggestion.description)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    Spacer()

                    // Status indicator
                    if started {
                        HStack(spacing: LadderSpacing.xxs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Started")
                                .font(LadderTypography.labelSmall)
                        }
                        .foregroundStyle(LadderColors.primary)
                    } else {
                        Text("Not Started")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                .padding(LadderSpacing.md)

                // Expanded detail section
                if isExpanded {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        goalDetailRow(label: "Why it matters", text: suggestion.whyItMatters)
                        goalDetailRow(label: "How to start", text: suggestion.howToStart)

                        if let hours = suggestion.targetHours {
                            HStack(spacing: LadderSpacing.xs) {
                                Image(systemName: "target")
                                    .font(.system(size: 12))
                                    .foregroundStyle(LadderColors.tertiary)
                                Text("Target: \(hours) hours")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.tertiary)
                            }
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.bottom, LadderSpacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderSpacing.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func goalDetailRow(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
            Text(label.uppercased())
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text(text)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: LadderSpacing.md) {
            statCard(
                value: "\(viewModel.activities.count)",
                label: "Activities",
                icon: "list.bullet",
                color: LadderColors.primary
            )
            statCard(
                value: "\(Int(viewModel.totalHours))",
                label: "Total Hours",
                icon: "clock.fill",
                color: LadderColors.tertiary
            )
            statCard(
                value: "\(viewModel.leadershipCount)",
                label: "Leadership",
                icon: "star.fill",
                color: LadderColors.secondary
            )
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        LadderCard {
            VStack(spacing: LadderSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                Text(value)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(label)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Filter Chips

    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(viewModel.categoriesWithCounts, id: \.0) { category, count in
                    LadderFilterChip(
                        title: "\(category) (\(count))",
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    // MARK: - Activities List

    private var activitiesListSection: some View {
        LazyVStack(spacing: LadderSpacing.lg) {
            ForEach(viewModel.groupedActivities, id: \.0) { category, items in
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    // Section header
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: ActivityModel.categoryIcons[category] ?? "folder.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)
                        Text(category)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        Text("\(items.count)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    ForEach(items) { activity in
                        activityCard(activity)
                    }
                }
            }
        }
    }

    // MARK: - Activity Card

    private func activityCard(_ activity: ActivityModel) -> some View {
        Button {
            viewModel.editingActivity = activity
        } label: {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text(activity.name)
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)

                            if let role = activity.role, !role.isEmpty {
                                Text(role)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .lineLimit(1)
                            }

                            if let org = activity.organization, !org.isEmpty {
                                Text(org)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: LadderSpacing.xs) {
                            tierBadge(activity.tier)

                            if activity.isLeadership {
                                HStack(spacing: LadderSpacing.xxs) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                    Text("Leader")
                                        .font(LadderTypography.labelSmall)
                                }
                                .foregroundStyle(LadderColors.secondary)
                            }
                        }
                    }

                    // Bottom row: hours + grades
                    HStack(spacing: LadderSpacing.md) {
                        if let hours = activity.hoursPerWeek, hours > 0 {
                            HStack(spacing: LadderSpacing.xxs) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text("\(Int(hours)) hrs/wk")
                                    .font(LadderTypography.labelSmall)
                            }
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        if let weeks = activity.weeksPerYear, weeks > 0 {
                            HStack(spacing: LadderSpacing.xxs) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                Text("\(Int(weeks)) wks/yr")
                                    .font(LadderTypography.labelSmall)
                            }
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        if !activity.gradeYears.isEmpty {
                            HStack(spacing: LadderSpacing.xxs) {
                                Image(systemName: "graduationcap")
                                    .font(.system(size: 10))
                                Text("Gr \(activity.gradeYearsFormatted)")
                                    .font(LadderTypography.labelSmall)
                            }
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        Spacer()

                        if activity.totalHours > 0 {
                            Text("\(Int(activity.totalHours))h total")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteActivity(activity)
            } label: {
                Label("Delete Activity", systemImage: "trash")
            }
        }
    }

    // MARK: - Tier Badge

    private func tierBadge(_ tier: Int) -> some View {
        let colors: [Int: Color] = [
            1: LadderColors.secondary,
            2: LadderColors.primary,
            3: LadderColors.tertiary,
            4: LadderColors.onSurfaceVariant
        ]
        return Text("T\(tier)")
            .font(LadderTypography.labelSmall)
            .foregroundStyle(.white)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xxs)
            .background(colors[tier] ?? LadderColors.onSurfaceVariant)
            .clipShape(Capsule())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(LadderColors.outlineVariant)
            Text("No activities yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text("Start building your portfolio by adding clubs, sports, jobs, and more.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    // MARK: - Add FAB

    private var addButton: some View {
        Button {
            viewModel.showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .ladderShadow(LadderElevation.primaryGlow)
        }
        .padding(LadderSpacing.lg)
    }
}
