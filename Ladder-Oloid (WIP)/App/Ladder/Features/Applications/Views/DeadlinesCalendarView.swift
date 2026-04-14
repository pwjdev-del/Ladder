import SwiftUI

// MARK: - Deadlines Calendar View

struct DeadlinesCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay: Int?

    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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
                Text("Deadlines")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    monthSelector
                    upcomingDeadlines
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout (Month Grid + Side Panel)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(alignment: .top, spacing: 0) {
                // Left: month grid (~70%)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                        monthSelector
                        monthGridHeatmap
                    }
                    .padding(LadderSpacing.xl)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(LadderColors.outlineVariant)
                    .frame(width: 1)
                    .ignoresSafeArea()

                // Right: selected day deadlines (~30%)
                selectedDayPanel
                    .frame(width: 360)
                    .frame(maxHeight: .infinity)
                    .background(LadderColors.surfaceContainerLow.opacity(0.4))
            }
        }
    }

    private var monthGridHeatmap: some View {
        let daysInMonth = daysIn(month: selectedMonth)
        let firstWeekday = firstWeekdayOf(month: selectedMonth) // 1 = Sun
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let columns = Array(repeating: GridItem(.flexible(), spacing: LadderSpacing.sm), count: 7)
        let monthDeadlines = deadlinesForMonth(selectedMonth)
        let maxCount: Int = max(1, monthDeadlines.reduce(into: [Int: Int]()) { acc, d in
            acc[d.day, default: 0] += 1
        }.values.max() ?? 1)

        return VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("\(fullMonthName(selectedMonth).uppercased()) \(String(currentYear))")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            LazyVGrid(columns: columns, spacing: LadderSpacing.sm) {
                ForEach(weekdays, id: \.self) { wd in
                    Text(wd)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.xs)
                }

                // Leading blanks
                ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                    Color.clear.frame(height: 72)
                }

                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let count = monthDeadlines.filter { $0.day == day }.count
                    dayCell(day: day, count: count, maxCount: maxCount)
                }
            }
        }
    }

    private func dayCell(day: Int, count: Int, maxCount: Int) -> some View {
        let intensity: Double = count == 0 ? 0.0 : max(0.2, min(1.0, Double(count) / Double(maxCount)))
        let isSelected = selectedDay == day

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedDay = day
            }
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text("\(day)")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(count > 0 && intensity > 0.55 ? .white : LadderColors.onSurface)

                Spacer(minLength: 0)

                if count > 0 {
                    Text("\(count)")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(intensity > 0.55 ? .white.opacity(0.9) : LadderColors.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 72)
            .padding(LadderSpacing.sm)
            .background(
                Group {
                    if count > 0 {
                        LadderColors.primary.opacity(intensity)
                    } else {
                        LadderColors.surfaceContainerLow
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                    .strokeBorder(
                        isSelected ? LadderColors.accentLime : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var selectedDayPanel: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                if let day = selectedDay {
                    Text("\(fullMonthName(selectedMonth).uppercased()) \(day)")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    Text("\(day) \(fullMonthName(selectedMonth))")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    let dayDeadlines = deadlinesForMonth(selectedMonth).filter { $0.day == day }

                    if dayDeadlines.isEmpty {
                        VStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 32))
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            Text("No deadlines on this day")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.xxxl)
                    } else {
                        ForEach(dayDeadlines) { deadline in
                            deadlineCard(deadline)
                        }
                    }
                } else {
                    Text("SELECT A DAY")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    Text("Tap a day in the calendar to view deadlines")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Divider()
                        .padding(.vertical, LadderSpacing.sm)

                    Text("\(fullMonthName(selectedMonth).uppercased()) DEADLINES")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    let allDeadlines = deadlinesForMonth(selectedMonth)
                    if allDeadlines.isEmpty {
                        Text("No deadlines this month")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    } else {
                        ForEach(allDeadlines) { deadline in
                            deadlineCard(deadline)
                        }
                    }
                }
            }
            .padding(LadderSpacing.lg)
        }
    }

    private func fullMonthName(_ month: Int) -> String {
        let names = ["January", "February", "March", "April", "May", "June",
                     "July", "August", "September", "October", "November", "December"]
        guard month >= 1 && month <= 12 else { return "" }
        return names[month - 1]
    }

    private func daysIn(month: Int) -> Int {
        let components = DateComponents(year: currentYear, month: month)
        let calendar = Calendar.current
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 30
        }
        return range.count
    }

    private func firstWeekdayOf(month: Int) -> Int {
        let components = DateComponents(year: currentYear, month: month, day: 1)
        guard let date = Calendar.current.date(from: components) else { return 1 }
        return Calendar.current.component(.weekday, from: date)
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(Array(months.enumerated()), id: \.offset) { index, month in
                    let monthNum = index + 1
                    let hasDeadlines = deadlinesForMonth(monthNum).count > 0
                    Button {
                        withAnimation { selectedMonth = monthNum }
                    } label: {
                        VStack(spacing: LadderSpacing.xs) {
                            Text(month)
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(selectedMonth == monthNum ? .white : LadderColors.onSurfaceVariant)

                            if hasDeadlines {
                                Circle()
                                    .fill(selectedMonth == monthNum ? .white : LadderColors.accentLime)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .background(selectedMonth == monthNum ? LadderColors.primary : LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Upcoming Deadlines

    private var upcomingDeadlines: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("\(months[selectedMonth - 1].uppercased()) DEADLINES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            let deadlines = deadlinesForMonth(selectedMonth)
            if deadlines.isEmpty {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Text("No deadlines this month")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.xxxxl)
            } else {
                ForEach(deadlines) { deadline in
                    deadlineCard(deadline)
                }
            }
        }
    }

    private func deadlineCard(_ deadline: DeadlineItem) -> some View {
        Button {
            coordinator.navigate(to: .applicationDetail(applicationId: deadline.collegeId))
        } label: {
            HStack(spacing: LadderSpacing.md) {
                // Date column
                VStack(spacing: 2) {
                    Text(deadline.dayString)
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(deadline.isUrgent ? LadderColors.error : LadderColors.primary)

                    Text(deadline.weekday)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .frame(width: 48)

                Rectangle()
                    .fill(deadline.isUrgent ? LadderColors.error : LadderColors.primaryContainer)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(deadline.collegeName)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(deadline.type)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    HStack(spacing: LadderSpacing.sm) {
                        LadderTagChip(deadline.platform)
                        if deadline.isUrgent {
                            LadderTagChip("Urgent", icon: "exclamationmark.triangle")
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mock Data

    private func deadlinesForMonth(_ month: Int) -> [DeadlineItem] {
        let all: [DeadlineItem] = [
            DeadlineItem(collegeName: "SAT Registration", type: "Test Registration", platform: "College Board", collegeId: "sat", month: 4, day: 15, isUrgent: true),
            DeadlineItem(collegeName: "FAFSA Opens", type: "Financial Aid", platform: "studentaid.gov", collegeId: "fafsa", month: 10, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "University of Florida", type: "Early Action", platform: "Common App", collegeId: "uf", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Florida State University", type: "Early Action", platform: "Common App", collegeId: "fsu", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Emory University", type: "Early Decision", platform: "Common App", collegeId: "emory", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Georgia Tech", type: "Early Action", platform: "Common App", collegeId: "gatech", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Rochester Institute of Technology", type: "Early Decision", platform: "Common App", collegeId: "rit", month: 11, day: 15, isUrgent: false),
            DeadlineItem(collegeName: "University of Florida", type: "Regular Decision", platform: "Common App", collegeId: "uf", month: 1, day: 15, isUrgent: false),
            DeadlineItem(collegeName: "Georgia Tech", type: "Regular Decision", platform: "Common App", collegeId: "gatech", month: 1, day: 4, isUrgent: false),
            DeadlineItem(collegeName: "Emory University", type: "Regular Decision", platform: "Common App", collegeId: "emory", month: 1, day: 15, isUrgent: false),
            DeadlineItem(collegeName: "National Decision Day", type: "Commitment Deadline", platform: "All Schools", collegeId: "ndd", month: 5, day: 1, isUrgent: false),
        ]
        return all.filter { $0.month == month }.sorted { $0.day < $1.day }
    }
}

// MARK: - Deadline Item

struct DeadlineItem: Identifiable {
    let id = UUID()
    let collegeName: String
    let type: String
    let platform: String
    let collegeId: String
    let month: Int
    let day: Int
    let isUrgent: Bool

    var dayString: String { "\(day)" }
    var weekday: String {
        let year = Calendar.current.component(.year, from: Date())
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar.current.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DeadlinesCalendarView()
            .environment(AppCoordinator())
    }
}
