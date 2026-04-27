import Testing
import Foundation
@testable import LadderApp

struct ApplicationModelsTests {

    @Test func applicationModelInit() {
        let app = ApplicationModel(collegeName: "MIT")
        #expect(app.collegeName == "MIT")
        #expect(app.status == "planning")
        #expect(app.checklistItems.isEmpty)
    }

    @Test func checklistItemModelInit() {
        let item = ChecklistItemModel(title: "Send transcript")
        #expect(item.title == "Send transcript")
        #expect(item.status == "pending")
    }

    @Test func studentProfileModelInit() {
        let profile = StudentProfileModel(firstName: "Ada", lastName: "Lovelace")
        #expect(profile.fullName == "Ada Lovelace")
        #expect(profile.grade == 9)
        #expect(profile.totalXP == 0)
    }
}
