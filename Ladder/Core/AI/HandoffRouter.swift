import Foundation

// Detects when Sia says she's handing off to a specialist and returns the target
// SessionType + a short summary that will be injected into the new specialist's
// system prompt. Matches the handoff phrases baked into Prompt 1 (Counselor) and
// echoed across the other prompts.
//
// Conservative by design: only routes on explicit handoff phrases. A general
// mention of "SAT" or "essay" in a counselor reply is NOT a handoff — we wait
// for the counselor to say "let me pull up your SAT Tutor" (etc).

enum HandoffRouter {

    struct Handoff: Equatable {
        let target: SessionType
        let summary: String
    }

    /// Returns the detected handoff, or nil if the message is a normal response.
    static func detect(in message: String) -> Handoff? {
        let lower = message.lowercased()
        for (phrases, target) in routes {
            for phrase in phrases where lower.contains(phrase) {
                return Handoff(
                    target: target,
                    summary: summary(for: target, from: message)
                )
            }
        }
        return nil
    }

    // Ordered matcher. First hit wins, so put more specific phrases first.
    private static let routes: [([String], SessionType)] = [
        (["sat tutor", "sat coach", "that's sat territory", "your sat prep"],          .satTutor),
        (["essay coach", "bring this to the essay", "essay lane"],                     .essayCoach),
        (["interview coach", "mock interview", "play the interviewer"],                .interviewCoach),
        (["career explorer", "rethinking your path", "wheel of career"],               .careerExplorer),
        (["class planner", "schedule planner"],                                        .classPlanner),
        (["score advisor", "gap between your profile", "score gap analysis"],          .scoreAdvisor)
    ]

    private static func summary(for target: SessionType, from message: String) -> String {
        let trimmed = message
            .replacingOccurrences(of: "\n", with: " ")
            .prefix(280)
        return """
        Handed off from Sia (Counselor mode) to \(target.specialistLabel).

        Counselor's last message: "\(trimmed)…"

        Pick up the thread — the student is expecting you to continue, not restart.
        """
    }
}
