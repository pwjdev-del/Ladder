import SwiftUI

// MARK: - Dashboard ViewModel

@Observable
final class DashboardViewModel {
    // Student info
    var studentName = "Kathan"
    var careerPath = "Medical Path"
    var grade = 10
    var streak = 0

    // Checklist
    var checklistProgress: Double = 0.0
    var completedTasks = 0
    var totalTasks = 0

    // Next task
    var nextTaskTitle = "Log Volunteering Hours"
    var nextTaskCategory = "Extracurriculars"
    var nextTaskProgress: Double = 0.45

    // Urgent deadline
    var urgentDeadlineTitle = ""
    var urgentDeadlineDate = ""
    var daysUntilDeadline = 0

    // Daily tip
    var dailyTip = "Start building your college list by researching schools that match your interests and academic profile."

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

    func loadDashboard() async {
        // TODO: Load from Supabase
        // - Student profile
        // - Checklist progress
        // - Upcoming deadlines
        // - AI-generated daily tip
    }
}
