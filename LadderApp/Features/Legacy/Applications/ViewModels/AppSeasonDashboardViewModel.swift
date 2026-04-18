import SwiftUI
import SwiftData

// MARK: - App Season Dashboard ViewModel
// Drives the application season dashboard for 12th graders during Sep–Jan

@Observable
final class AppSeasonDashboardViewModel {

    // MARK: - State

    var applications: [ApplicationModel] = []
    var studentGrade: Int = 10
    var isAppSeason: Bool = false

    // MARK: - Computed

    var regularDecisionDeadline: Date {
        // Jan 1 of the current cycle year
        let cal = Calendar.current
        let now = Date()
        let month = cal.component(.month, from: now)
        let year = cal.component(.year, from: now)
        // If Sep–Dec, RD deadline is Jan 1 of next year; if Jan, it's Jan 1 of this year
        let rdYear = month >= 9 ? year + 1 : year
        return cal.date(from: DateComponents(year: rdYear, month: 1, day: 1)) ?? now
    }

    var daysUntilRD: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: regularDecisionDeadline).day ?? 0
        return max(days, 0)
    }

    var submittedCount: Int {
        applications.filter { ["submitted", "accepted", "rejected", "waitlisted", "committed"].contains($0.status) }.count
    }

    var totalCount: Int {
        applications.count
    }

    var submissionProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(submittedCount) / Double(totalCount)
    }

    /// Applications sorted by nearest deadline first
    var urgencyList: [ApplicationModel] {
        applications
            .filter { !["submitted", "accepted", "rejected", "committed"].contains($0.status) }
            .sorted { ($0.deadlineDate ?? .distantFuture) < ($1.deadlineDate ?? .distantFuture) }
    }

    // Status breakdown counts
    var notStartedCount: Int { applications.filter { $0.status == "planning" }.count }
    var inProgressCount: Int { applications.filter { $0.status == "in_progress" }.count }
    var submittedStatusCount: Int { applications.filter { $0.status == "submitted" }.count }
    var decidedCount: Int { applications.filter { ["accepted", "rejected", "waitlisted", "committed"].contains($0.status) }.count }

    // MARK: - Quick Actions

    struct QuickAction: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let route: Route
    }

    var quickActions: [QuickAction] {
        [
            QuickAction(title: "Write Essay", icon: "text.alignleft", route: .essayHub),
            QuickAction(title: "Request Rec", icon: "envelope", route: .lorTracker),
            QuickAction(title: "Submit App", icon: "paperplane", route: .deadlinesCalendar),
            QuickAction(title: "Check Status", icon: "envelope.open", route: .decisionPortal),
        ]
    }

    // MARK: - Season Check

    func checkAppSeason() {
        let cal = Calendar.current
        let month = cal.component(.month, from: Date())
        // App season: September (9) through January (1)
        isAppSeason = studentGrade == 12 && (month >= 9 || month == 1)
    }

    // MARK: - Data Loading

    @MainActor
    func loadData(context: ModelContext) {
        // Load student grade
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        if let profiles = try? context.fetch(profileDescriptor), let profile = profiles.first {
            studentGrade = profile.grade
        }

        checkAppSeason()

        // Load all applications
        let appDescriptor = FetchDescriptor<ApplicationModel>(
            sortBy: [SortDescriptor(\.deadlineDate)]
        )
        applications = (try? context.fetch(appDescriptor)) ?? []
    }

    // MARK: - Helpers

    func daysUntilDeadline(for app: ApplicationModel) -> Int? {
        guard let deadline = app.deadlineDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(days, 0)
    }

    func statusColor(for status: String) -> Color {
        switch status {
        case "planning": return LadderColors.error
        case "in_progress": return Color(red: 0.75, green: 0.60, blue: 0.10)
        case "submitted": return LadderColors.primary
        case "accepted", "committed": return Color(red: 0.15, green: 0.50, blue: 0.70)
        case "rejected": return LadderColors.error
        case "waitlisted": return Color(red: 0.75, green: 0.60, blue: 0.10)
        default: return LadderColors.onSurfaceVariant
        }
    }

    func statusLabel(for status: String) -> String {
        switch status {
        case "planning": return "Not Started"
        case "in_progress": return "In Progress"
        case "submitted": return "Submitted"
        case "accepted": return "Accepted"
        case "rejected": return "Rejected"
        case "waitlisted": return "Waitlisted"
        case "committed": return "Committed"
        default: return status.capitalized
        }
    }
}
