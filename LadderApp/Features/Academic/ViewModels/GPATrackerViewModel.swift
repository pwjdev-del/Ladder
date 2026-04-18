import Foundation
import SwiftData

// MARK: - GPA Tracker ViewModel
// Manages semester GPA entries, calculates cumulative GPA and trends

@Observable
@MainActor
final class GPATrackerViewModel {

    // MARK: - State

    var entries: [GPAEntryModel] = []
    var showWeighted: Bool = true
    var showAddSemester: Bool = false

    // Add semester form state
    var selectedSeason: String = "Fall"
    var selectedYear: Int = Calendar.current.component(.year, from: Date())
    var editingCourses: [CourseGrade] = []
    var editingEntry: GPAEntryModel? = nil

    static let seasons = ["Fall", "Spring", "Summer"]
    static let availableYears: [Int] = {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 4)...(current + 2))
    }()

    // MARK: - Computed Properties

    var sortedEntries: [GPAEntryModel] {
        entries.sorted { semesterSortValue($0.semester) < semesterSortValue($1.semester) }
    }

    var cumulativeWeightedGPA: Double {
        let allCourses = entries.flatMap { $0.courses }
        return allCourses.weightedGPA
    }

    var cumulativeUnweightedGPA: Double {
        let allCourses = entries.flatMap { $0.courses }
        return allCourses.unweightedGPA
    }

    var currentGPA: Double {
        showWeighted ? cumulativeWeightedGPA : cumulativeUnweightedGPA
    }

    var currentGPAFormatted: String {
        String(format: "%.2f", currentGPA)
    }

    enum GPATrend {
        case improving, declining, stable, insufficient

        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .declining: return "arrow.down.right"
            case .stable: return "arrow.right"
            case .insufficient: return "minus"
            }
        }

        var label: String {
            switch self {
            case .improving: return "Improving"
            case .declining: return "Declining"
            case .stable: return "Stable"
            case .insufficient: return "Add more semesters"
            }
        }
    }

    var trend: GPATrend {
        let sorted = sortedEntries
        guard sorted.count >= 2 else { return .insufficient }
        let last = sorted[sorted.count - 1]
        let prev = sorted[sorted.count - 2]
        let recent = showWeighted ? last.weightedGPA : last.unweightedGPA
        let previous = showWeighted ? prev.weightedGPA : prev.unweightedGPA
        let diff = recent - previous

        if diff > 0.05 { return .improving }
        if diff < -0.05 { return .declining }
        return .stable
    }

    /// Data points for line chart: (Date, GPA)
    var chartData: [(Date, Double)] {
        sortedEntries.map { entry in
            let gpa = showWeighted ? entry.weightedGPA : entry.unweightedGPA
            return (entry.createdAt, gpa)
        }
    }

    var semesterLabel: String {
        "\(selectedSeason) \(selectedYear)"
    }

    var editingWeightedGPA: Double {
        editingCourses.weightedGPA
    }

    var editingUnweightedGPA: Double {
        editingCourses.unweightedGPA
    }

    // MARK: - Actions

    @MainActor
    func fetchEntries(context: ModelContext) {
        let descriptor = FetchDescriptor<GPAEntryModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        entries = (try? context.fetch(descriptor)) ?? []
    }

    func startAddSemester() {
        editingEntry = nil
        selectedSeason = "Fall"
        selectedYear = Calendar.current.component(.year, from: Date())
        editingCourses = [
            CourseGrade(name: "", creditHours: 3.0, grade: "A", isAP: false, isHonors: false)
        ]
        showAddSemester = true
    }

    func startEditSemester(_ entry: GPAEntryModel) {
        editingEntry = entry
        // Parse semester string
        let parts = entry.semester.split(separator: " ")
        if parts.count == 2 {
            selectedSeason = String(parts[0])
            selectedYear = Int(parts[1]) ?? Calendar.current.component(.year, from: Date())
        }
        editingCourses = entry.courses
        if editingCourses.isEmpty {
            editingCourses = [CourseGrade(name: "", creditHours: 3.0, grade: "A", isAP: false, isHonors: false)]
        }
        showAddSemester = true
    }

    func addCourse() {
        editingCourses.append(
            CourseGrade(name: "", creditHours: 3.0, grade: "A", isAP: false, isHonors: false)
        )
    }

    func removeCourse(at index: Int) {
        guard editingCourses.count > 1 else { return }
        editingCourses.remove(at: index)
    }

    @MainActor
    func saveSemester(context: ModelContext) {
        // Filter out empty courses
        let validCourses = editingCourses.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !validCourses.isEmpty else { return }

        if let existing = editingEntry {
            // Update existing
            existing.semester = semesterLabel
            existing.courses = validCourses
            existing.weightedGPA = validCourses.weightedGPA
            existing.unweightedGPA = validCourses.unweightedGPA
        } else {
            // Create new
            let entry = GPAEntryModel(
                semester: semesterLabel,
                courses: validCourses,
                weightedGPA: validCourses.weightedGPA,
                unweightedGPA: validCourses.unweightedGPA
            )
            context.insert(entry)
        }

        do { try context.save() } catch { Log.error("GPA save failed: \(error)") }
        fetchEntries(context: context)
        showAddSemester = false
        editingEntry = nil
    }

    @MainActor
    func deleteSemester(_ entry: GPAEntryModel, context: ModelContext) {
        context.delete(entry)
        do { try context.save() } catch { Log.error("GPA save failed: \(error)") }
        fetchEntries(context: context)
    }

    // MARK: - Helpers

    /// Converts "Fall 2024" to a sortable integer (year * 10 + season order)
    private func semesterSortValue(_ semester: String) -> Int {
        let parts = semester.split(separator: " ")
        guard parts.count == 2, let year = Int(parts[1]) else { return 0 }
        let seasonOrder: Int
        switch String(parts[0]) {
        case "Spring": seasonOrder = 0
        case "Summer": seasonOrder = 1
        case "Fall": seasonOrder = 2
        default: seasonOrder = 0
        }
        return year * 10 + seasonOrder
    }
}
