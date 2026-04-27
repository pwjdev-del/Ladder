import Testing
import Foundation
@testable import LadderApp

struct CollegeModelsTests {

    @Test func collegeModelInit() {
        let college = CollegeModel(name: "Georgia Tech")
        #expect(college.name == "Georgia Tech")
        #expect(college.isHBCU == false)
        #expect(college.programs.isEmpty)
        #expect(college.deadlines.isEmpty)
    }

    @Test func collegePersonalityModelInit() {
        let personality = CollegePersonalityModel(archetypeName: "The Builder/Maker")
        #expect(personality.archetypeName == "The Builder/Maker")
        #expect(personality.traits.isEmpty)
    }

    @Test func collegeDeadlineModelInit() {
        let deadline = CollegeDeadlineModel(deadlineType: "Early Action")
        #expect(deadline.deadlineType == "Early Action")
        #expect(deadline.applicationPlatforms.isEmpty)
    }

    @Test func collegeVisitModelInit() {
        let visit = CollegeVisitModel(collegeId: "col_003", collegeName: "Caltech")
        #expect(visit.collegeName == "Caltech")
        #expect(visit.hasVisited == false)
    }
}
