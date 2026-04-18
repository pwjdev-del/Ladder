import SwiftUI
import SwiftData

// MARK: - Deadline Heatmap ViewModel

@Observable
final class DeadlineHeatmapViewModel {

    var currentMonth: Date = Date()
    var selectedDate: Date?
    var selectedFilter: DeadlineFilter = .all
    var calendarAddedIds: Set<String> = []
    var myCollegesOnly: Bool = true
    var savedCollegeIds: Set<String> = []

    // MARK: - Load Saved College IDs

    func loadSavedCollegeIds(context: ModelContext) {
        let descriptor = FetchDescriptor<StudentProfileModel>()
        if let profile = try? context.fetch(descriptor).first {
            savedCollegeIds = Set(profile.savedCollegeIds)
        }
    }

    // MARK: - Filter

    enum DeadlineFilter: String, CaseIterable {
        case all = "All"
        case earlyDecision = "Early Decision"
        case earlyAction = "Early Action"
        case regular = "Regular"
        case scholarships = "Scholarships"
    }

    // MARK: - Month Navigation

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    func goToPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func goToNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // MARK: - Calendar Grid

    /// Returns the days to display in the calendar grid (includes leading/trailing blanks as nil).
    func calendarDays() -> [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) // 1 = Sunday
        let leadingBlanks = weekdayOfFirst - 1

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in range {
            var dayComponents = components
            dayComponents.day = day
            days.append(calendar.date(from: dayComponents))
        }

        // Pad to fill last row
        let remaining = (7 - (days.count % 7)) % 7
        days += Array(repeating: nil as Date?, count: remaining)

        return days
    }

    // MARK: - Deadline Queries

    func deadlinesForDate(_ date: Date, from allDeadlines: [CollegeDeadlineModel]) -> [CollegeDeadlineModel] {
        let calendar = Calendar.current
        return filteredDeadlines(from: allDeadlines).filter { deadline in
            guard let deadlineDate = deadline.date else { return false }
            return calendar.isDate(deadlineDate, inSameDayAs: date)
        }
    }

    func deadlineCount(for date: Date, from allDeadlines: [CollegeDeadlineModel]) -> Int {
        deadlinesForDate(date, from: allDeadlines).count
    }

    func filteredDeadlines(from allDeadlines: [CollegeDeadlineModel]) -> [CollegeDeadlineModel] {
        switch selectedFilter {
        case .all:
            return allDeadlines
        case .earlyDecision:
            return allDeadlines.filter { $0.deadlineType.localizedCaseInsensitiveContains("Early Decision") }
        case .earlyAction:
            return allDeadlines.filter { $0.deadlineType.localizedCaseInsensitiveContains("Early Action") }
        case .regular:
            return allDeadlines.filter { $0.deadlineType.localizedCaseInsensitiveContains("Regular") }
        case .scholarships:
            return allDeadlines.filter { $0.deadlineType.localizedCaseInsensitiveContains("Scholarship") }
        }
    }

    // MARK: - Heatmap Color

    func heatmapColor(for count: Int) -> Color {
        switch count {
        case 0:
            return .clear
        case 1:
            return Color(red: 0.55, green: 0.78, blue: 0.45).opacity(0.5) // light green
        case 2...3:
            return Color(red: 0.95, green: 0.80, blue: 0.25).opacity(0.6) // yellow
        default:
            return Color(red: 0.90, green: 0.35, blue: 0.20).opacity(0.65) // red/orange
        }
    }

    // MARK: - Helpers

    func selectDate(_ date: Date) {
        if let current = selectedDate, Calendar.current.isDate(current, inSameDayAs: date) {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func isSelected(_ date: Date) -> Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(selected, inSameDayAs: date)
    }

    // MARK: - Calendar Integration

    @MainActor
    func addToCalendar(deadline: CollegeDeadlineModel) async {
        guard let date = deadline.date,
              let collegeName = deadline.college?.name else { return }

        let title = "\(collegeName) - \(deadline.deadlineType)"
        let notes = "Deadline for \(collegeName) (\(deadline.deadlineType))"

        let success = await CalendarManager.shared.addDeadline(
            title: title,
            date: date,
            notes: notes
        )

        if success {
            let id = "\(collegeName)-\(deadline.deadlineType)-\(date.timeIntervalSince1970)"
            calendarAddedIds.insert(id)
        }
    }

    func calendarIdFor(_ deadline: CollegeDeadlineModel) -> String {
        let name = deadline.college?.name ?? ""
        let date = deadline.date ?? Date()
        return "\(name)-\(deadline.deadlineType)-\(date.timeIntervalSince1970)"
    }

    // MARK: - Deterministic Gradient

    func gradientColors(for name: String) -> [Color] {
        let pairs: [(Color, Color)] = [
            (Color(red: 0.26, green: 0.37, blue: 0.25), Color(red: 0.35, green: 0.47, blue: 0.34)),
            (Color(red: 0.15, green: 0.30, blue: 0.45), Color(red: 0.20, green: 0.40, blue: 0.55)),
            (Color(red: 0.45, green: 0.25, blue: 0.12), Color(red: 0.55, green: 0.35, blue: 0.20)),
            (Color(red: 0.35, green: 0.15, blue: 0.35), Color(red: 0.45, green: 0.25, blue: 0.45)),
            (Color(red: 0.50, green: 0.15, blue: 0.15), Color(red: 0.60, green: 0.25, blue: 0.20)),
            (Color(red: 0.20, green: 0.35, blue: 0.35), Color(red: 0.30, green: 0.45, blue: 0.45)),
            (Color(red: 0.30, green: 0.30, blue: 0.15), Color(red: 0.40, green: 0.40, blue: 0.25)),
            (Color(red: 0.25, green: 0.25, blue: 0.40), Color(red: 0.35, green: 0.35, blue: 0.50)),
        ]
        let hash = abs(name.hashValue)
        return [pairs[hash % pairs.count].0, pairs[hash % pairs.count].1]
    }

    func initials(_ name: String) -> String {
        let words = name.split(separator: " ").filter {
            !["of", "the", "and", "at", "in", "for"].contains($0.lowercased())
        }
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    // MARK: - Deadline Type Chip Color

    func chipColor(for type: String) -> Color {
        let lower = type.lowercased()
        if lower.contains("early decision") {
            return Color(red: 0.50, green: 0.15, blue: 0.15) // deep red
        } else if lower.contains("early action") {
            return Color(red: 0.15, green: 0.30, blue: 0.45) // blue
        } else if lower.contains("regular") {
            return LadderColors.primary
        } else if lower.contains("scholarship") {
            return Color(red: 0.45, green: 0.25, blue: 0.12) // amber
        } else {
            return LadderColors.onSurfaceVariant
        }
    }

    func chipLabel(for type: String) -> String {
        let lower = type.lowercased()
        if lower.contains("early decision") { return "ED" }
        if lower.contains("early action") { return "EA" }
        if lower.contains("regular") { return "RD" }
        if lower.contains("scholarship") { return "Scholarship" }
        if lower.contains("rolling") { return "Rolling" }
        return type
    }
}
