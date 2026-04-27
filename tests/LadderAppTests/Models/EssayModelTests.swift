import Testing
import Foundation
@testable import LadderApp

struct EssayModelTests {

    @Test func essayModelInit() {
        let essay = EssayModel(collegeId: "col_001", collegeName: "Stanford", prompt: "Why Stanford?")
        #expect(essay.collegeId == "col_001")
        #expect(essay.status == "not_started")
        #expect(essay.wordLimit == 650)
        #expect(essay.wordCount == 0)
    }

    @Test func essayModelWordCount() {
        let essay = EssayModel(collegeId: "col_002", collegeName: "Harvard", prompt: "Why Harvard?")
        essay.draft = "I love Harvard so much"
        #expect(essay.wordCount == 4)
    }
}
