import Foundation

// SiaEngine+Models — return types shared across SiaEngine, SiaEngine+Counselor,
// and all call sites. Kept separate to hold SiaEngine.swift under the 500-line
// file_length warning threshold.

// MARK: - Student surface return types

struct HomeCard: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var body: String
    var priority: SiaPriority
    var specialist: SessionType?
    var deepLink: String?
}

enum SiaPriority: String, Codable, Equatable {
    case critical
    case high
    case normal
    case low

    var rank: Int {
        switch self {
        case .critical: return 0
        case .high:     return 1
        case .normal:   return 2
        case .low:      return 3
        }
    }
}

struct CollegeInsight: Identifiable, Equatable {
    let id = UUID()
    var collegeId: String
    var message: String
    var kind: Kind
    enum Kind: String, Codable {
        case categoryShift, deadlineWarning, missingItem, listBalance, newSuggestion
    }
}

struct ActivityRecommendation: Identifiable, Equatable {
    let id = UUID()
    var category: String
    var suggestion: String
    var rationale: String
}

struct ClassPlan: Equatable {
    var tier: Tier
    var courses: [Course]
    var rationale: String
    var workloadEstimate: String
    enum Tier: String, Codable { case balanced, challenging, maximum }
}

struct SATInsight: Equatable {
    var trajectoryLabel: String
    var gapToTarget: Int
    var weakSections: [String]
    var nextDrillSuggestion: String
    var weeklyPlanAvailable: Bool
}

struct EssayInsight: Identifiable, Equatable {
    let id = UUID()
    var college: String
    var type: String
    var message: String
    var severity: SiaPriority
}

struct TimelineItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var date: Date
    var kind: String
    var status: Status
    enum Status: String, Codable { case done, upcoming, overdue }
}

struct FinancialAidInsight: Equatable {
    var headline: String
    var bullets: [String]
}

struct NotificationPayload: Equatable {
    var title: String
    var body: String
    var deepLink: String?
    var priority: SiaPriority
}
