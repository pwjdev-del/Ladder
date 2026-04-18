import Foundation

// MARK: - Level Progression System
// Tracks XP thresholds and level names. Stateless — computes from totalXP on StudentProfileModel.

@Observable
final class LevelManager {
    static let shared = LevelManager()
    private init() {}

    // MARK: - Level Definition

    struct Level {
        let number: Int
        let name: String
        let minXP: Int
        let maxXP: Int
    }

    let levels: [Level] = [
        Level(number: 1, name: "Explorer", minXP: 0, maxXP: 99),
        Level(number: 2, name: "Builder", minXP: 100, maxXP: 299),
        Level(number: 3, name: "Achiever", minXP: 300, maxXP: 599),
        Level(number: 4, name: "Leader", minXP: 600, maxXP: 999),
        Level(number: 5, name: "College Bound", minXP: 1000, maxXP: Int.max),
    ]

    // MARK: - Queries

    func currentLevel(xp: Int) -> Level {
        levels.last(where: { xp >= $0.minXP }) ?? levels[0]
    }

    func progress(xp: Int) -> Double {
        let level = currentLevel(xp: xp)
        if level.maxXP == Int.max { return 1.0 }
        let range = Double(level.maxXP - level.minXP + 1)
        let progress = Double(xp - level.minXP) / range
        return min(1.0, max(0.0, progress))
    }

    func xpToNextLevel(xp: Int) -> Int {
        let level = currentLevel(xp: xp)
        if level.maxXP == Int.max { return 0 }
        return level.maxXP + 1 - xp
    }

    // MARK: - XP Rewards

    enum Action {
        case completeChecklist    // +10
        case saveCollege          // +5
        case finishCareerQuiz     // +20
        case uploadTranscript     // +15
        case logActivity          // +10
        case writeEssay           // +15
        case retakeQuiz           // +10
        case completePreferenceQuiz // +15

        var xp: Int {
            switch self {
            case .completeChecklist: return 10
            case .saveCollege: return 5
            case .finishCareerQuiz: return 20
            case .uploadTranscript: return 15
            case .logActivity: return 10
            case .writeEssay: return 15
            case .retakeQuiz: return 10
            case .completePreferenceQuiz: return 15
            }
        }
    }

    /// Awards XP for an action, returns amount awarded and whether a level-up occurred
    func awardXP(_ action: Action, to profile: StudentProfileModel) -> (awarded: Int, leveledUp: Bool) {
        let previousLevel = currentLevel(xp: profile.totalXP)
        profile.totalXP += action.xp
        let newLevel = currentLevel(xp: profile.totalXP)
        return (action.xp, newLevel.number > previousLevel.number)
    }
}
