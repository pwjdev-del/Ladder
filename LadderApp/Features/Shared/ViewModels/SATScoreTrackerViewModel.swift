import SwiftUI
import SwiftData

// MARK: - SAT Score Tracker ViewModel

@Observable
final class SATScoreTrackerViewModel {

    var entries: [SATScoreEntryModel] = []
    var showAddSheet = false

    // Add score form fields
    var newTestDate = Date()
    var newMathScore = ""
    var newReadingScore = ""
    var newIsPractice = false

    // MARK: - Computed

    var sortedEntries: [SATScoreEntryModel] {
        entries.sorted { $0.testDate < $1.testDate }
    }

    var chartData: [(Date, Double)] {
        sortedEntries.map { ($0.testDate, Double($0.totalScore)) }
    }

    var bestSuperscore: Int {
        guard !entries.isEmpty else { return 0 }
        let bestMath = entries.map(\.mathScore).max() ?? 0
        let bestReading = entries.map(\.readingScore).max() ?? 0
        return bestMath + bestReading
    }

    var bestMath: Int {
        entries.map(\.mathScore).max() ?? 0
    }

    var bestReading: Int {
        entries.map(\.readingScore).max() ?? 0
    }

    var latestScore: SATScoreEntryModel? {
        sortedEntries.last
    }

    var improvementFromPrevious: Int? {
        let sorted = sortedEntries
        guard sorted.count >= 2 else { return nil }
        let current = sorted[sorted.count - 1].totalScore
        let previous = sorted[sorted.count - 2].totalScore
        return current - previous
    }

    // MARK: - College Targets (mock data for now)

    struct CollegeTarget: Identifiable {
        let id = UUID()
        let name: String
        let satLow: Int
        let satHigh: Int
    }

    var collegeTargets: [CollegeTarget] {
        [
            CollegeTarget(name: "Rochester Institute of Tech", satLow: 1270, satHigh: 1450),
            CollegeTarget(name: "University of Florida", satLow: 1300, satHigh: 1470),
            CollegeTarget(name: "Stanford University", satLow: 1470, satHigh: 1570)
        ]
    }

    var targetSATAverage: Double? {
        guard !collegeTargets.isEmpty else { return nil }
        let avg = collegeTargets.map { Double($0.satLow + $0.satHigh) / 2.0 }.reduce(0, +) / Double(collegeTargets.count)
        return avg
    }

    func statusForTarget(_ target: CollegeTarget) -> (label: String, color: Color) {
        let score = bestSuperscore
        if score >= target.satLow {
            return ("In Range", LadderColors.accentLime)
        } else if score >= target.satLow - 60 {
            return ("Close", Color.yellow)
        } else {
            return ("Below", LadderColors.error)
        }
    }

    // MARK: - Actions

    @MainActor
    func loadEntries(from context: ModelContext) {
        let descriptor = FetchDescriptor<SATScoreEntryModel>(
            sortBy: [SortDescriptor(\.testDate)]
        )
        entries = (try? context.fetch(descriptor)) ?? []
    }

    @MainActor
    func addScore(context: ModelContext) {
        guard let math = Int(newMathScore), let reading = Int(newReadingScore),
              math >= 200, math <= 800, reading >= 200, reading <= 800 else { return }

        let entry = SATScoreEntryModel(
            testDate: newTestDate,
            totalScore: math + reading,
            mathScore: math,
            readingScore: reading
        )
        entry.isPractice = newIsPractice
        context.insert(entry)
        try? context.save()

        // Reset form
        newMathScore = ""
        newReadingScore = ""
        newIsPractice = false
        newTestDate = Date()
        showAddSheet = false

        loadEntries(from: context)
    }

    @MainActor
    func deleteEntry(_ entry: SATScoreEntryModel, context: ModelContext) {
        context.delete(entry)
        try? context.save()
        loadEntries(from: context)
    }
}
