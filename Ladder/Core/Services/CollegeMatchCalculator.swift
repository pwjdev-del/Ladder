import Foundation

// MARK: - Match Tier

enum MatchTier: String {
    case safety = "Safety"
    case match = "Match"
    case reach = "Reach"

    var color: String {
        switch self {
        case .safety: return "green"
        case .match: return "yellow"
        case .reach: return "red"
        }
    }
}

// MARK: - College Match Calculator

struct CollegeMatchCalculator {

    /// Determines whether a college is a Safety, Match, or Reach for the student
    /// based on GPA, SAT scores, and the college's selectivity profile.
    static func tier(
        studentGPA: Double?,
        studentSAT: Int?,
        collegeAcceptanceRate: Double?,
        collegeSATAvg: Int?,
        collegeSAT25: Int?,
        collegeSAT75: Int?
    ) -> MatchTier {
        // If no student data, can't calculate
        guard let gpa = studentGPA else { return .match }

        // If studentSAT is 0 (never entered), return neutral .match
        if let sat = studentSAT, sat == 0 { return .match }

        let satLow = collegeSAT25 ?? (collegeSATAvg.map { $0 - 100 } ?? 1000)
        let satHigh = collegeSAT75 ?? (collegeSATAvg.map { $0 + 100 } ?? 1400)
        let satMid = (satLow + satHigh) / 2

        // Treat 0.0 acceptance rate (missing/malformed data) as 0.50 to avoid false "impossible reach"
        let rawRate = collegeAcceptanceRate ?? 0.5
        let acceptRate = rawRate == 0.0 ? 0.5 : rawRate

        let studentSATVal = studentSAT ?? 1100

        let isHighlySelective = acceptRate < 0.20
        let isModeratelySelective = acceptRate < 0.50

        let satAbove75th = studentSATVal >= satHigh
        let satAbove50th = studentSATVal >= satMid
        let satBelow25th = studentSATVal < satLow

        let strongGPA = gpa >= 3.7
        let averageGPA = gpa >= 3.2

        if isHighlySelective {
            if satAbove75th && strongGPA { return .match }
            return .reach
        }

        if isModeratelySelective {
            if satAbove75th && strongGPA { return .safety }
            if satAbove50th && averageGPA { return .match }
            return .reach
        }

        // Less selective (>50% acceptance)
        if satAbove50th && averageGPA { return .safety }
        if !satBelow25th || averageGPA { return .match }
        return .reach
    }
}
