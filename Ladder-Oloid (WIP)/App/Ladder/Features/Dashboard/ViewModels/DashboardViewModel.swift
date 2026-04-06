import SwiftUI

// MARK: - Dashboard ViewModel

@Observable
final class DashboardViewModel {
    // Student info
    var studentName = "Kathan"
    var careerPath = "Medical Path"
    var grade = 10
    var streak = 14

    // Checklist
    var checklistProgress: Double = 0.6
    var completedTasks = 6
    var totalTasks = 10

    // Next task
    var nextTaskTitle = "Log Volunteering Hours"
    var nextTaskCategory = "Extracurriculars"
    var nextTaskProgress: Double = 0.45

    // Urgent deadline
    var urgentDeadlineTitle = "SAT Registration"
    var urgentDeadlineDate = "April 15, 2026"
    var daysUntilDeadline = 13

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
