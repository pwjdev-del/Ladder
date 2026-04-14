import Foundation

struct StateRequirements {
    let totalCredits: Double
    let math: Double
    let english: Double
    let science: Double
    let socialStudies: Double
    let foreignLanguage: Double
    let pe: Double
    let arts: Double
    let electives: Double
    let standardizedTest: String?  // e.g. "Florida Civic Literacy Exam"
    let communityServiceHours: Int?
}

enum StateRequirementsEngine {
    /// Returns graduation requirements for a given US state code (FL, CA, TX, etc.)
    static func requirements(for stateCode: String) -> StateRequirements {
        switch stateCode.uppercased() {
        case "FL":
            return StateRequirements(totalCredits: 24, math: 4, english: 4, science: 3, socialStudies: 3, foreignLanguage: 2, pe: 1, arts: 1, electives: 6, standardizedTest: "Florida Civic Literacy Exam", communityServiceHours: 75)
        case "CA":
            return StateRequirements(totalCredits: 22, math: 2, english: 3, science: 2, socialStudies: 3, foreignLanguage: 1, pe: 2, arts: 1, electives: 8, standardizedTest: nil, communityServiceHours: nil)
        case "TX":
            return StateRequirements(totalCredits: 26, math: 4, english: 4, science: 4, socialStudies: 3, foreignLanguage: 2, pe: 1, arts: 1, electives: 7, standardizedTest: "STAAR EOC", communityServiceHours: nil)
        case "NY":
            return StateRequirements(totalCredits: 22, math: 3, english: 4, science: 3, socialStudies: 4, foreignLanguage: 1, pe: 2, arts: 1, electives: 4, standardizedTest: "Regents", communityServiceHours: nil)
        default:
            return StateRequirements(totalCredits: 24, math: 3, english: 4, science: 3, socialStudies: 3, foreignLanguage: 2, pe: 1, arts: 1, electives: 7, standardizedTest: nil, communityServiceHours: nil)
        }
    }

    static var allStates: [(code: String, name: String)] {
        [("FL","Florida"), ("CA","California"), ("TX","Texas"), ("NY","New York"), ("PA","Pennsylvania"), ("IL","Illinois"), ("OH","Ohio"), ("GA","Georgia"), ("NC","North Carolina"), ("MI","Michigan"), ("NJ","New Jersey"), ("VA","Virginia"), ("WA","Washington"), ("AZ","Arizona"), ("MA","Massachusetts"), ("TN","Tennessee"), ("IN","Indiana"), ("MO","Missouri"), ("MD","Maryland"), ("WI","Wisconsin"), ("CO","Colorado"), ("MN","Minnesota"), ("SC","South Carolina"), ("AL","Alabama"), ("LA","Louisiana"), ("KY","Kentucky"), ("OR","Oregon"), ("OK","Oklahoma"), ("CT","Connecticut"), ("UT","Utah"), ("IA","Iowa"), ("NV","Nevada"), ("AR","Arkansas"), ("MS","Mississippi"), ("KS","Kansas"), ("NM","New Mexico"), ("NE","Nebraska"), ("WV","West Virginia"), ("ID","Idaho"), ("HI","Hawaii"), ("NH","New Hampshire"), ("ME","Maine"), ("MT","Montana"), ("RI","Rhode Island"), ("DE","Delaware"), ("SD","South Dakota"), ("ND","North Dakota"), ("AK","Alaska"), ("VT","Vermont"), ("WY","Wyoming")]
    }
}
