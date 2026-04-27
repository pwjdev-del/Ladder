import Foundation

// Snapshot of the student's in-app behavior. Powers blind-spot detection,
// nudge adaptation ("they always dismiss volunteer nudges — stop sending"),
// and sentiment-aware tone shifts. Populated by BehaviorTracker.

struct BehaviorSignals: Codable, Equatable {
    // Usage
    var lastLogin: Date?
    var loginStreak: Int
    var avgSessionsPerWeek: Double
    var avgSessionMinutes: Double
    var topScreens: [String]
    var leastVisitedScreens: [String]
    var neverOpened: [String]

    // Engagement with Sia's suggestions
    var nudgesShown: Int
    var nudgesTapped: Int
    var nudgesDismissed: Int
    var nudgeTapRate: Double            // 0.0 - 1.0
    var ignoredNudgeTopics: [String]    // topics consistently dismissed

    // What they talk / don't talk about
    var topChatTopics: [String]
    var blindSpotTopics: [String]       // likely-relevant topics never raised
    var recentQuestions: [String]       // last 5

    // Follow-through
    var actionsCompleted: Int
    var actionsIgnored: Int

    // Progress snapshot
    var satTrend: String                // "improving", "plateauing", "declining", "no data"
    var gpaTrend: String
    var essayDraftsCount: Int
    var collegeListGrowth: String       // "added 3, removed 1 (30d)"
    var volunteerHoursThisMonth: Double
    var checklistCompletedThisWeek: Int

    // Emotional signals
    var sentimentTrend: String          // "positive", "neutral", "declining"
    var earlyExits: Int                 // sessions ended < 30s
    var repeatedQuestions: [String]     // confusion signal
    var sessionGaps: [Int]              // days between last N sessions

    static let empty = BehaviorSignals(
        lastLogin: nil,
        loginStreak: 0,
        avgSessionsPerWeek: 0,
        avgSessionMinutes: 0,
        topScreens: [],
        leastVisitedScreens: [],
        neverOpened: [],
        nudgesShown: 0,
        nudgesTapped: 0,
        nudgesDismissed: 0,
        nudgeTapRate: 0,
        ignoredNudgeTopics: [],
        topChatTopics: [],
        blindSpotTopics: [],
        recentQuestions: [],
        actionsCompleted: 0,
        actionsIgnored: 0,
        satTrend: "no data",
        gpaTrend: "no data",
        essayDraftsCount: 0,
        collegeListGrowth: "",
        volunteerHoursThisMonth: 0,
        checklistCompletedThisWeek: 0,
        sentimentTrend: "neutral",
        earlyExits: 0,
        repeatedQuestions: [],
        sessionGaps: []
    )
}
