import Foundation
import SwiftData
import UIKit

// MARK: - Why This School Essay Seed ViewModel

@Observable
final class WhyThisSchoolViewModel {

    // MARK: - State

    var college: CollegeModel?
    var studentProfile: StudentProfileModel?
    var talkingPoints: [TalkingPoint] = []
    var paragraphs: [EssayParagraph] = []
    var isGenerating = false
    var hasGenerated = false
    var copiedToClipboard = false

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

        buildTalkingPoints()
    }

    // MARK: - Talking Points

    private func buildTalkingPoints() {
        guard let c = college else { return }
        var points: [TalkingPoint] = []

        // Unique programs related to student's career interest
        if let career = studentProfile?.careerPath, !c.programs.isEmpty {
            let relatedPrograms = c.programs.prefix(3).joined(separator: ", ")
            points.append(TalkingPoint(
                icon: "graduationcap",
                title: "Programs Aligned with Your Goals",
                detail: "\(c.name) offers \(relatedPrograms) — relevant to your interest in \(career)."
            ))
        } else if !c.programs.isEmpty {
            let topPrograms = c.programs.prefix(3).joined(separator: ", ")
            points.append(TalkingPoint(
                icon: "graduationcap",
                title: "Notable Programs",
                detail: "\(c.name) offers \(topPrograms)."
            ))
        }

        // Campus culture keywords
        if let personality = c.personality, !personality.cultureKeywords.isEmpty {
            let keywords = personality.cultureKeywords.prefix(4).joined(separator: ", ")
            points.append(TalkingPoint(
                icon: "person.3",
                title: "Campus Culture",
                detail: "Students describe the culture as: \(keywords)."
            ))
        }

        // Location / city appeal
        if let city = c.city, let state = c.state {
            points.append(TalkingPoint(
                icon: "mappin.and.ellipse",
                title: "Location Appeal",
                detail: "Located in \(city), \(state) — a setting that offers unique opportunities for internships and community engagement."
            ))
        }

        // Research opportunities
        if let personality = c.personality, !personality.traits.isEmpty {
            let traits = personality.traits.prefix(3).joined(separator: ", ")
            points.append(TalkingPoint(
                icon: "magnifyingglass",
                title: "Research & Opportunities",
                detail: "Known for being \(traits) — offering hands-on research and experiential learning."
            ))
        }

        // Student-faculty ratio
        if let enrollment = c.enrollment, let size = c.sizeCategory {
            points.append(TalkingPoint(
                icon: "person.2",
                title: "Community Size",
                detail: "\(size) campus with ~\(enrollment.formatted()) students — fostering \(size == "Small" ? "close-knit mentorship" : "diverse connections")."
            ))
        }

        // Acceptance rate & test policy
        if let rate = c.acceptanceRate {
            let pct = Int(rate * 100)
            let testNote = c.personality?.testPolicy ?? c.testingPolicy ?? "Test policy varies"
            points.append(TalkingPoint(
                icon: "chart.bar",
                title: "Selectivity & Testing",
                detail: "\(pct)% acceptance rate. \(testNote)."
            ))
        }

        // Archetype quote
        if let personality = c.personality, let quote = personality.quote {
            points.append(TalkingPoint(
                icon: "quote.opening",
                title: "School Character",
                detail: "\"\(quote)\""
            ))
        }

        talkingPoints = points
    }

    // MARK: - Generate Essay Outline

    func generateOutline() {
        guard let c = college else { return }
        isGenerating = true

        // Simulate async generation (TODO: Gemini API later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            let studentName = studentProfile.map { "\($0.firstName)" } ?? "I"
            let career = studentProfile?.careerPath ?? "my academic interests"
            let activities = studentProfile?.extracurriculars.prefix(2).joined(separator: " and ") ?? "my extracurricular involvement"
            let city = c.city ?? "its campus"
            let programs = c.programs.prefix(2).joined(separator: " and ")
            let cultureWords = c.personality?.cultureKeywords.prefix(2).joined(separator: " and ") ?? "academic excellence"
            let acceptanceStr = c.acceptanceRate.map { "\(Int($0 * 100))% acceptance rate" } ?? "selective admissions"
            let sizeDesc = c.sizeCategory ?? "vibrant"
            let archetype = c.personality?.archetypeName ?? ""

            let para1 = """
            The first time I explored \(c.name), I was struck by \
            \(archetype.isEmpty ? "its unique character" : "its identity as \"\(archetype)\""). \
            With \(acceptanceStr) and a \(sizeDesc.lowercased()) campus in \(city), \
            \(c.name) stands out not just for its academics but for the kind of community it builds. \
            \(programs.isEmpty ? "Its diverse program offerings" : "Programs like \(programs)") \
            immediately caught my attention as a place where I could thrive.
            """

            let para2 = """
            My passion for \(career) aligns perfectly with what \(c.name) offers. \
            \(programs.isEmpty ? "The academic programs" : "Specifically, \(programs)") \
            would give me the foundation I need to pursue my goals. \
            The campus culture — described as \(cultureWords) — mirrors the kind of environment \
            where I do my best work. \(c.satAvg.map { "With an average SAT of \($0), I know " } ?? "")\
            I'll be surrounded by peers who push me to grow academically and personally.
            """

            let para3 = """
            Beyond academics, I'm eager to contribute to \(c.name)'s community through \
            \(activities.isEmpty ? "my unique experiences and perspectives" : activities). \
            \(studentProfile?.archetypeTraits.first.map { "As someone who is \($0.lowercased()), " } ?? "")\
            I see myself not just benefiting from \(c.name)'s resources but actively enriching \
            the campus through leadership, collaboration, and a genuine commitment to \
            \(cultureWords.isEmpty ? "making a difference" : cultureWords).
            """

            self.paragraphs = [
                EssayParagraph(
                    heading: "What Draws Me to \(c.name)",
                    placeholder: para1,
                    editedText: ""
                ),
                EssayParagraph(
                    heading: "How \(c.name) Aligns with My Goals",
                    placeholder: para2,
                    editedText: ""
                ),
                EssayParagraph(
                    heading: "What I'll Contribute",
                    placeholder: para3,
                    editedText: ""
                )
            ]
            self.isGenerating = false
            self.hasGenerated = true
        }
    }

    // MARK: - Copy to Clipboard

    func copyToClipboard() {
        let fullText = paragraphs.map { paragraph in
            let text = paragraph.editedText.isEmpty ? paragraph.placeholder : paragraph.editedText
            return text
        }.joined(separator: "\n\n")

        UIPasteboard.general.string = fullText
        copiedToClipboard = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.copiedToClipboard = false
        }
    }
}

// MARK: - Supporting Types

struct TalkingPoint: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

struct EssayParagraph: Identifiable {
    let id = UUID()
    let heading: String
    let placeholder: String
    var editedText: String
}
