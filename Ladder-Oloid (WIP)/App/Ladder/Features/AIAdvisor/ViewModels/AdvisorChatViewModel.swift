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

    // MARK: - Quick Prompts

    static let quickPrompts: [QuickPrompt] = [
        QuickPrompt(title: "College List", subtitle: "Help me build my list", icon: "building.columns", prompt: "Help me build a balanced college list with reach, match, and safety schools based on my profile."),
        QuickPrompt(title: "Essay Help", subtitle: "Review my essay", icon: "text.alignleft", prompt: "I need help brainstorming ideas for my Common App personal statement."),
        QuickPrompt(title: "SAT Strategy", subtitle: "Improve my score", icon: "chart.line.uptrend.xyaxis", prompt: "What's the best strategy to improve my SAT score? I'm currently scoring around 1200."),
        QuickPrompt(title: "Extracurriculars", subtitle: "Strengthen activities", icon: "star.circle", prompt: "How can I strengthen my extracurricular profile for college applications?"),
        QuickPrompt(title: "Financial Aid", subtitle: "Scholarship tips", icon: "dollarsign.circle", prompt: "What scholarships should I look into? I'm a first-generation college student."),
        QuickPrompt(title: "Timeline", subtitle: "What to do now", icon: "calendar.badge.clock", prompt: "What should I be doing right now as a 10th grader to prepare for college?"),
    ]

    // MARK: - Send Message

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatBubble(role: .user, content: text))
        inputText = ""
        isTyping = true

        // Simulate AI response
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            let response = generateMockResponse(for: text)
            messages.append(ChatBubble(role: .assistant, content: response))
            isTyping = false
        }
    }

    func sendQuickPrompt(_ prompt: QuickPrompt) {
        inputText = prompt.prompt
        sendMessage()
    }

    // MARK: - Mock Response Generator

    private func generateMockResponse(for input: String) -> String {
        let lower = input.lowercased()

        if lower.contains("college list") || lower.contains("balanced") {
            return """
            Great question! Based on your profile, here's a framework for building your list:

            **Reach Schools (2-3):**
            Schools where your stats are below the average admitted student. These are aspirational but possible.

            **Match Schools (3-4):**
            Schools where your stats align with the middle 50% of admitted students. You have a solid chance here.

            **Safety Schools (2-3):**
            Schools where your stats exceed the average. These should still be schools you'd be happy attending.

            Would you like me to suggest specific schools based on your interests and GPA?
            """
        } else if lower.contains("essay") || lower.contains("statement") {
            return """
            The personal statement is your chance to show who you are beyond numbers. Here are some tips:

            1. **Be authentic** - Write about something genuinely meaningful to you
            2. **Show, don't tell** - Use specific stories and details
            3. **Reflect on growth** - Admissions wants to see self-awareness
            4. **Start strong** - Your opening should hook the reader

            Common topics that work well: a challenge you overcame, a passion project, a moment of realization, or a unique perspective you bring.

            Would you like to brainstorm a specific topic together?
            """
        } else if lower.contains("sat") || lower.contains("score") {
            return """
            Here's a proven SAT improvement strategy:

            **Weeks 1-2: Diagnostic**
            Take a full practice test to identify weak areas.

            **Weeks 3-6: Targeted Practice**
            Focus on your weakest sections. Khan Academy's free SAT prep is excellent.

            **Weeks 7-8: Full Practice Tests**
            Take 2-3 more practice tests under real conditions.

            **Key Tips:**
            - Study 30-45 min daily rather than long cramming sessions
            - Review every wrong answer to understand WHY you missed it
            - Fee waivers are available if you're on free/reduced lunch

            Most students improve 100-200 points with consistent prep. Would you like a detailed weekly study plan?
            """
        } else if lower.contains("extracurricular") || lower.contains("activities") {
            return """
            Quality over quantity! Colleges want to see depth, not a long list. Here's how to strengthen your profile:

            **Go Deep:**
            Pick 2-3 activities you're passionate about and aim for leadership roles.

            **Show Impact:**
            Start a project, organize an event, or create something meaningful.

            **Connect to Your Goals:**
            If you're interested in medicine, volunteer at a hospital or shadow a doctor.

            **Categories to Cover:**
            - Community service
            - Leadership roles
            - Academic enrichment
            - Personal interests/hobbies

            What activities are you currently involved in? I can help you think about how to deepen your involvement.
            """
        } else {
            return """
            That's a great question! As your AI college advisor, I'm here to help you navigate every step of the college preparation journey.

            I can help you with:
            - Building and refining your college list
            - Essay brainstorming and review
            - SAT/ACT preparation strategies
            - Extracurricular planning
            - Scholarship and financial aid guidance
            - Application timeline management

            What specific area would you like to focus on today?
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
