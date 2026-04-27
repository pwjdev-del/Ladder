import Testing
import Foundation
@testable import LadderApp

struct LevelManagerTests {

    @Test func sharedSingletonIsNotNil() {
        let manager = LevelManager.shared
        #expect(manager !== nil)
    }

    @Test func xpZeroIsLevelOneExplorer() {
        let level = LevelManager.shared.currentLevel(xp: 0)
        #expect(level.number == 1)
        #expect(level.name == "Explorer")
    }

    @Test func xp100IsLevelTwoBuilder() {
        let level = LevelManager.shared.currentLevel(xp: 100)
        #expect(level.number == 2)
        #expect(level.name == "Builder")
    }

    @Test func xp1000IsMaxLevel() {
        let level = LevelManager.shared.currentLevel(xp: 1000)
        #expect(level.number == 5)
        #expect(level.name == "College Bound")
    }

    @Test func progressAtMaxLevelIsOne() {
        let progress = LevelManager.shared.progress(xp: 1000)
        #expect(progress == 1.0)
    }

    @Test func xpToNextLevelAtMaxIsZero() {
        let remaining = LevelManager.shared.xpToNextLevel(xp: 9999)
        #expect(remaining == 0)
    }

    @Test func completeChecklistActionIstenXP() {
        #expect(LevelManager.Action.completeChecklist.xp == 10)
    }

    @Test func finishCareerQuizActionIsTwentyXP() {
        #expect(LevelManager.Action.finishCareerQuiz.xp == 20)
    }

    @Test func awardXPToProfileUpdatesTotalXP() {
        let profile = StudentProfileModel(firstName: "Test", lastName: "Student")
        profile.totalXP = 0
        let (awarded, leveledUp) = LevelManager.shared.awardXP(.saveCollege, to: profile)
        #expect(awarded == 5)
        #expect(profile.totalXP == 5)
        #expect(leveledUp == false)
    }
}
