import Foundation

// Persistent Sia memory across sessions. Updated at end of each chat via a
// secondary LLM call (see MemoryExtractor). Separate from ChatMessageModel,
// which stores raw transcripts; this is the distilled relationship state.

struct ConversationMemory: Codable, Equatable {
    var allTimeSummary: String
    var keyDecisions: [Decision]
    var openActions: [ActionItem]
    var completedActions: [ActionItem]
    var emotionalMoments: [EmotionalMoment]
    var learnedPreferences: [LearnedPreference]
    var sensitivities: [Sensitivity]
    var lastSessionSummary: String?
    var lastSessionDate: Date?
    var daysSinceLastSession: Int?
    var topicHistory: [String]

    static let empty = ConversationMemory(
        allTimeSummary: "",
        keyDecisions: [],
        openActions: [],
        completedActions: [],
        emotionalMoments: [],
        learnedPreferences: [],
        sensitivities: [],
        lastSessionSummary: nil,
        lastSessionDate: nil,
        daysSinceLastSession: nil,
        topicHistory: []
    )
}

struct Decision: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var description: String
}

struct ActionItem: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var description: String
    var status: String                  // "open", "completed", "abandoned"
    var completedDate: Date?
    var specialist: String?             // "counselor", "satTutor", "essayCoach", ...
}

struct EmotionalMoment: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var sentiment: String               // "frustrated", "excited", "anxious", "relieved"
    var description: String
}

struct LearnedPreference: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var description: String
    var observedCount: Int              // de-dup signal; higher = more confident
    var lastObserved: Date
}

struct Sensitivity: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var topic: String
    var description: String             // "don't bring up unless they do"
    var flaggedAt: Date
}

// MARK: - Extraction contract
// At end of each chat, AIService runs a secondary call with the full transcript
// and this JSON schema. Result is merged into the persisted ConversationMemory.

enum MemoryExtractor {

    static let systemPrompt = """
    You are a post-session analyzer. Read the conversation transcript and extract \
    structured memory items. Return ONLY valid JSON matching this schema. No prose.

    {
      "sessionSummary": "1 paragraph, 2-3 sentences max",
      "newDecisions":   [{"description": "..."}],
      "newActionItems": [{"description": "...", "specialist": "counselor|satTutor|essayCoach|interviewCoach|careerExplorer|classPlanner|scoreAdvisor|null"}],
      "completedActions": [{"description": "..."}],
      "emotionalMoments": [{"sentiment": "...", "description": "..."}],
      "learnedPreferences": [{"description": "..."}],
      "sensitivities":  [{"topic": "...", "description": "..."}],
      "topics": ["..."]
    }

    Rules:
    - Only include items that genuinely came up. Empty arrays are fine.
    - Decisions = concrete choices the student made ("Applying ED to RIT").
    - Action items = things the student said they'd do OR Sia assigned.
    - Preferences = communication style ("prefers short answers", "responds to humor").
      Do NOT restate profile data as preferences.
    - Sensitivities = topics the student flinched from or asked to avoid.
    """

    struct ExtractionResult: Codable {
        var sessionSummary: String
        var newDecisions: [Item]
        var newActionItems: [ActionItemExtraction]
        var completedActions: [Item]
        var emotionalMoments: [EmotionalExtraction]
        var learnedPreferences: [Item]
        var sensitivities: [SensitivityExtraction]
        var topics: [String]

        struct Item: Codable { var description: String }
        struct ActionItemExtraction: Codable {
            var description: String
            var specialist: String?
        }
        struct EmotionalExtraction: Codable {
            var sentiment: String
            var description: String
        }
        struct SensitivityExtraction: Codable {
            var topic: String
            var description: String
        }
    }

    static func merge(
        into memory: ConversationMemory,
        extraction: ExtractionResult,
        now: Date = Date()
    ) -> ConversationMemory {
        var m = memory

        m.lastSessionSummary = extraction.sessionSummary
        m.lastSessionDate = now
        m.daysSinceLastSession = 0

        m.keyDecisions.append(contentsOf: extraction.newDecisions.map {
            Decision(date: now, description: $0.description)
        })

        m.openActions.append(contentsOf: extraction.newActionItems.map {
            ActionItem(date: now, description: $0.description, status: "open", completedDate: nil, specialist: $0.specialist)
        })

        // Close any matching open action items flagged as completed.
        for completed in extraction.completedActions {
            if let idx = m.openActions.firstIndex(where: { $0.description.caseInsensitiveCompare(completed.description) == .orderedSame }) {
                var item = m.openActions.remove(at: idx)
                item.status = "completed"
                item.completedDate = now
                m.completedActions.append(item)
            }
        }

        m.emotionalMoments.append(contentsOf: extraction.emotionalMoments.map {
            EmotionalMoment(date: now, sentiment: $0.sentiment, description: $0.description)
        })

        // Dedupe learned preferences by description; bump observedCount on re-observe.
        for pref in extraction.learnedPreferences {
            if let idx = m.learnedPreferences.firstIndex(where: { $0.description.caseInsensitiveCompare(pref.description) == .orderedSame }) {
                m.learnedPreferences[idx].observedCount += 1
                m.learnedPreferences[idx].lastObserved = now
            } else {
                m.learnedPreferences.append(
                    LearnedPreference(description: pref.description, observedCount: 1, lastObserved: now)
                )
            }
        }

        for s in extraction.sensitivities {
            if !m.sensitivities.contains(where: { $0.topic.caseInsensitiveCompare(s.topic) == .orderedSame }) {
                m.sensitivities.append(Sensitivity(topic: s.topic, description: s.description, flaggedAt: now))
            }
        }

        m.topicHistory.append(contentsOf: extraction.topics)
        if m.topicHistory.count > 200 { m.topicHistory.removeFirst(m.topicHistory.count - 200) }

        return m
    }
}
