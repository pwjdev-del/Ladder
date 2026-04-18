import SwiftUI
import SwiftData

// MARK: - Dashboard ViewModel (Simplified 3-Section Dashboard)

@Observable
@MainActor
final class DashboardViewModel {
    // Student info
    var studentName = "Student"
    var careerPath = "Exploring"
    var grade = 10
    var streak = 0

    // Junior year major re-prompt
    var showMajorPrompt = false

    // Checklist progress
    var checklistProgress: Double = 0
    var completedTasks = 0
    var totalTasks = 0

    // Next task
    var nextTaskTitle = "Take the Career Quiz"
    var nextTaskCategory = "Getting Started"
    var nextTaskProgress: Double = 0
    var nextTaskRoute: Route? = nil

    // Upcoming deadlines (top 3)
    var upcomingDeadlines: [DashboardDeadline] = []

    // State-specific tip (loaded from student's state)
    var stateTip: String?

    // Grade + career-specific actions powered by ConnectionEngine
    var gradeActions: [DashboardAction] {
        ConnectionEngine.shared.dashboardActions(
            grade: grade,
            careerPath: careerPath == "Exploring" ? nil : careerPath
        )
    }

    // MARK: - Computed

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    // MARK: - Data Loading

    @MainActor
    func loadDashboard(context: ModelContext) {
        // Load student profile
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        if let profiles = try? context.fetch(profileDescriptor), let profile = profiles.first {
            studentName = profile.firstName.isEmpty ? "Student" : profile.firstName
            grade = profile.grade
            careerPath = profile.careerPath ?? "Exploring"
            streak = profile.streak

            // Junior year major re-prompt: show if grade 11+ and no major selected
            showMajorPrompt = profile.grade >= 11 && profile.selectedMajor == nil

            // Load state-specific tip
            stateTip = stateTipForState(profile.state)
        }

        // Load checklist progress
        let checklistDescriptor = FetchDescriptor<ChecklistItemModel>()
        if let items = try? context.fetch(checklistDescriptor), !items.isEmpty {
            totalTasks = items.count
            completedTasks = items.filter { $0.status == "completed" }.count
            checklistProgress = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0

            // Find next incomplete task sorted by due date
            let pending = items
                .filter { $0.status != "completed" }
                .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }

            if let nextTask = pending.first {
                nextTaskTitle = nextTask.title
                nextTaskCategory = nextTask.category?.capitalized ?? "General"

                // Progress within same category
                let categoryItems = items.filter { $0.category == nextTask.category }
                let categoryDone = categoryItems.filter { $0.status == "completed" }.count
                nextTaskProgress = categoryItems.isEmpty ? 0 : Double(categoryDone) / Double(categoryItems.count)
            }
        }

        // Load nearest 3 upcoming deadlines
        let now = Date()
        let deadlineDescriptor = FetchDescriptor<CollegeDeadlineModel>()
        if let deadlines = try? context.fetch(deadlineDescriptor) {
            let upcoming = deadlines
                .filter { ($0.date ?? .distantPast) > now }
                .sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
                .prefix(3)

            upcomingDeadlines = upcoming.map { deadline in
                let deadlineDate = deadline.date ?? Date()
                let days = Calendar.current.dateComponents([.day], from: now, to: deadlineDate).day ?? 0
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return DashboardDeadline(
                    collegeName: deadline.college?.name ?? "Unknown",
                    deadlineType: deadline.deadlineType,
                    dateFormatted: formatter.string(from: deadlineDate),
                    daysRemaining: max(days, 0)
                )
            }
        }
    }

    // MARK: - State Tip

    private func stateTipForState(_ state: String?) -> String? {
        guard let state = state?.uppercased() else { return nil }
        switch state {
        case "FL", "FLORIDA":
            return "Track your Bright Futures progress \u{2014} 100 service hours + 3.5 GPA for free tuition"
        case "TX", "TEXAS":
            return "Top 6% of your class? Automatic UT Austin admission"
        case "CA", "CALIFORNIA":
            return "Complete A-G courses for UC/CSU eligibility"
        case "NY", "NEW YORK":
            return "Excelsior Scholarship covers SUNY/CUNY tuition if family income < $125K"
        case "GA", "GEORGIA":
            return "Maintain 3.0 GPA for HOPE Scholarship \u{2014} free GA public university tuition"
        default:
            return nil
        }
    }
}

// MARK: - Supporting Types

struct DashboardAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let route: Route
}

struct DashboardDeadline: Identifiable {
    let id = UUID()
    let collegeName: String
    let deadlineType: String
    let dateFormatted: String
    let daysRemaining: Int
}
