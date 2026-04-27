import Foundation

// The 7 Sia modes. Each is a different "hat" on the same Sia personality.
// The 8th surface (ambient nudges) is handled by SiaEngine, not a session type.

enum SessionType: String, Codable, CaseIterable {
    case counselor          // general conversation, relationship holder, router
    case satTutor
    case essayCoach
    case interviewCoach
    case careerExplorer
    case classPlanner
    case scoreAdvisor       // college-score gap analysis

    var displayName: String {
        switch self {
        case .counselor:        return "Sia"
        case .satTutor:         return "Sia — SAT Tutor"
        case .essayCoach:       return "Sia — Essay Coach"
        case .interviewCoach:   return "Sia — Interview Coach"
        case .careerExplorer:   return "Sia — Career Explorer"
        case .classPlanner:     return "Sia — Class Planner"
        case .scoreAdvisor:     return "Sia — Score Advisor"
        }
    }

    // The specialist name Sia uses when she "puts on the hat."
    var specialistLabel: String {
        switch self {
        case .counselor:        return "Counselor"
        case .satTutor:         return "SAT Tutor"
        case .essayCoach:       return "Essay Coach"
        case .interviewCoach:   return "Interview Coach"
        case .careerExplorer:   return "Career Explorer"
        case .classPlanner:     return "Class Planner"
        case .scoreAdvisor:     return "Score Advisor"
        }
    }
}
