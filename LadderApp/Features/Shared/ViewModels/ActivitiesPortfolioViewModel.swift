import Foundation
import SwiftData

// MARK: - Activities Portfolio ViewModel

@Observable
final class ActivitiesPortfolioViewModel {
    var activities: [ActivityModel] = []
    var selectedCategory: String = "All"
    var editingActivity: ActivityModel?
    var showingAddSheet = false
    var showingExportSheet = false
    var studentProfile: StudentProfileModel?

    private var modelContext: ModelContext?

    // MARK: - Computed

    var filteredActivities: [ActivityModel] {
        if selectedCategory == "All" {
            return activities
        }
        return activities.filter { $0.category == selectedCategory }
    }

    var totalHours: Double {
        activities.reduce(0) { $0 + $1.totalHours }
    }

    var leadershipCount: Int {
        activities.filter(\.isLeadership).count
    }

    var categoriesWithCounts: [(String, Int)] {
        var result: [(String, Int)] = [("All", activities.count)]
        for category in ActivityModel.allCategories {
            let count = activities.filter { $0.category == category }.count
            if count > 0 {
                result.append((category, count))
            }
        }
        return result
    }

    var groupedActivities: [(String, [ActivityModel])] {
        let grouped = Dictionary(grouping: filteredActivities) { $0.category }
        return ActivityModel.allCategories.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.tier < $1.tier })
        }
    }

    // MARK: - Data Operations

    @MainActor
    func load(context: ModelContext) {
        self.modelContext = context
        fetchAll()
        fetchStudentProfile()
    }

    func fetchAll() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<ActivityModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            activities = try modelContext.fetch(descriptor)
        } catch {
            activities = []
        }
    }

    func fetchStudentProfile() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<StudentProfileModel>()
        studentProfile = try? modelContext.fetch(descriptor).first
    }

    @MainActor
    func addActivity(_ activity: ActivityModel) {
        guard let modelContext else { return }
        modelContext.insert(activity)
        saveAndRefresh()
    }

    @MainActor
    func deleteActivity(_ activity: ActivityModel) {
        guard let modelContext else { return }
        modelContext.delete(activity)
        saveAndRefresh()
    }

    @MainActor
    func saveActivity() {
        saveAndRefresh()
    }

    private func saveAndRefresh() {
        guard let modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            // Handle silently
        }
        fetchAll()
    }
}
