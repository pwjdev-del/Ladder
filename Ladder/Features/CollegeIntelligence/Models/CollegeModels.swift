import Foundation
import SwiftData

// MARK: - College (6,500+ schools from College Scorecard)

@Model
final class CollegeModel {
    @Attribute(.unique) var scorecardId: Int?
    var supabaseId: String?
    var name: String
    var city: String?
    var state: String?
    var latitude: Double?
    var longitude: Double?
    var institutionType: String? // "Public", "Private nonprofit", "Private for-profit"
    var sizeCategory: String? // "Small", "Medium", "Large"
    var acceptanceRate: Double?
    var inStateTuition: Int?
    var outStateTuition: Int?
    var roomAndBoard: Int?
    var enrollment: Int?
    var satAvg: Int?
    var satMath25: Int?
    var satMath75: Int?
    var satReading25: Int?
    var satReading75: Int?
    var actAvg: Int?
    var completionRate: Double?
    var retentionRate: Double?
    var medianEarnings: Int?
    var websiteURL: String?
    var imageURL: String?
    var region: String?
    var isHBCU: Bool = false
    var programs: [String] = []
    var lastSyncedAt: Date?

    @Relationship(deleteRule: .cascade) var personality: CollegePersonalityModel?
    @Relationship(deleteRule: .cascade) var deadlines: [CollegeDeadlineModel] = []

    init(name: String) {
        self.name = name
    }
}

// MARK: - College Personality (AI-generated archetype)

@Model
final class CollegePersonalityModel {
    var archetypeName: String // "The Builder/Maker"
    var archetypeDescription: String?
    var traits: [String] = [] // ["Hands-on", "Co-op focused"]
    var cultureKeywords: [String] = []
    var matchExplanation: String?
    var optimalStudentTypes: [String] = []
    var quote: String?

    // CDS Section C7 data
    var rigorImportance: String? // "Very Important", "Important", "Considered", "Not Considered"
    var gpaImportance: String?
    var testScoreImportance: String?
    var essayImportance: String?
    var extracurricularImportance: String?
    var interviewImportance: String?
    var demonstratedInterestImportance: String?
    var firstGenImportance: String?
    var legacyImportance: String?

    var testPolicy: String? // "Required", "Test-optional", "Test-blind"

    var generatedAt: Date?

    var college: CollegeModel?

    init(archetypeName: String) {
        self.archetypeName = archetypeName
        self.generatedAt = Date()
    }
}

// MARK: - College Deadline (scraped + crowdsourced)

@Model
final class CollegeDeadlineModel {
    var deadlineType: String // "Early Action", "Early Decision", "Regular Decision", "Rolling"
    var date: Date?
    var applicationPlatforms: [String] = [] // ["Common App", "Coalition"]
    var testingPolicy: String?
    var transcriptRequirement: String? // "Official", "Self-Reported SSAR"
    var source: String? // "firecrawl", "crowdsource", "manual"
    var cycleYear: Int?

    var college: CollegeModel?

    init(deadlineType: String) {
        self.deadlineType = deadlineType
    }
}
