import SwiftUI
import SwiftData

// MARK: - What If Simulator ViewModel

@Observable
final class WhatIfSimulatorViewModel {

    // Slider values
    var gpa: Double = 3.5
    var satScore: Double = 1200
    var apCount: Double = 3
    var extracurricularRating: Double = 3

    // College selection
    var selectedCollege: CollegeModel?
    var searchText = ""
    var colleges: [CollegeModel] = []
    var savedColleges: [CollegeModel] = []

    // Results
    var matchCategory: MatchCategory = .match
    var chancePercent: Double = 50
    var summaryText = ""

    enum MatchCategory: String {
        case reach = "Reach"
        case match = "Match"
        case safety = "Safety"
    }

    init() {}

    // MARK: - Load Colleges

    @MainActor
    func loadColleges(from context: ModelContext) {
        do {
            var descriptor = FetchDescriptor<CollegeModel>(
                sortBy: [SortDescriptor(\.name)]
            )
            descriptor.fetchLimit = 10000
            let models = try context.fetch(descriptor)
            colleges = models

            // Load student profile for saved colleges
            let profileDescriptor = FetchDescriptor<StudentProfileModel>()
            if let profile = try context.fetch(profileDescriptor).first {
                let savedIds = Set(profile.savedCollegeIds)
                savedColleges = models.filter { college in
                    if let sid = college.supabaseId { return savedIds.contains(sid) }
                    if let scid = college.scorecardId { return savedIds.contains(String(scid)) }
                    return false
                }
            }
        } catch {
            print("[WhatIfSimulatorVM] Fetch error: \(error)")
        }
    }

    // MARK: - Fill from Student Profile

    @MainActor
    func fillFromProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<StudentProfileModel>()
        guard let profile = try? context.fetch(descriptor).first else { return }
        if let gpaVal = profile.gpa { gpa = gpaVal }
        if let sat = profile.satScore { satScore = Double(sat) }
        apCount = Double(profile.apCourses.count)
        let activityCount = profile.extracurriculars.count
        extracurricularRating = min(5, max(1, Double(activityCount)))
    }

    // MARK: - Filtered Colleges for Search

    var filteredColleges: [CollegeModel] {
        if searchText.isEmpty { return savedColleges }
        let query = searchText.lowercased()
        return colleges.filter { $0.name.lowercased().contains(query) }
    }

    // MARK: - Calculate Match

    func recalculate() {
        guard let college = selectedCollege else {
            matchCategory = .match
            chancePercent = 50
            summaryText = "Select a college to see your chances."
            return
        }

        var score: Double = 50

        // SAT comparison against 25th/75th percentile
        let sat = Int(satScore)
        if let sat75 = college.satMath75, let satR75 = college.satReading75 {
            let combined75 = sat75 + satR75
            if sat >= combined75 {
                score += 20
            } else if let sat25 = college.satMath25, let satR25 = college.satReading25 {
                let combined25 = sat25 + satR25
                if sat >= combined25 {
                    let range = Double(combined75 - combined25)
                    let position = range > 0 ? Double(sat - combined25) / range : 0.5
                    score += position * 15
                } else {
                    let deficit = Double(combined25 - sat) / Double(combined25)
                    score -= deficit * 30
                }
            }
        } else if let satAvg = college.satAvg {
            let ratio = Double(sat) / Double(satAvg)
            score += (ratio - 1.0) * 50
        }

        // GPA factor (estimate typical admitted GPA from acceptance rate)
        let estimatedTargetGPA: Double
        if let rate = college.acceptanceRate {
            if rate < 0.1 { estimatedTargetGPA = 3.95 }
            else if rate < 0.2 { estimatedTargetGPA = 3.85 }
            else if rate < 0.3 { estimatedTargetGPA = 3.75 }
            else if rate < 0.5 { estimatedTargetGPA = 3.5 }
            else if rate < 0.7 { estimatedTargetGPA = 3.2 }
            else { estimatedTargetGPA = 3.0 }
        } else {
            estimatedTargetGPA = 3.5
        }
        let gpaRatio = gpa / estimatedTargetGPA
        score += (gpaRatio - 1.0) * 30

        // Acceptance rate factor
        if let rate = college.acceptanceRate {
            score += (rate - 0.5) * 20
        }

        // AP boost
        score += min(10, apCount * 1.5)

        // Extracurricular boost
        score += (extracurricularRating - 3) * 3

        // Test-optional boost
        if let policy = college.testingPolicy?.lowercased(),
           (policy.contains("optional") || policy.contains("blind")),
           sat < (college.satAvg ?? 1200) {
            score += 5
        }

        // Clamp
        chancePercent = min(95, max(5, score))

        // Determine category
        if chancePercent >= 70 {
            matchCategory = .safety
        } else if chancePercent >= 30 {
            matchCategory = .match
        } else {
            matchCategory = .reach
        }

        // Build summary
        let gpaStr = String(format: "%.1f", gpa)
        let satStr = "\(Int(satScore))"
        summaryText = "With a \(gpaStr) GPA and \(satStr) SAT, you'd be a \(matchCategory.rawValue.uppercased()) for \(college.name)."
    }

    // MARK: - College stat helpers

    var collegeSATRange: String {
        guard let college = selectedCollege else { return "N/A" }
        if let m25 = college.satMath25, let m75 = college.satMath75,
           let r25 = college.satReading25, let r75 = college.satReading75 {
            return "\(m25 + r25) - \(m75 + r75)"
        }
        if let avg = college.satAvg { return "\(avg)" }
        return "N/A"
    }

    var collegeAcceptanceRate: String {
        guard let rate = selectedCollege?.acceptanceRate else { return "N/A" }
        return "\(Int(rate * 100))%"
    }
}
