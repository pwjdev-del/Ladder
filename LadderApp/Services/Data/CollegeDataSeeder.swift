import Foundation
import SwiftData

// MARK: - College Data Seeder
// Seeds SwiftData on first launch with merged Scorecard + Perplexity data

@Observable
final class CollegeDataSeeder {
    var isSeeding = false
    var progress: Double = 0
    var isComplete = false
    var schoolCount = 0

    @MainActor
    func seedIfNeeded(context: ModelContext) async {
        let descriptor = FetchDescriptor<CollegeModel>()
        let count = (try? context.fetchCount(descriptor)) ?? 0

        if count > 0 {
            schoolCount = count
            isComplete = true
            return
        }

        await performSeed(context: context)
    }

    /// Deletes all existing college data and re-seeds from scratch.
    /// Use this when the Perplexity database has been updated or field parsing has been fixed.
    @MainActor
    func forceReseed(context: ModelContext) async {
        isSeeding = true
        progress = 0
        isComplete = false

        // Delete all existing data
        do {
            try context.delete(model: CollegeDeadlineModel.self)
            try context.delete(model: CollegePersonalityModel.self)
            try context.delete(model: CollegeModel.self)
            try context.save()
            print("[CollegeDataSeeder] Deleted all existing college data for reseed")
        } catch {
            print("[CollegeDataSeeder] Error deleting existing data: \(error)")
        }

        await performSeed(context: context)
    }

    @MainActor
    private func performSeed(context: ModelContext) async {
        isSeeding = true
        progress = 0

        let merger = CollegeDataMerger()
        await merger.merge(context: context) { [weak self] p in
            Task { @MainActor in
                self?.progress = p
            }
        }

        schoolCount = merger.mergedCount
        isSeeding = false
        isComplete = true
    }
}
