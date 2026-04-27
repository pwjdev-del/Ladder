import Foundation

// Codable snapshot of the student used by PromptBuilder to render every AI prompt.
// Built from StudentProfileModel + related SwiftData models at prompt assembly time.
// Separate from the SwiftData @Model so it can be serialized, diffed, cached, and logged.

struct StudentContext: Codable, Equatable {
    // Identity
    var name: String
    var preferredName: String?
    var pronouns: String?
    var grade: Int
    var age: Int?
    var state: String?
    var firstGen: Bool
    var homeLanguage: String?
    var siblingsCollegeStatus: String?

    // Academic
    var gpaUnweighted: Double?
    var gpaWeighted: Double?
    var classRank: String?
    var gpaTrend: String?
    var strongSubjects: [String]
    var weakSubjects: [String]
    var currentClasses: [Course]
    var pastTranscript: [TranscriptEntry]
    var advancedCourses: [String]
    var apExamScores: [APExamScore]

    // Testing
    var satScores: [SATScore]
    var latestSAT: Int?
    var latestSATDate: Date?
    var satSectionBreakdown: SATSectionBreakdown?
    var satTrajectory: String?
    var targetSAT: Int?
    var nextTestDate: Date?
    var practiceTestHistory: [PracticeTest]
    var feeWaiverEligible: Bool
    var feeWaiverUsed: Bool

    // Career / Major
    var careerPath: String?
    var intendedMajor: String?
    var careerQuizHistory: [CareerQuizResult]
    var careerPathChanges: [CareerPathChange]
    var familyCareerExpectations: String?
    var hobbies: [String]

    // Activities
    var volunteering: [Activity]
    var volunteerHours: Double
    var clubs: [ClubActivity]
    var jobs: [JobActivity]
    var athletics: [AthleticActivity]
    var careerElectives: [Activity]
    var awards: [String]
    var leadershipPositions: [String]
    var ecTierAssessment: String?

    // Colleges
    var savedColleges: [SavedCollege]
    var removedColleges: [RemovedCollege]
    var applicationStatus: [ApplicationStatus]
    var essays: [EssayStatus]
    var personalStatementStatus: String?
    var recLetters: [RecLetterStatus]

    // Financial
    var fafsaStatus: String?
    var cssProfileStatus: String?
    var familyFinancialContext: String?
    var aidPackages: [AidPackage]

    // Florida-specific
    var brightFuturesStatus: BrightFuturesStatus?
}

// MARK: - Supporting types

struct Course: Codable, Equatable {
    var name: String
    var level: String  // "AP", "Honors", "DE", "Regular"
    var period: Int?
    var grade: String?  // letter or percent
}

struct TranscriptEntry: Codable, Equatable {
    var year: String  // "9th", "10th", ...
    var term: String  // "Fall", "Spring", "Full Year"
    var course: String
    var grade: String
    var credits: Double?
}

struct APExamScore: Codable, Equatable {
    var exam: String
    var score: Int  // 1-5
    var date: Date?
}

struct SATScore: Codable, Equatable {
    var date: Date
    var total: Int
    var readingWriting: Int?
    var math: Int?
    var isPractice: Bool
}

struct SATSectionBreakdown: Codable, Equatable {
    // Reading & Writing
    var craftStructure: Int?
    var infoIdeas: Int?
    var standardEnglish: Int?
    var expression: Int?
    // Math
    var algebra: Int?
    var advancedMath: Int?
    var psda: Int?          // Problem Solving & Data Analysis
    var geomTrig: Int?
}

struct PracticeTest: Codable, Equatable {
    var date: Date
    var total: Int
    var notes: String?
}

struct CareerQuizResult: Codable, Equatable {
    var date: Date
    var topResult: String
    var secondaryResult: String?
    var hollandCode: String?  // e.g. "RIA"
}

struct CareerPathChange: Codable, Equatable {
    var date: Date
    var from: String
    var to: String
}

struct Activity: Codable, Equatable {
    var name: String
    var role: String?
    var hoursPerWeek: Double?
    var startDate: Date?
    var endDate: Date?
    var description: String?
}

struct ClubActivity: Codable, Equatable {
    var name: String
    var role: String?
    var yearsIn: Int
    var leadershipLevel: String?  // "member", "officer", "president"
}

struct JobActivity: Codable, Equatable {
    var title: String
    var employer: String
    var hoursPerWeek: Double
    var startDate: Date
    var endDate: Date?
}

struct AthleticActivity: Codable, Equatable {
    var sport: String
    var level: String  // "JV", "Varsity", "Club"
    var yearsIn: Int
    var awards: [String]
}

struct SavedCollege: Codable, Equatable {
    var id: String
    var name: String
    var category: String  // "reach", "target", "safety"
    var interestLevel: Int  // 1-5
    var visited: Bool
    var infoSession: Bool
    var applied: Bool
    var status: String?  // "planning", "submitted", "accepted", "rejected", "waitlisted"
}

struct RemovedCollege: Codable, Equatable {
    var name: String
    var removedAt: Date
    var reason: String?
}

struct ApplicationStatus: Codable, Equatable {
    var college: String
    var type: String  // "EA", "ED", "RD", "Rolling"
    var status: String
    var deadline: Date?
    var submittedAt: Date?
}

struct EssayStatus: Codable, Equatable {
    var college: String
    var type: String  // "Personal Statement", "Why Us", "Supplement"
    var prompt: String?
    var draftNumber: Int
    var wordCount: Int
    var wordLimit: Int?
    var lastEdited: Date?
    var latestFeedback: String?
}

struct RecLetterStatus: Codable, Equatable {
    var teacherName: String
    var subject: String?
    var requestedAt: Date?
    var status: String  // "pending", "requested", "submitted"
}

struct AidPackage: Codable, Equatable {
    var college: String
    var totalCost: Double
    var grants: Double
    var loans: Double
    var workStudy: Double
    var netCost: Double
}

struct BrightFuturesStatus: Codable, Equatable {
    var level: String  // "FAS", "FMS", "Not yet eligible"
    var gpaMet: Bool
    var satMet: Bool
    var hoursMet: Bool
    var satGapToFAS: Int?
    var hoursGapToFAS: Double?
}
