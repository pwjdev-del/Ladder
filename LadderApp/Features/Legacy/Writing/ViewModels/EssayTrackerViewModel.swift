import Foundation
import SwiftData

// MARK: - Essay Tracker ViewModel

@Observable
final class EssayTrackerViewModel {

    // MARK: - State

    var essays: [EssayModel] = []
    var colleges: [CollegeModel] = []
    var collegesToPrompt: [CollegeModel] = []

    // Sheet state
    var showAddSheet = false
    var showEditorSheet = false
    var selectedEssay: EssayModel?

    // Add-essay form fields
    var newPrompt: String = ""
    var newWordLimit: String = "650"
    var selectedCollege: CollegeModel?

    // MARK: - Computed

    var totalEssays: Int { essays.count }

    var completedEssays: Int { essays.filter(\.isComplete).count }

    var progressPercentage: Double {
        guard totalEssays > 0 else { return 0 }
        return Double(completedEssays) / Double(totalEssays)
    }

    /// Essays grouped by college name, sorted alphabetically
    var groupedByCollege: [(collegeName: String, essays: [EssayModel])] {
        let grouped = Dictionary(grouping: essays, by: \.collegeName)
        return grouped
            .map { (collegeName: $0.key, essays: $0.value.sorted { $0.createdAt < $1.createdAt }) }
            .sorted { $0.collegeName < $1.collegeName }
    }

    // MARK: - Data Loading

    @MainActor
    func loadData(context: ModelContext) {
        let essayDescriptor = FetchDescriptor<EssayModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        essays = (try? context.fetch(essayDescriptor)) ?? []

        let collegeDescriptor = FetchDescriptor<CollegeModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        colleges = (try? context.fetch(collegeDescriptor)) ?? []

        // Detect saved colleges that don't have essay entries yet
        detectSavedCollegesWithoutEssays(context: context)
    }

    // MARK: - Saved College Detection

    /// Find saved colleges that have no essay entries yet
    func detectSavedCollegesWithoutEssays(context: ModelContext) {
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        guard let profile = try? context.fetch(profileDescriptor).first else {
            collegesToPrompt = []
            return
        }

        let savedIds = Set(profile.savedCollegeIds)
        guard !savedIds.isEmpty else {
            collegesToPrompt = []
            return
        }

        // College names that already have essays
        let collegeNamesWithEssays = Set(essays.map(\.collegeName))

        // Find saved colleges that have NO essays
        collegesToPrompt = colleges.filter { college in
            let collegeId = college.supabaseId ?? (college.scorecardId.map { String($0) } ?? college.name)
            return savedIds.contains(collegeId) && !collegeNamesWithEssays.contains(college.name)
        }
    }

    /// Auto-create essay tracking entries for a saved college
    @MainActor
    func autoCreateEssays(for college: CollegeModel, context: ModelContext) {
        let essayCountStr = college.supplementalEssaysCount ?? "0"
        let essayCount = max(Int(essayCountStr) ?? 1, 1)
        let collegeId = college.supabaseId ?? UUID().uuidString

        for i in 1...essayCount {
            let prompt = essayCount == 1
                ? "Supplemental essay for \(college.name)"
                : "Supplemental essay \(i) for \(college.name)"

            let essay = EssayModel(
                collegeId: collegeId,
                collegeName: college.name,
                prompt: prompt,
                wordLimit: 650
            )
            context.insert(essay)
        }

        try? context.save()
        loadData(context: context)
    }

    // MARK: - Actions

    @MainActor
    func addEssay(context: ModelContext) {
        guard let college = selectedCollege,
              !newPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let limit = Int(newWordLimit) ?? 650
        let essay = EssayModel(
            collegeId: college.supabaseId ?? UUID().uuidString,
            collegeName: college.name,
            prompt: newPrompt.trimmingCharacters(in: .whitespacesAndNewlines),
            wordLimit: limit
        )
        context.insert(essay)
        try? context.save()

        // Reset form
        newPrompt = ""
        newWordLimit = "650"
        selectedCollege = nil
        showAddSheet = false

        loadData(context: context)
    }

    @MainActor
    func saveEssay(_ essay: EssayModel, context: ModelContext) {
        essay.updatedAt = Date()
        try? context.save()
        loadData(context: context)
    }

    @MainActor
    func deleteEssay(_ essay: EssayModel, context: ModelContext) {
        context.delete(essay)
        try? context.save()
        loadData(context: context)
    }

    func openEditor(for essay: EssayModel) {
        selectedEssay = essay
        showEditorSheet = true
    }
}
