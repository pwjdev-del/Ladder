import Foundation

// MARK: - State Requirements Engine
// Provides state-specific graduation requirements, merit scholarships, and special rules

@Observable
final class StateRequirementsEngine {
    static let shared = StateRequirementsEngine()
    private init() {}

    struct StateRequirements {
        let state: String
        let graduationCredits: Int
        let creditRequirements: [String: Int]  // "English": 4, "Math": 4, etc.
        let meritScholarship: MeritScholarship?
        let specialRules: [String]
    }

    struct MeritScholarship {
        let name: String
        let fullAmount: String
        let requirements: String  // e.g., "3.5 GPA + 1330 SAT + 100 service hours"
        let partialName: String?
        let partialRequirements: String?
    }

    func requirements(for state: String) -> StateRequirements {
        switch state.uppercased() {
        case "FL", "FLORIDA":
            return StateRequirements(
                state: "Florida",
                graduationCredits: 24,
                creditRequirements: [
                    "English": 4, "Math": 4, "Science": 3,
                    "Social Studies": 3, "World Language": 2,
                    "Fine Arts": 1, "Physical Education": 1, "Electives": 6
                ],
                meritScholarship: MeritScholarship(
                    name: "Bright Futures FAS",
                    fullAmount: "100% tuition at FL public universities",
                    requirements: "3.5 weighted GPA + 1330 SAT/29 ACT + 100 community service hours",
                    partialName: "Bright Futures FMS",
                    partialRequirements: "3.0 weighted GPA + 1210 SAT/25 ACT + 75 community service hours = 75% tuition"
                ),
                specialRules: [
                    "Dual Enrollment is FREE for FL residents",
                    "STARS transcript system required for most FL public universities",
                    "FL public universities use common application deadlines"
                ]
            )
        case "TX", "TEXAS":
            return StateRequirements(
                state: "Texas",
                graduationCredits: 26,
                creditRequirements: [
                    "English": 4, "Math": 4, "Science": 4,
                    "Social Studies": 4, "World Language": 2,
                    "Fine Arts": 1, "Physical Education": 1, "Electives": 6
                ],
                meritScholarship: nil,
                specialRules: [
                    "Top 6% auto-admission to UT Austin",
                    "Top 10% auto-admission to any TX public university",
                    "Foundation + Endorsement graduation plans available"
                ]
            )
        case "CA", "CALIFORNIA":
            return StateRequirements(
                state: "California",
                graduationCredits: 22,
                creditRequirements: [
                    "English": 4, "Math": 3, "Science": 2,
                    "Social Studies": 3, "World Language": 2,
                    "Visual/Performing Arts": 1, "Electives": 7
                ],
                meritScholarship: MeritScholarship(
                    name: "Cal Grant A",
                    fullAmount: "Up to $12,570/year at UC, $5,742 at CSU",
                    requirements: "3.0 GPA + financial need (FAFSA required)",
                    partialName: "Cal Grant B",
                    partialRequirements: "2.0 GPA + financial need = living expenses + tuition after first year"
                ),
                specialRules: [
                    "UC system requires A-G coursework (15 year-long courses)",
                    "CSU system has its own eligibility index",
                    "Community college guaranteed transfer via TAG program"
                ]
            )
        case "NY", "NEW YORK":
            return StateRequirements(
                state: "New York",
                graduationCredits: 22,
                creditRequirements: [
                    "English": 4, "Math": 3, "Science": 3,
                    "Social Studies": 4, "World Language": 1,
                    "Arts": 1, "Physical Education": 2, "Health": 1, "Electives": 3
                ],
                meritScholarship: MeritScholarship(
                    name: "Excelsior Scholarship",
                    fullAmount: "Free SUNY/CUNY tuition (household income < $125K)",
                    requirements: "30 credits/year + live/work in NY 4 years after graduation",
                    partialName: nil, partialRequirements: nil
                ),
                specialRules: [
                    "Regents diploma requires passing 5 Regents exams",
                    "Advanced Regents diploma requires 8+ Regents exams",
                    "SUNY/CUNY have separate application systems"
                ]
            )
        case "GA", "GEORGIA":
            return StateRequirements(
                state: "Georgia",
                graduationCredits: 24,
                creditRequirements: [
                    "English": 4, "Math": 4, "Science": 4,
                    "Social Studies": 3, "World Language": 2,
                    "Health/PE": 1, "Electives": 6
                ],
                meritScholarship: MeritScholarship(
                    name: "HOPE Scholarship",
                    fullAmount: "Covers tuition at GA public universities",
                    requirements: "3.0 GPA in core courses (maintained each year in college)",
                    partialName: "Zell Miller Scholarship",
                    partialRequirements: "3.7 GPA + 1200 SAT/26 ACT = 100% tuition"
                ),
                specialRules: [
                    "HOPE must be maintained with 3.0 GPA in college each checkpoint",
                    "Move On When Ready dual enrollment program"
                ]
            )
        default:
            // Generic requirements for states not yet added
            return StateRequirements(
                state: state,
                graduationCredits: 24,
                creditRequirements: [
                    "English": 4, "Math": 3, "Science": 3,
                    "Social Studies": 3, "World Language": 2,
                    "Electives": 9
                ],
                meritScholarship: nil,
                specialRules: ["Check with your school counselor for state-specific requirements"]
            )
        }
    }

    // List of supported states for picker
    static let supportedStates = [
        "Florida", "Texas", "California", "New York", "Georgia",
        "Pennsylvania", "Illinois", "Ohio", "North Carolina", "New Jersey",
        "Virginia", "Washington", "Massachusetts", "Arizona", "Colorado",
        "Other"
    ]
}
