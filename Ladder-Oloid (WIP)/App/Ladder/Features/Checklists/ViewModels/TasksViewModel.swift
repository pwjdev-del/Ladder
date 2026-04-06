import SwiftUI

// MARK: - Tasks ViewModel

@Observable
final class TasksViewModel {

    // MARK: - Filter

    var selectedFilter: TaskFilter = .all
    var searchText = ""

    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case academics = "Academics"
        case testing = "Testing"
        case extracurriculars = "Extracurriculars"
        case applications = "Applications"
        case financial = "Financial"
    }

    // MARK: - Tasks

    var tasks: [TaskItem] = TaskItem.sampleTasks

    var filteredTasks: [TaskItem] {
        var result = tasks
        if selectedFilter != .all {
            result = result.filter { $0.category == selectedFilter.rawValue }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var pendingTasks: [TaskItem] {
        filteredTasks.filter { !$0.isCompleted }
    }

    var completedTasks: [TaskItem] {
        filteredTasks.filter { $0.isCompleted }
    }

    var overallProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isCompleted).count) / Double(tasks.count)
    }

    // MARK: - Actions

    func toggleTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].completedAt = Date()
            } else {
                tasks[index].completedAt = nil
            }
        }
    }
}

// MARK: - Task Item

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String?
    var category: String
    var dueDate: Date?
    var isCompleted: Bool = false
    var completedAt: Date?
    var priority: Priority = .medium
    var icon: String

    enum Priority: String {
        case high, medium, low
    }

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    var dueDateFormatted: String? {
        guard let dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }

    static var sampleTasks: [TaskItem] {
        let cal = Calendar.current
        let now = Date()
        return [
            TaskItem(
                title: "Register for SAT",
                description: "Sign up on College Board website. Fee waivers available.",
                category: "Testing",
                dueDate: cal.date(byAdding: .day, value: 13, to: now),
                priority: .high,
                icon: "pencil.and.list.clipboard"
            ),
            TaskItem(
                title: "Request Transcript from Counselor",
                description: "Ask your school counselor to send official transcripts.",
                category: "Applications",
                dueDate: cal.date(byAdding: .day, value: 30, to: now),
                priority: .high,
                icon: "doc.text"
            ),
            TaskItem(
                title: "Log Volunteering Hours",
                description: "Update your activity log with recent community service.",
                category: "Extracurriculars",
                dueDate: cal.date(byAdding: .day, value: 7, to: now),
                priority: .medium,
                icon: "heart.circle"
            ),
            TaskItem(
                title: "Study for AP Biology Exam",
                description: "Review chapters 12-18 and complete practice tests.",
                category: "Academics",
                dueDate: cal.date(byAdding: .day, value: 21, to: now),
                priority: .high,
                icon: "book"
            ),
            TaskItem(
                title: "Update Common App Activities",
                description: "Add new extracurriculars and update descriptions.",
                category: "Applications",
                dueDate: cal.date(byAdding: .day, value: 45, to: now),
                priority: .medium,
                icon: "square.and.pencil"
            ),
            TaskItem(
                title: "Research Scholarship Opportunities",
                description: "Check Fastweb and local community foundations.",
                category: "Financial",
                dueDate: cal.date(byAdding: .day, value: 14, to: now),
                priority: .medium,
                icon: "dollarsign.circle"
            ),
            TaskItem(
                title: "Complete FAFSA Application",
                description: "Gather tax documents and fill out FAFSA.",
                category: "Financial",
                dueDate: cal.date(byAdding: .day, value: 60, to: now),
                priority: .high,
                icon: "banknote"
            ),
            TaskItem(
                title: "Join a Club or Organization",
                description: "Look for clubs that align with your interests.",
                category: "Extracurriculars",
                isCompleted: true,
                completedAt: cal.date(byAdding: .day, value: -5, to: now),
                priority: .low,
                icon: "person.3"
            ),
            TaskItem(
                title: "Take Practice SAT",
                description: "Complete a full-length practice test under timed conditions.",
                category: "Testing",
                isCompleted: true,
                completedAt: cal.date(byAdding: .day, value: -3, to: now),
                priority: .medium,
                icon: "timer"
            ),
            TaskItem(
                title: "Set Up College Board Account",
                description: "Create account for SAT registration and score reports.",
                category: "Testing",
                isCompleted: true,
                completedAt: cal.date(byAdding: .day, value: -10, to: now),
                priority: .high,
                icon: "person.badge.key"
            ),
            TaskItem(
                title: "Draft Personal Statement",
                description: "Write first draft of your Common App essay.",
                category: "Applications",
                dueDate: cal.date(byAdding: .day, value: 90, to: now),
                priority: .medium,
                icon: "text.alignleft"
            ),
            TaskItem(
                title: "Build College List",
                description: "Research and create a balanced list of reach, match, and safety schools.",
                category: "Applications",
                dueDate: cal.date(byAdding: .day, value: 60, to: now),
                priority: .medium,
                icon: "list.bullet.rectangle"
            ),
        ]
    }
}
