import Foundation
import SwiftData

// MARK: - AI College Summary ViewModel

@Observable
final class AICollegeSummaryViewModel {

    // MARK: - State

    var college: CollegeModel?
    var studentProfile: StudentProfileModel?
    var sections: [SummarySection] = []
    var isLoading = true

    let collegeId: String

    init(collegeId: String) {
        self.collegeId = collegeId
    }

    // MARK: - Load Data

    func loadData(context: ModelContext) {
        // Load college
        let collegeDescriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(collegeDescriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId || $0.name == collegeId }
        }

        // Load student profile
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        if let profiles = try? context.fetch(profileDescriptor) {
            studentProfile = profiles.first
        }

        generateSummary()
        isLoading = false
    }

    // MARK: - Generate Summary Sections

    private func generateSummary() {
        guard let c = college else { return }
        var result: [SummarySection] = []

        // 1. At a Glance
        result.append(buildAtAGlance(c))

        // 2. Who Gets In
        result.append(buildWhoGetsIn(c))

        // 3. What It Costs
        result.append(buildWhatItCosts(c))

        // 4. Student Life
        result.append(buildStudentLife(c))

        // 5. Why It Might Be Right For You
        result.append(buildWhyRightForYou(c))

        sections = result
    }

    private func buildAtAGlance(_ c: CollegeModel) -> SummarySection {
        let typeStr = c.institutionType ?? "institution"
        let location = [c.city, c.state].compactMap { $0 }.joined(separator: ", ")
        let sizeStr = c.sizeCategory?.lowercased() ?? "mid-sized"
        let enrollStr = c.enrollment.map { "approximately \($0.formatted()) students" } ?? "a diverse student body"
        let hbcuNote = c.isHBCU ? " As a Historically Black College or University, it carries a rich legacy of academic excellence and cultural pride." : ""
        let archetype: String
        if let name = c.personality?.archetypeName {
            archetype = " Often described as \"\(name),\""
        } else {
            archetype = ""
        }

        let text = """
        \(c.name) is a \(sizeStr) \(typeStr) located in \(location.isEmpty ? "the United States" : location), \
        serving \(enrollStr).\(archetype) the school \
        \(c.completionRate.map { "boasts a \(Int($0 * 100))% graduation rate" } ?? "is committed to student success") \
        and \(c.retentionRate.map { "retains \(Int($0 * 100))% of first-year students" } ?? "prioritizes student retention").\(hbcuNote)
        """

        return SummarySection(
            icon: "building.columns",
            title: "At a Glance",
            body: text
        )
    }

    private func buildWhoGetsIn(_ c: CollegeModel) -> SummarySection {
        var lines: [String] = []

        if c.isOpenAdmissions {
            lines.append("This is an open-admissions institution, meaning all applicants who meet basic requirements are accepted.")
        } else if let rate = c.acceptanceRate {
            let pct = Int(rate * 100)
            let selectivity: String
            if pct < 15 { selectivity = "highly selective" }
            else if pct < 30 { selectivity = "very selective" }
            else if pct < 50 { selectivity = "moderately selective" }
            else { selectivity = "accessible" }
            lines.append("\(c.name) is \(selectivity) with a \(pct)% acceptance rate.")
        }

        if let satAvg = c.satAvg {
            let satRange: String
            if let m25 = c.satMath25, let m75 = c.satMath75 {
                satRange = " (Math: \(m25)-\(m75))"
            } else { satRange = "" }
            lines.append("The average SAT score is \(satAvg)\(satRange).")
        }

        if let act = c.actAvg {
            lines.append("The average ACT score is \(act).")
        }

        let testPolicy = c.personality?.testPolicy ?? c.testingPolicy
        if let policy = testPolicy {
            lines.append("Testing policy: \(policy).")
        }

        if let essays = c.supplementalEssaysCount {
            lines.append("Supplemental essays required: \(essays).")
        }

        if let recs = c.recommendationLetters {
            lines.append("Recommendation letters: \(recs).")
        }

        if let interview = c.interviewPolicy {
            lines.append("Interview: \(interview).")
        }

        if let interest = c.demonstratedInterest {
            lines.append("Demonstrated interest: \(interest).")
        }

        return SummarySection(
            icon: "person.badge.key",
            title: "Who Gets In",
            body: lines.joined(separator: " ")
        )
    }

    private func buildWhatItCosts(_ c: CollegeModel) -> SummarySection {
        var lines: [String] = []

        if let inState = c.inStateTuition {
            lines.append("In-state tuition: $\(inState.formatted()).")
        }
        if let outState = c.outStateTuition {
            lines.append("Out-of-state tuition: $\(outState.formatted()).")
        }
        if let rb = c.roomAndBoard {
            lines.append("Room & board: $\(rb.formatted()).")
        }
        if let net = c.avgNetPrice {
            lines.append("Average net price after aid: $\(net.formatted()).")
        }
        if let debt = c.medianDebt {
            lines.append("Median student debt at graduation: $\(debt.formatted()).")
        }
        if let earnings = c.medianEarnings {
            lines.append("Median earnings 10 years after enrollment: $\(earnings.formatted()).")
        }
        if let css = c.cssProfileRequired {
            lines.append("CSS Profile: \(css).")
        }
        if let merit = c.topMeritScholarship, let amount = c.meritScholarshipAmount {
            lines.append("Top merit scholarship: \(merit) (\(amount)).")
        }
        if let pell = c.pellRate {
            lines.append("\(Int(pell * 100))% of students receive Pell Grants.")
        }

        if lines.isEmpty {
            lines.append("Detailed cost information is not yet available for this school.")
        }

        return SummarySection(
            icon: "dollarsign.circle",
            title: "What It Costs",
            body: lines.joined(separator: " ")
        )
    }

    private func buildStudentLife(_ c: CollegeModel) -> SummarySection {
        var lines: [String] = []

        if let personality = c.personality {
            if !personality.cultureKeywords.isEmpty {
                let keywords = personality.cultureKeywords.joined(separator: ", ")
                lines.append("Campus culture is characterized by: \(keywords).")
            }
            if !personality.traits.isEmpty {
                let traits = personality.traits.joined(separator: ", ")
                lines.append("Key traits: \(traits).")
            }
            if !personality.optimalStudentTypes.isEmpty {
                let types = personality.optimalStudentTypes.joined(separator: ", ")
                lines.append("This school tends to be a great fit for: \(types).")
            }
            if let desc = personality.archetypeDescription {
                lines.append(desc)
            }
        }

        if let size = c.sizeCategory {
            lines.append("As a \(size.lowercased()) school, \(c.name) offers a \(size == "Small" ? "tight-knit community feel" : size == "Large" ? "wide range of clubs, organizations, and social opportunities" : "balanced campus experience").")
        }

        if lines.isEmpty {
            lines.append("Student life details are being gathered for \(c.name). Check back soon for campus culture insights.")
        }

        return SummarySection(
            icon: "figure.socialdance",
            title: "Student Life",
            body: lines.joined(separator: " ")
        )
    }

    private func buildWhyRightForYou(_ c: CollegeModel) -> SummarySection {
        var lines: [String] = []

        if let student = studentProfile {
            if let career = student.careerPath, !c.programs.isEmpty {
                let matching = c.programs.prefix(2).joined(separator: " and ")
                lines.append("Your interest in \(career) aligns with \(c.name)'s programs in \(matching).")
            }

            if let gpa = student.gpa, let rate = c.acceptanceRate {
                let competitive = gpa >= 3.5 && rate < 0.3
                if competitive {
                    lines.append("With your GPA of \(String(format: "%.1f", gpa)), you're a competitive applicant for this \(Int(rate * 100))% acceptance rate school.")
                } else {
                    lines.append("Your GPA of \(String(format: "%.1f", gpa)) puts you in the running at a school with a \(Int(rate * 100))% acceptance rate.")
                }
            }

            if let sat = student.satScore, let avg = c.satAvg {
                if sat >= avg {
                    lines.append("Your SAT score of \(sat) is at or above the school average of \(avg).")
                } else {
                    lines.append("The average SAT here is \(avg) — consider how your full application strengthens your candidacy.")
                }
            }

            if student.isFirstGen {
                if let importance = c.personality?.firstGenImportance, importance == "Very Important" || importance == "Important" {
                    lines.append("As a first-generation student, you'll be valued here — first-gen status is considered \(importance.lowercased()) in admissions.")
                }
            }

            if !student.extracurriculars.isEmpty {
                let acts = student.extracurriculars.prefix(2).joined(separator: " and ")
                lines.append("Your involvement in \(acts) demonstrates the kind of engagement \(c.name) values.")
            }
        } else {
            lines.append("Complete your profile to see personalized insights about why \(c.name) might be a great fit for you.")
        }

        return SummarySection(
            icon: "sparkles",
            title: "Why It Might Be Right For You",
            body: lines.joined(separator: " ")
        )
    }

    // MARK: - Share

    func shareText() -> String {
        guard let c = college else { return "" }
        var text = "College Summary: \(c.name)\n\n"
        for section in sections {
            text += "--- \(section.title) ---\n\(section.body)\n\n"
        }
        text += "Generated by Ladder"
        return text
    }
}

// MARK: - Supporting Types

struct SummarySection: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
}
