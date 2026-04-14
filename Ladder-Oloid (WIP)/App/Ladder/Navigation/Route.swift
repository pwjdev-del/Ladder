import Foundation

// MARK: - All navigation destinations in the app (49 screens)

enum Route: Hashable {

    // MARK: - College Intelligence
    case collegeDiscovery
    case collegeProfile(collegeId: String)
    case collegeComparison(leftId: String, rightId: String)
    case matchScore(collegeId: String)
    case collegeFilters
    case collegePersonality(collegeId: String)
    case savedColleges

    // MARK: - Applications
    case deadlinesCalendar
    case applicationDetail(applicationId: String)
    case applicationSubmission(applicationId: String)
    case decisionPortal
    case waitlistStrategy(applicationId: String)
    case postApplication(applicationId: String)

    // MARK: - Checklists & Roadmap
    case roadmap
    case activityChecklist
    case enrollmentChecklist(collegeId: String)
    case volunteeringLog

    // MARK: - AI Advisor
    case advisorChat(sessionId: String?)
    case mockInterview(collegeId: String?)
    case interviewFeedback(sessionId: String)
    case interviewPrepHub
    case essayHub
    case lociGenerator(collegeId: String)
    case thankYouNote(collegeId: String)
    case scoreImprovement

    // MARK: - Financial
    case scholarshipSearch
    case financialAidComparison

    // MARK: - Housing
    case housingPreferences
    case dormComparison(collegeId: String)
    case roommateFinder(collegeId: String)
    case roommateProfile(profileId: String)
    case roommateIntro(profileId: String)

    // MARK: - Reports
    case pdfPreview(reportType: String)
    case impactReport
    case socialShare

    // MARK: - Settings
    case profileSettings
    case notificationSettings

    // MARK: - Shared / Modals
    case customReminder
    case milestone(milestoneId: String)
    case recommendationRequest
    case careerQuiz
    case messaging(recipientId: String)
}
