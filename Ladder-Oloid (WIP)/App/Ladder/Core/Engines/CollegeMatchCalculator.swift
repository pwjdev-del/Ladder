import Foundation

/// Computes Reach / Match / Safety classification for a student-college pair
/// based on standardized scores and acceptance rate.
enum MatchCategory: String {
    case safety, match, reach, hardReach
    var color: String {  // names map to LadderColors
        switch self {
        case .safety: "accentLime"
        case .match: "primary"
        case .reach: "tertiary"
        case .hardReach: "error"
        }
    }
    var label: String {
        switch self {
        case .safety: "Safety"
        case .match: "Match"
        case .reach: "Reach"
        case .hardReach: "Hard Reach"
        }
    }
}

enum CollegeMatchCalculator {
    /// Returns a 0-100 match score for a student-college pair
    static func matchScore(profileGPA: Double?, profileSAT: Int?, collegeAcceptance: Double?, collegeSATRange: String?) -> Int {
        guard let gpa = profileGPA, let sat = profileSAT else { return 50 }

        // Parse college SAT range like "1400-1550"
        let (lo, hi) = parseRange(collegeSATRange) ?? (1200, 1400)
        let mid = (lo + hi) / 2

        // GPA contribution (50% weight): how close to 4.0
        let gpaScore = min(100.0, (gpa / 4.0) * 100.0)

        // SAT contribution (50% weight): vs midpoint
        let satScore: Double
        if sat >= hi { satScore = 95.0 }
        else if sat >= mid { satScore = 80.0 }
        else if sat >= lo { satScore = 65.0 }
        else { satScore = max(20.0, Double(sat) / Double(mid) * 60.0) }

        // Penalty if college acceptance is brutal (< 10%)
        var penalty = 0.0
        if let acc = collegeAcceptance, acc < 0.10 { penalty = 10.0 }

        return Int(gpaScore * 0.5 + satScore * 0.5 - penalty)
    }

    static func category(profileGPA: Double?, profileSAT: Int?, collegeAcceptance: Double?, collegeSATRange: String?) -> MatchCategory {
        let score = matchScore(profileGPA: profileGPA, profileSAT: profileSAT, collegeAcceptance: collegeAcceptance, collegeSATRange: collegeSATRange)
        if let acc = collegeAcceptance, acc < 0.10, score < 90 { return .hardReach }
        switch score {
        case 80...: return .safety
        case 60..<80: return .match
        case 40..<60: return .reach
        default: return .hardReach
        }
    }

    private static func parseRange(_ s: String?) -> (Int, Int)? {
        guard let s = s else { return nil }
        let parts = s.split(separator: "-").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }
}
