import SwiftUI

// MARK: - Advisor Chat ViewModel

@Observable
final class AdvisorChatViewModel {

    var messages: [ChatBubble] = []
    var inputText = ""
    var isTyping = false
    var sessionType: SessionType = .advisor

    enum SessionType: String, CaseIterable {
        case advisor = "General Advisor"
        case essay = "Essay Review"
        case interview = "Mock Interview"
        case score = "Score Strategy"
    }

    // MARK: - Student Context (injected from live StudentProfileModel via configure(with:))

    var studentName: String = "Student"
    var studentGrade: Int = 10
    var studentGPA: Double = 0.0
    var studentSAT: Int = 0
    var studentCareerPath: String = "Not set"
    var studentSavedColleges: String = ""
    var isFirstGen: Bool = false

    func configure(with profile: StudentProfileModel?) {
        guard let p = profile else { return }
        studentName = p.firstName.isEmpty ? "Student" : p.firstName
        studentGrade = p.grade
        studentGPA = p.gpa ?? 0.0
        studentSAT = p.satScore ?? 0
        studentCareerPath = p.careerPath ?? "Not set"
        studentSavedColleges = p.savedCollegeIds.joined(separator: ", ")
        isFirstGen = p.isFirstGen
    }

    // MARK: - Quick Prompts

    var quickPrompts: [QuickPrompt] {
        [
            QuickPrompt(title: "College List", subtitle: "Help me build my list", icon: "building.columns", prompt: "Help me build a balanced college list with reach, match, and safety schools based on my profile."),
            QuickPrompt(title: "Essay Help", subtitle: "Review my essay", icon: "text.alignleft", prompt: "I need help brainstorming ideas for my Common App personal statement."),
            QuickPrompt(title: "SAT Strategy", subtitle: "Improve my score", icon: "chart.line.uptrend.xyaxis", prompt: "What's the best strategy to improve my SAT score? I'm currently scoring around \(studentSAT > 0 ? studentSAT : 1200)."),
            QuickPrompt(title: "Extracurriculars", subtitle: "Strengthen activities", icon: "star.circle", prompt: "How can I strengthen my extracurricular profile for college applications?"),
            QuickPrompt(title: "Financial Aid", subtitle: "Scholarship tips", icon: "dollarsign.circle", prompt: "What scholarships should I look into?\(isFirstGen ? " I'm a first-generation college student." : "")"),
            QuickPrompt(title: "Timeline", subtitle: "What to do now", icon: "calendar.badge.clock", prompt: "What should I be doing right now as a \(studentGrade)th grader to prepare for college?"),
        ]
    }

    // Static fallback for previews / places that access before configure() fires
    static let defaultQuickPrompts: [QuickPrompt] = [
        QuickPrompt(title: "College List", subtitle: "Help me build my list", icon: "building.columns", prompt: "Help me build a balanced college list with reach, match, and safety schools based on my profile."),
        QuickPrompt(title: "Essay Help", subtitle: "Review my essay", icon: "text.alignleft", prompt: "I need help brainstorming ideas for my Common App personal statement."),
        QuickPrompt(title: "SAT Strategy", subtitle: "Improve my score", icon: "chart.line.uptrend.xyaxis", prompt: "What's the best strategy to improve my SAT score?"),
        QuickPrompt(title: "Extracurriculars", subtitle: "Strengthen activities", icon: "star.circle", prompt: "How can I strengthen my extracurricular profile for college applications?"),
        QuickPrompt(title: "Financial Aid", subtitle: "Scholarship tips", icon: "dollarsign.circle", prompt: "What scholarships should I look into?"),
        QuickPrompt(title: "Timeline", subtitle: "What to do now", icon: "calendar.badge.clock", prompt: "What should I be doing right now to prepare for college?"),
    ]

    private func buildSystemPrompt() -> String {
        let name = studentName
        let grade = studentGrade
        let gpa = studentGPA
        let sat = studentSAT
        let careerPath = studentCareerPath
        let savedColleges = studentSavedColleges

        return """
        You are a personal college counselor for \(name), a \(grade)th grade student.

        Student profile:
        - GPA: \(gpa)
        - SAT: \(sat)
        - Career interest: \(careerPath)
        - Saved colleges: \(savedColleges)

        Always give SPECIFIC, ACTIONABLE advice with real deadlines.
        Frame everything as suggestions, never mandates.
        Reference the student's actual data — don't give generic advice.
        Keep responses concise (2-3 short paragraphs max).
        """
    }

    // MARK: - Send Message

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatBubble(role: .user, content: text))
        inputText = ""
        isTyping = true

        let systemPrompt = buildSystemPrompt()
        let history = messages.map { AIMessage(role: $0.role == .user ? "user" : "assistant", content: $0.content) }

