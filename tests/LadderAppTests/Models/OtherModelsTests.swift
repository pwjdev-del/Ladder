import Testing
import Foundation
@testable import LadderApp

struct OtherModelsTests {

    @Test func lorModelInit() {
        let lor = LetterOfRecModel(recommenderName: "Dr. Smith", recommenderRole: "Teacher")
        #expect(lor.recommenderName == "Dr. Smith")
        #expect(lor.status == "not_requested")
        #expect(lor.collegesFor.isEmpty)
    }

    @Test func chatSessionModelInit() {
        let session = ChatSessionModel(sessionType: "advisor")
        #expect(session.sessionType == "advisor")
        #expect(session.messages.isEmpty)
    }

    @Test func chatMessageModelInit() {
        let msg = ChatMessageModel(role: "user", content: "Hello")
        #expect(msg.role == "user")
        #expect(msg.content == "Hello")
    }

    @Test func counselorProfileModelInit() {
        let profile = CounselorProfileModel(name: "Jane Doe", schoolName: "Lincoln High")
        #expect(profile.name == "Jane Doe")
        #expect(profile.reviewCount == 0)
        #expect(profile.isFreelance == false)
    }

    @Test func schoolClubModelInit() {
        let club = SchoolClubModel(name: "Debate Team", category: "Academic")
        #expect(club.name == "Debate Team")
        #expect(club.isActive == true)
    }

    @Test func dashboardActionInit() {
        let action = DashboardAction(
            title: "Explore Colleges",
            subtitle: "Browse 6,300+ schools",
            icon: "building.columns.fill",
            route: .collegeDiscovery
        )
        #expect(action.title == "Explore Colleges")
        #expect(action.route == .collegeDiscovery)
    }
}
