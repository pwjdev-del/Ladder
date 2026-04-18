import Foundation

// Snapshot of the student's school. Powers class planning, activity gap analysis,
// "what's offered here" answers. Populated from SchoolClubModel / SchoolSportModel /
// SchoolCalendarEventModel / admin-uploaded class catalog.

struct SchoolContext: Codable, Equatable {
    var name: String
    var city: String?
    var state: String
    var type: String?                  // "public", "charter", "private", "magnet"
    var classesOffered: [Course]
    var apClasses: [String]
    var honorsClasses: [String]
    var dualEnrollment: [String]
    var clubsOffered: [String]
    var athleticsOffered: [String]
    var keyDates: [SchoolDate]
    var counselors: [Counselor]
    var sisSystem: String?             // "Focus", "PowerSchool"
}

struct SchoolDate: Codable, Equatable {
    var title: String
    var date: Date
    var kind: String                   // "term_start", "term_end", "exam", "break", "graduation"
}

struct Counselor: Codable, Equatable {
    var name: String
    var email: String?
    var phone: String?
    var title: String?
}

extension SchoolContext {
    // Fallback when no school is configured — lets PromptBuilder keep running.
    static func unknown(state: String?) -> SchoolContext {
        SchoolContext(
            name: "Unknown school",
            city: nil,
            state: state ?? "",
            type: nil,
            classesOffered: [],
            apClasses: [],
            honorsClasses: [],
            dualEnrollment: [],
            clubsOffered: [],
            athleticsOffered: [],
            keyDates: [],
            counselors: [],
            sisSystem: nil
        )
    }
}