        // Attempt live AI call; fall back to personalized mock on failure.
        Task {
            do {
                let response = try await AIService.shared.sendMessage(
                    messages: history,
                    systemPrompt: systemPrompt
                )
                messages.append(ChatBubble(role: .assistant, content: response))
            } catch {
                try? await Task.sleep(for: .seconds(1.0))
                let response = generateMockResponse(for: text)
                messages.append(ChatBubble(role: .assistant, content: response))
            }
            isTyping = false
        }
    }

    func sendQuickPrompt(_ prompt: QuickPrompt) {
        inputText = prompt.prompt
        sendMessage()
    }

    // MARK: - Mock Response Generator (personalized fallback)

    private func generateMockResponse(for input: String) -> String {
        let lower = input.lowercased()
        let name = studentName
        let gpa = studentGPA
        let sat = studentSAT
        let careerPath = studentCareerPath
        let savedColleges = studentSavedColleges
        let grade = studentGrade

        if lower.contains("college list") || lower.contains("balanced") {
            return """
            \(name), based on your \(gpa) GPA, \(sat) SAT, and interest in \(careerPath), here's how to frame your list around your saved schools (\(savedColleges)):

            **Reach (2-3):** Stanford and MIT sit above your current stats — keep them as aspirational targets and lean into essays that reflect your \(careerPath) focus.

            **Match (3-4):** RIT aligns well with your profile. Add 2-3 more schools where your \(gpa) GPA and \(sat) SAT land in the middle 50%.

            **Safety (2-3):** Pick schools where your stats exceed the average — but only ones you'd genuinely attend.

            Want me to suggest specific match/safety schools that fit \(careerPath)?
            """
        } else if lower.contains("essay") || lower.contains("statement") {
            return """
            \(name), since you're targeting \(savedColleges) and leaning toward \(careerPath), your personal statement should show *why* that path — not just *that* it's your path.

            1. **Be authentic** — a specific moment that pulled you toward \(careerPath) beats a generic "I want to help people."
            2. **Show, don't tell** — use scenes and details, not adjectives.
            3. **Reflect on growth** — admissions wants self-awareness, especially at reach schools like MIT and Stanford.

            Want to brainstorm a topic tied to your \(careerPath) interest?
            """
        } else if lower.contains("sat") || lower.contains("score") {
            return """
            \(name), you're at \(sat) — solid, but reach schools like Stanford and MIT from your saved list typically want 1500+. Here's a targeted plan:

            **Weeks 1-2:** Full diagnostic to find your weakest section.
            **Weeks 3-6:** 30-45 min daily on that section. Khan Academy is free and excellent.
            **Weeks 7-8:** 2-3 full timed practice tests.

            Consistent prep usually adds 100-200 points — that would put you near 1400-1450, much stronger for your \(careerPath) target schools. Want a weekly study plan?
            """
        } else if lower.contains("extracurricular") || lower.contains("activities") {
            return """
            \(name), for \(careerPath) applicants, depth beats breadth — especially at RIT, MIT, and Stanford. Given your \(gpa) GPA you have capacity to go deeper on 2-3 activities.

            **Go Deep:** Aim for leadership in activities tied to \(careerPath) — hospital volunteering, research, or a health-focused club.
            **Show Impact:** Start a project or organize an event. Measurable outcomes matter.
            **Connect to Goals:** For \(careerPath), shadowing a doctor or clinical volunteering is gold.

            What are you currently involved in? I can suggest how to deepen each one.
            """
        } else if lower.contains("timeline") || lower.contains("10th") || lower.contains("now") {
            return """
            \(name), as a \(grade)th grader interested in \(careerPath), here's what matters most right now:

            **This semester:** Protect your \(gpa) GPA — sophomore grades weigh heavily. Start SAT prep to build on your \(sat) baseline.
            **This summer:** Land a \(careerPath)-aligned experience (hospital volunteering, research, or a pre-med summer program).
            **Next fall (11th):** Take the SAT for real, start narrowing your list beyond \(savedColleges).

            Want me to break any of these into weekly steps?
            """
        } else {
            return """
            Great question, \(name). With your \(gpa) GPA, \(sat) SAT, and interest in \(careerPath), I can give you advice tailored to your actual situation — not generic tips.

            I can help you with:
            - Refining your list around \(savedColleges)
            - Essays that highlight your \(careerPath) focus
            - SAT strategy to push past \(sat)
            - Extracurriculars that strengthen a \(careerPath) application
            - Scholarship and financial aid options
            - A \(grade)th grade timeline

            What do you want to tackle first?
            """
        }
    }
}

// MARK: - Models

struct ChatBubble: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()

    enum Role {
        case user, assistant
    }
}

struct QuickPrompt: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let prompt: String
}
