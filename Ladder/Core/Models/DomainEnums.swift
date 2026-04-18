import Foundation

// MARK: - ApplicationState (state-machine enum, distinct from the AI-context
// payload struct `ApplicationState` in StudentContext.swift).

enum ApplicationState: String, CaseIterable {
    case planning
    case inProgress = "in_progress"
    case submitted
    case accepted
    case rejected
    case waitlisted
    case committed

    var label: String {
        switch self {
        case .planning:    return "Planning"
        case .inProgress:  return "In Progress"
        case .submitted:   return "Submitted"
        case .accepted:    return "Accepted"
        case .rejected:    return "Rejected"
        case .waitlisted:  return "Waitlisted"
        case .committed:   return "Committed"
        }
    }

    /// Forward-only transition rules. Returns true if `from → to` is allowed.
    static func canTransition(from: ApplicationState, to: ApplicationState) -> Bool {
        if from == to { return true }
        switch (from, to) {
        case (.planning, .inProgress),
             (.planning, .submitted),
             (.inProgress, .submitted),
             (.submitted, .accepted),
             (.submitted, .rejected),
             (.submitted, .waitlisted),
             (.waitlisted, .accepted),
             (.waitlisted, .rejected),
             (.accepted, .committed):
            return true
        default:
            return false
        }
    }
}

// MARK: - EssayState

enum EssayState: String, CaseIterable {
    case notStarted = "not_started"
    case drafting
    case reviewing
    case complete

    static func canTransition(from: EssayState, to: EssayState) -> Bool {
        if from == to { return true }
        switch (from, to) {
        case (.notStarted, .drafting),
             (.drafting, .reviewing),
             (.drafting, .complete),
             (.reviewing, .drafting),
             (.reviewing, .complete):
            return true
        default:
            return false
        }
    }
}

// MARK: - LORStatus

enum LORStatus: String, CaseIterable {
    case notRequested = "not_requested"
    case requested
    case inProgress = "in_progress"
    case submitted
    case received

    static func canTransition(from: LORStatus, to: LORStatus) -> Bool {
        if from == to { return true }
        switch (from, to) {
        case (.notRequested, .requested),
             (.requested, .inProgress),
             (.requested, .submitted),
             (.inProgress, .submitted),
             (.submitted, .received):
            return true
        default:
            return false
        }
    }
}

// MARK: - ChecklistStatus

enum ChecklistStatus: String, CaseIterable {
    case pending
    case inProgress = "in_progress"
    case completed
}

// MARK: - Validators

enum DomainValidator {
    static let validStates: Set<String> = [
        "AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA",
        "KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
        "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT",
        "VA","WA","WV","WI","WY","DC"
    ]

    /// Clamp grade to [9, 12]; log if clamped.
    static func clampedGrade(_ grade: Int) -> Int {
        if (9...12).contains(grade) { return grade }
        Log.warn("Grade \(grade) out of range [9,12]; clamping.")
        return max(9, min(12, grade))
    }

    static func isValidState(_ code: String?) -> Bool {
        guard let code = code?.trimmingCharacters(in: .whitespaces).uppercased(),
              !code.isEmpty else { return false }
        return validStates.contains(code)
    }

    /// Normalize a state code to a 2-letter uppercase US code, or nil if invalid.
    static func normalizedState(_ code: String?) -> String? {
        guard let raw = code?.trimmingCharacters(in: .whitespaces).uppercased(),
              !raw.isEmpty, validStates.contains(raw) else { return nil }
        return raw
    }

    /// SAT total score valid range: 400–1600, multiples of 10.
    static func isValidSATTotal(_ score: Int) -> Bool {
        score >= 400 && score <= 1600 && score % 10 == 0
    }

    /// SAT section (Math or Reading/Writing) valid range: 200–800, multiples of 10.
    static func isValidSATSection(_ score: Int) -> Bool {
        score >= 200 && score <= 800 && score % 10 == 0
    }

    /// GPA valid range: 0.0–5.0 (5.0 allows for weighted).
    static func isValidGPA(_ gpa: Double) -> Bool {
        gpa >= 0.0 && gpa <= 5.0
    }
}
