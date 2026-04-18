import SwiftUI
import SwiftData

// MARK: - My Chances ViewModel

@Observable
final class MyChancesViewModel {

    var studentGPA: Double = 0
    var studentSAT: Int = 0
    var studentACT: Int = 0
    var studentAPCount: Int = 0
    var hasProfile = false

    var collegeChances: [CollegeChance] = []
    var suggestions: [ImprovementSuggestion] = []
    var sortOrder: SortOrder = .chance

    enum SortOrder: String, CaseIterable {
        case chance = "Best Chance"
        case name = "A-Z"
        case acceptance = "Selectivity"
    }

    struct CollegeChance: Identifiable {
        let id = UUID()
        let college: CollegeModel
        let chancePercent: Double
        let category: MatchCategory
    }

    struct ImprovementSuggestion: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
        let impact: String
    }

    enum MatchCategory: String {
        case reach = "Reach"
        case match = "Match"
        case safety = "Safety"
    }

    init() {}

    // MARK: - Load Data

    @MainActor
    func loadData(from context: ModelContext) {
        // Load student profile
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        guard let profile = try? context.fetch(profileDescriptor).first else {
            hasProfile = false
            return
        }
        hasProfile = true
        studentGPA = profile.gpa ?? 0
        studentSAT = profile.satScore ?? 0
        studentACT = profile.actScore ?? 0
        studentAPCount = profile.apCourses.count

        // Load saved colleges
        let savedIds = Set(profile.savedCollegeIds)
        guard !savedIds.isEmpty else { return }

        let descriptor = FetchDescriptor<CollegeModel>(sortBy: [SortDescriptor(\.name)])
        guard let allColleges = try? context.fetch(descriptor) else { return }

        let saved = allColleges.filter { college in
            if let sid = college.supabaseId { return savedIds.contains(sid) }
            if let scid = college.scorecardId { return savedIds.contains(String(scid)) }
            return false
        }

        // Calculate chances for each
        collegeChances = saved.map { college in
            let chance = calculateChance(for: college, profile: profile)
            let category: MatchCategory
            if chance >= 70 { category = .safety }
            else if chance >= 30 { category = .match }
            else { category = .reach }
            return CollegeChance(college: college, chancePercent: chance, category: category)
        }

        sortColleges()
        generateSuggestions()
    }

    // MARK: - Calculate Chance for Single College

    private func calculateChance(for college: CollegeModel, profile: StudentProfileModel) -> Double {
        var score: Double = 50
        let sat = profile.satScore ?? 0

        // SAT comparison
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
                    let deficit = Double(combined25 - sat) / Double(max(1, combined25))
                    score -= deficit * 30
                }
            }
        } else if let satAvg = college.satAvg, sat > 0 {
            let ratio = Double(sat) / Double(satAvg)
            score += (ratio - 1.0) * 50
        }

        // GPA factor
        let gpa = profile.gpa ?? 3.0
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
        score += ((gpa / estimatedTargetGPA) - 1.0) * 30

        // Acceptance rate factor
        if let rate = college.acceptanceRate {
            score += (rate - 0.5) * 20
        }

        // AP boost
        score += min(10, Double(profile.apCourses.count) * 1.5)

        // Test-optional boost
        let testPolicy = college.testingPolicy?.lowercased() ?? ""
        let personalityTestPolicy = college.personality?.testPolicy?.lowercased() ?? ""
        let isTestOptional = testPolicy.contains("optional") || testPolicy.contains("blind")
            || personalityTestPolicy.contains("optional") || personalityTestPolicy.contains("blind")
        if isTestOptional && sat < (college.satAvg ?? 1200) {
            score += 5
        }

        return min(95, max(5, score))
    }

    // MARK: - Sort

    func sortColleges() {
        switch sortOrder {
        case .chance:
            collegeChances.sort { $0.chancePercent > $1.chancePercent }
        case .name:
            collegeChances.sort { $0.college.name < $1.college.name }
        case .acceptance:
            collegeChances.sort { ($0.college.acceptanceRate ?? 1) < ($1.college.acceptanceRate ?? 1) }
        }
    }

    // MARK: - Generate Suggestions

    private func generateSuggestions() {
        var items: [ImprovementSuggestion] = []

        // Find reach schools and suggest improvements
        let reachSchools = collegeChances.filter { $0.category == .reach }

        for reach in reachSchools.prefix(3) {
            if let satAvg = reach.college.satAvg, studentSAT < satAvg {
                let gap = satAvg - studentSAT
                let needed = min(gap, 100)
                items.append(ImprovementSuggestion(
                    icon: "doc.text.magnifyingglass",
                    text: "Raise SAT by \(needed) points to improve chances at \(reach.college.name)",
                    impact: "+\(Int(Double(needed) / 10))% chance"
                ))
            }
        }

        if studentAPCount < 5 {
            items.append(ImprovementSuggestion(
                icon: "book.closed",
                text: "Take \(5 - studentAPCount) more AP courses to strengthen your academic profile",
                impact: "+5-10% across schools"
            ))
        }

        if studentGPA < 3.8 && studentGPA > 0 {
            items.append(ImprovementSuggestion(
                icon: "chart.line.uptrend.xyaxis",
                text: "Aim for a \(String(format: "%.1f", min(4.0, studentGPA + 0.2))) GPA this semester to boost competitiveness",
                impact: "+3-8% for reach schools"
            ))
        }

        if items.isEmpty {
            items.append(ImprovementSuggestion(
                icon: "star.fill",
                text: "Your profile is strong — focus on essays and extracurriculars to stand out",
                impact: "Holistic boost"
            ))
        }

        suggestions = items
    }

    // MARK: - Stats

    var safetyCount: Int { collegeChances.filter { $0.category == .safety }.count }
    var matchCount: Int { collegeChances.filter { $0.category == .match }.count }
    var reachCount: Int { collegeChances.filter { $0.category == .reach }.count }
}
