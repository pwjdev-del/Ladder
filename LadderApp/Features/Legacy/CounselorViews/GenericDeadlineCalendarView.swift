import SwiftUI
import SwiftData

// MARK: - Generic Deadline Calendar View
// Reference tool showing ALL college deadlines in a calendar grid.
// No student names — purely a deadline reference for counselors.

struct GenericDeadlineCalendarView: View {
    @Query(sort: \CollegeDeadlineModel.date) private var deadlines: [CollegeDeadlineModel]

    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()
    @State private var selectedFilter: DeadlineFilter = .all

    enum DeadlineFilter: String, CaseIterable {
        case all = "All"
        case earlyDecision = "ED"
        case earlyAction = "EA"
        case regular = "Regular"
        case scholarships = "Scholarships"
        case tests = "Tests"

        var deadlineTypes: [String] {
            switch self {
            case .all: return []
            case .earlyDecision: return ["Early Decision", "Early Decision II"]
            case .earlyAction: return ["Early Action", "Restrictive Early Action"]
            case .regular: return ["Regular Decision", "Rolling"]
            case .scholarships: return ["Scholarship"]
            case .tests: return ["SAT", "ACT", "SAT Subject Test"]
            }
        }
    }

    private var filteredDeadlines: [CollegeDeadlineModel] {
        guard selectedFilter != .all else { return deadlines }
        return deadlines.filter { deadline in
            selectedFilter.deadlineTypes.contains(where: { deadline.deadlineType.contains($0) })
        }
    }

    private var thisMonthCount: Int {
        let calendar = Calendar.current
        return filteredDeadlines.filter { deadline in
            guard let date = deadline.date else { return false }
            return calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        }.count
    }

    private var deadlinesForSelectedDate: [CollegeDeadlineModel] {
        let calendar = Calendar.current
        return filteredDeadlines.filter { deadline in
            guard let date = deadline.date else { return false }
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Deadline Calendar")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("All college deadlines at a glance")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    filterChips
                    monthSummary
                    calendarGrid
                    selectedDateDeadlines
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(DeadlineFilter.allCases, id: \.self) { filter in
                    LadderFilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
        }
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Month Summary

    private var monthSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("This Month")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text("\(thisMonthCount) deadline\(thisMonthCount == 1 ? "" : "s")")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }

            Spacer()

            // Legend
            HStack(spacing: LadderSpacing.md) {
                legendDot(color: .red, label: "ED")
                legendDot(color: .orange, label: "EA")
                legendDot(color: LadderColors.primary, label: "RD")
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: LadderSpacing.md) {
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.primary)
                }

                Spacer()

                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Spacer()

                Button {
                    withAnimation {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.primary)
                }
            }

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: LadderSpacing.sm) {
                ForEach(days, id: \.self) { day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func dayCell(_ date: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dayDeadlines = deadlinesForDate(date)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(
                        isSelected ? .white
                            : isToday ? LadderColors.primary
                            : LadderColors.onSurface
                    )

                // Deadline dots
                HStack(spacing: 2) {
                    ForEach(Array(deadlineDotColors(dayDeadlines).prefix(3).enumerated()), id: \.offset) { _, color in
                        Circle()
                            .fill(color)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                isSelected
                    ? AnyShapeStyle(LadderColors.primary)
                    : isToday
                        ? AnyShapeStyle(LadderColors.primaryContainer.opacity(0.3))
                        : AnyShapeStyle(Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selected Date Deadlines

    private var selectedDateDeadlines: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            if deadlinesForSelectedDate.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 24))
                            .foregroundStyle(LadderColors.outlineVariant)
                        Text("No deadlines on this day")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                }
            } else {
                ForEach(deadlinesForSelectedDate, id: \.self) { deadline in
                    LadderCard {
                        HStack(spacing: LadderSpacing.md) {
                            Circle()
                                .fill(colorForDeadlineType(deadline.deadlineType))
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(deadline.college?.name ?? "Unknown College")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .lineLimit(1)

                                Text(deadline.deadlineType)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            Spacer()

                            if !deadline.applicationPlatforms.isEmpty {
                                Text(deadline.applicationPlatforms.first ?? "")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .padding(.horizontal, LadderSpacing.sm)
                                    .padding(.vertical, 2)
                                    .background(LadderColors.surfaceContainerHighest)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Calendar Helpers

    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - 1

        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)

        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: firstDay) {
                days.append(date)
            }
        }

        // Pad to complete row
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func deadlinesForDate(_ date: Date) -> [CollegeDeadlineModel] {
        let calendar = Calendar.current
        return filteredDeadlines.filter { deadline in
            guard let d = deadline.date else { return false }
            return calendar.isDate(d, inSameDayAs: date)
        }
    }

    private func deadlineDotColors(_ deadlines: [CollegeDeadlineModel]) -> [Color] {
        // Return unique colors for the types present
        var colors: [Color] = []
        var seenTypes: Set<String> = []
        for deadline in deadlines {
            let simplified = simplifiedType(deadline.deadlineType)
            if !seenTypes.contains(simplified) {
                seenTypes.insert(simplified)
                colors.append(colorForDeadlineType(deadline.deadlineType))
            }
        }
        return colors
    }

    private func simplifiedType(_ type: String) -> String {
        if type.contains("Early Decision") { return "ED" }
        if type.contains("Early Action") { return "EA" }
        if type.contains("Regular") || type.contains("Rolling") { return "RD" }
        if type.contains("Scholarship") { return "Scholarship" }
        if type.contains("SAT") || type.contains("ACT") { return "Test" }
        return type
    }

    private func colorForDeadlineType(_ type: String) -> Color {
        if type.contains("Early Decision") { return .red }
        if type.contains("Early Action") { return .orange }
        if type.contains("Regular") || type.contains("Rolling") { return LadderColors.primary }
        if type.contains("Scholarship") { return Color(red: 0.2, green: 0.7, blue: 0.3) }
        if type.contains("SAT") || type.contains("ACT") { return .purple }
        return LadderColors.primary
    }
}
