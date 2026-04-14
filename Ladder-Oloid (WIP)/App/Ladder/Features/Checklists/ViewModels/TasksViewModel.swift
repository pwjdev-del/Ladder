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

    func loadTasks(for grade: Int) {
        tasks = TaskItem.tasksForGrade(grade)
    }

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
    var icon: String = "checkmark.circle"

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

    static func tasksForGrade(_ grade: Int) -> [TaskItem] {
        switch grade {
        case 9:
            return [
                TaskItem(title: "Keep GPA above 3.5", category: "Academics", isCompleted: false),
                TaskItem(title: "Join 2-3 school clubs", category: "Extracurriculars", isCompleted: false),
                TaskItem(title: "Explore career interests (take career quiz)", category: "Career", isCompleted: false),
                TaskItem(title: "Read for pleasure (build vocabulary)", category: "Academics", isCompleted: false),
                TaskItem(title: "Research summer programs", category: "Planning", isCompleted: false),
                TaskItem(title: "Attend career fair at school", category: "Career", isCompleted: false)
            ]
        case 10:
            return [
                TaskItem(title: "Maintain strong GPA (target 3.7+)", category: "Academics", isCompleted: false),
                TaskItem(title: "Take PSAT (practice)", category: "Testing", isCompleted: false),
                TaskItem(title: "Deepen involvement in 1-2 activities (leadership)", category: "Extracurriculars", isCompleted: false),
                TaskItem(title: "Start 30-40 hours of community service", category: "Service", isCompleted: false),
                TaskItem(title: "Research college types (public/private/liberal arts)", category: "Planning", isCompleted: false),
                TaskItem(title: "Plan AP or Honors courses for junior year", category: "Academics", isCompleted: false),
                TaskItem(title: "Summer job or enrichment program", category: "Summer", isCompleted: false)
            ]
        case 11:
            return [
                TaskItem(title: "Register for SAT or ACT", category: "Testing", isCompleted: false),
                TaskItem(title: "Take SAT/ACT (first attempt spring)", category: "Testing", isCompleted: false),
                TaskItem(title: "Take AP exams", category: "Testing", isCompleted: false),
                TaskItem(title: "Build college list (10-15 schools)", category: "Planning", isCompleted: false),
                TaskItem(title: "Visit 3-5 colleges", category: "Planning", isCompleted: false),
                TaskItem(title: "Ask teachers for recommendation letters (spring)", category: "Applications", isCompleted: false),
                TaskItem(title: "Draft Common App personal statement (summer)", category: "Essays", isCompleted: false),
                TaskItem(title: "Attend Junior Parent Night", category: "Planning", isCompleted: false)
            ]
        case 12:
            return [
                TaskItem(title: "Finalize college list (balance reach/match/safety)", category: "Applications", isCompleted: false),
                TaskItem(title: "Complete Common App activities section", category: "Applications", isCompleted: false),
                TaskItem(title: "Finalize personal statement", category: "Essays", isCompleted: false),
                TaskItem(title: "Submit EA/ED applications by Nov 1", category: "Applications", isCompleted: false),
                TaskItem(title: "Submit regular decision apps by Jan 1", category: "Applications", isCompleted: false),
                TaskItem(title: "Complete FAFSA (opens Oct 1)", category: "Financial Aid", isCompleted: false),
                TaskItem(title: "Request final transcripts", category: "Applications", isCompleted: false),
                TaskItem(title: "Compare financial aid packages (April)", category: "Financial Aid", isCompleted: false),
                TaskItem(title: "Submit enrollment deposit by May 1", category: "Post-Admission", isCompleted: false)
            ]
        default:
            return []
        }
    }

    // Keep the original static var sampleTasks but point it at a default grade for previews
    static var sampleTasks: [TaskItem] { tasksForGrade(10) }
}
