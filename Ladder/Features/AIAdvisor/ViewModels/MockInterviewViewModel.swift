import SwiftUI

// MARK: - Mock Interview ViewModel

@Observable
final class MockInterviewViewModel {

    // MARK: - State

    var selectedCollege: String = ""
    var interviewType: InterviewType = .admissions
    var phase: InterviewPhase = .setup

    var questions: [InterviewQuestion] = []
    var currentQuestionIndex = 0
    var elapsedSeconds = 0
    var timerActive = false

    var overallScore = 0
    var contentScore = 0
    var clarityScore = 0
    var confidenceScore = 0
    var improvements: [String] = []

    // MARK: - Types

    enum InterviewType: String, CaseIterable, Identifiable {
        case admissions = "Admissions"
        case scholarship = "Scholarship"
        case alumni = "Alumni"

        var id: String { rawValue }
    }

    enum InterviewPhase {
        case setup
        case inProgress
        case review
        case results
    }

    struct InterviewQuestion: Identifiable {
        let id = UUID()
        let text: String
        let category: String // "Behavioral", "Academic", "Personal"
        var answer: String = ""
        var score: Int = 0
        var feedback: String = ""
        var strength: String = ""
        var improvement: String = ""
        var suggestedResponse: String = ""
    }

    // MARK: - Computed

    var currentQuestion: InterviewQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progressFraction: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var timerString: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var collegeSuggestions: [String] {
        ["University of Florida", "FSU", "UCF", "University of Miami", "Georgia Tech",
         "Emory University", "Stanford University", "MIT", "Duke University"]
    }

    // MARK: - Actions

    func startInterview() {
        generateQuestions()
        phase = .inProgress
        currentQuestionIndex = 0
        elapsedSeconds = 0
        timerActive = true
    }

    func updateAnswer(_ text: String) {
        guard currentQuestionIndex < questions.count else { return }
        questions[currentQuestionIndex].answer = text
    }

    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }

    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }

    func submitInterview() {
        timerActive = false
        generateFeedback()
        phase = .results
    }

    func retryInterview() {
        phase = .setup
        questions = []
        currentQuestionIndex = 0
        overallScore = 0
        contentScore = 0
        clarityScore = 0
        confidenceScore = 0
        improvements = []
    }

    // MARK: - Mock Question Generation

    private func generateQuestions() {
        let college = selectedCollege.isEmpty ? "the university" : selectedCollege

        switch interviewType {
        case .admissions:
            questions = [
                InterviewQuestion(text: "Tell me about a challenge you've faced and how you overcame it.", category: "Behavioral"),
                InterviewQuestion(text: "Why are you interested in \(college)?", category: "Personal"),
                InterviewQuestion(text: "What do you plan to study and why?", category: "Academic"),
                InterviewQuestion(text: "Describe a time you demonstrated leadership.", category: "Behavioral"),
                InterviewQuestion(text: "What will you contribute to our campus community?", category: "Personal")
            ]
        case .scholarship:
            questions = [
                InterviewQuestion(text: "What are your long-term career goals?", category: "Personal"),
                InterviewQuestion(text: "How has your background shaped who you are?", category: "Behavioral"),
                InterviewQuestion(text: "Describe your most meaningful extracurricular activity.", category: "Academic"),
                InterviewQuestion(text: "How would this scholarship impact your education?", category: "Personal"),
                InterviewQuestion(text: "What does community service mean to you?", category: "Behavioral"),
                InterviewQuestion(text: "Tell me about a time you failed and what you learned.", category: "Behavioral")
            ]
        case .alumni:
            questions = [
                InterviewQuestion(text: "Walk me through a typical day in your life.", category: "Personal"),
                InterviewQuestion(text: "What book, podcast, or experience has changed your perspective?", category: "Personal"),
                InterviewQuestion(text: "If you could solve one problem in your community, what would it be?", category: "Behavioral"),
                InterviewQuestion(text: "What excites you most about the next four years?", category: "Academic"),
                InterviewQuestion(text: "Is there anything else you'd like the admissions committee to know?", category: "Personal")
            ]
        }
    }

    // MARK: - Mock Feedback Generation

    private func generateFeedback() {
        for i in 0..<questions.count {
            let answerLength = questions[i].answer.trimmingCharacters(in: .whitespacesAndNewlines).count
            let baseScore = min(max(answerLength / 3, 40), 95)
            questions[i].score = baseScore

            if answerLength < 20 {
                questions[i].feedback = "Your answer was very brief. Try to provide more detail and specific examples."
                questions[i].strength = "You addressed the topic."
                questions[i].improvement = "Elaborate with a specific story using the STAR method (Situation, Task, Action, Result)."
                questions[i].suggestedResponse = "A strong answer would include a specific example from your experience, describe the challenge, your actions, and the outcome."
            } else if answerLength < 100 {
                questions[i].feedback = "Good start, but could use more depth. Specific examples make answers memorable."
                questions[i].strength = "You showed understanding of the question."
                questions[i].improvement = "Add quantifiable results and connect your answer to your goals."
                questions[i].suggestedResponse = "Try leading with the most impactful detail, then explain the context and what you learned."
            } else {
                questions[i].feedback = "Strong, detailed response with good structure."
                questions[i].strength = "Excellent use of specific examples and clear communication."
                questions[i].improvement = "Consider tightening your response to stay under 2 minutes when spoken."
                questions[i].suggestedResponse = "Your answer demonstrates strong self-awareness. Keep the structure and consider varying your opening."
            }
        }

        let scores = questions.map(\.score)
        overallScore = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
        contentScore = min(overallScore + Int.random(in: -5...8), 100)
        clarityScore = min(overallScore + Int.random(in: -8...5), 100)
        confidenceScore = min(overallScore + Int.random(in: -3...6), 100)

        improvements = [
            "Practice the STAR method for behavioral questions to add structure.",
            "Add more specific examples with real numbers to quantify your impact.",
            "Connect each answer back to why this specific school is your fit."
        ]
    }
}
