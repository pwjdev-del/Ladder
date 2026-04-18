import SwiftUI
import SwiftData

// MARK: - Deadline Heatmap Calendar View
// A month-view calendar where each day is color-coded by deadline density.
// Distinct from DeadlinesCalendarView (which is a simple list).

struct DeadlineHeatmapView: View {

    @Environment(\.modelContext) private var context
    @Query private var deadlines: [CollegeDeadlineModel]
    @State private var viewModel = DeadlineHeatmapViewModel()

    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    /// Deadlines filtered by "My Colleges Only" toggle
    private var visibleDeadlines: [CollegeDeadlineModel] {
        guard viewModel.myCollegesOnly else { return deadlines }
        let savedIds = viewModel.savedCollegeIds
        guard !savedIds.isEmpty else { return deadlines }
        return deadlines.filter { deadline in
            guard let college = deadline.college else { return false }
            let collegeId = college.supabaseId ?? (college.scorecardId.map { String($0) } ?? college.name)
            return savedIds.contains(collegeId)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                monthNavigationHeader
                myCollegesToggle
                filterChips
                weekdayHeaders
                calendarGrid
                legend

                if let selected = viewModel.selectedDate {
                    deadlinePanel(for: selected)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(LadderColors.surface)
        .navigationTitle("Deadline Heatmap")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedDate)
        .onAppear {
            viewModel.loadSavedCollegeIds(context: context)
        }
    }

    // MARK: - My Colleges Only Toggle

    private var myCollegesToggle: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: viewModel.myCollegesOnly ? "bookmark.fill" : "bookmark")
                .font(.system(size: 14))
                .foregroundStyle(viewModel.myCollegesOnly ? LadderColors.primary : LadderColors.onSurfaceVariant)

            Text("My Colleges Only")
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurface)

            Spacer()

            Toggle("", isOn: $viewModel.myCollegesOnly)
                .labelsHidden()
                .tint(LadderColors.primary)
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderSpacing.md, style: .continuous))
    }

    // MARK: - Month Navigation

    private var monthNavigationHeader: some View {
        HStack {
            Button {
                viewModel.goToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(viewModel.monthTitle)
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)

            Spacer()

            Button {
                viewModel.goToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DeadlineHeatmapViewModel.DeadlineFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                            viewModel.selectedDate = nil
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(
                                viewModel.selectedFilter == filter
                                    ? LadderColors.onPrimary
                                    : LadderColors.onSurface
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(
                                    viewModel.selectedFilter == filter
                                        ? LadderColors.primary
                                        : LadderColors.surfaceContainerHigh
                                )
                            )
                    }
                }
            }
        }
    }

    // MARK: - Weekday Headers

    private var weekdayHeaders: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = viewModel.calendarDays()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear
                        .frame(height: 48)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let count = viewModel.deadlineCount(for: date, from: visibleDeadlines)
        let isSelected = viewModel.isSelected(date)
        let isToday = viewModel.isToday(date)

        return Button {
            viewModel.selectDate(date)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.heatmapColor(for: count))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isSelected
                                    ? LadderColors.primary
                                    : (isToday ? LadderColors.accentLime : Color.clear),
                                lineWidth: isSelected ? 2.5 : (isToday ? 1.5 : 0)
                            )
                    )

                VStack(spacing: 2) {
                    Text(viewModel.dayNumber(date))
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(
                            count > 0 ? LadderColors.onSurface : LadderColors.onSurfaceVariant
                        )

                    if count > 0 {
                        Text("\(count)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }
            .frame(height: 48)
        }
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: .clear, border: true, label: "None")
            legendItem(color: viewModel.heatmapColor(for: 1), label: "1")
            legendItem(color: viewModel.heatmapColor(for: 2), label: "2-3")
            legendItem(color: viewModel.heatmapColor(for: 4), label: "4+")
        }
        .padding(.vertical, 8)
    }

    private func legendItem(color: Color, border: Bool = false, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .overlay(
                    border
                        ? RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(LadderColors.outlineVariant, lineWidth: 1)
                        : nil
                )
                .frame(width: 16, height: 16)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Deadline Panel (slide-up)

    private func deadlinePanel(for date: Date) -> some View {
        let dayDeadlines = viewModel.deadlinesForDate(date, from: visibleDeadlines)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"

        return VStack(alignment: .leading, spacing: 12) {
            Text(formatter.string(from: date))
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
                .padding(.bottom, 4)

            if dayDeadlines.isEmpty {
                Text("No deadlines on this day")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(dayDeadlines, id: \.id) { deadline in
                    deadlineRow(deadline)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LadderColors.surfaceContainerLow)
        )
    }

    private func deadlineRow(_ deadline: CollegeDeadlineModel) -> some View {
        let collegeName = deadline.college?.name ?? "Unknown College"
        let websiteURL = deadline.college?.websiteURL
        let calId = viewModel.calendarIdFor(deadline)
        let isAdded = viewModel.calendarAddedIds.contains(calId)

        return HStack(spacing: 12) {
            // College logo with gradient fallback
            CollegeLogoView(collegeName, websiteURL: websiteURL, size: 40, cornerRadius: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(collegeName)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(1)

                // Deadline type chip
                Text(viewModel.chipLabel(for: deadline.deadlineType))
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(viewModel.chipColor(for: deadline.deadlineType))
                    )
            }

            Spacer()

            // Add to Calendar button
            Button {
                Task {
                    await viewModel.addToCalendar(deadline: deadline)
                }
            } label: {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "calendar.badge.plus")
                    .font(.title3)
                    .foregroundStyle(isAdded ? LadderColors.primary : LadderColors.onSurfaceVariant)
            }
            .disabled(isAdded)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LadderColors.surfaceContainer)
        )
    }
}

#Preview {
    NavigationStack {
        DeadlineHeatmapView()
            .modelContainer(for: [CollegeModel.self, CollegeDeadlineModel.self], inMemory: true)
    }
}
