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
    case apCredits(collegeId: String)

    // MARK: - Applications
    case deadlinesCalendar
    case applicationDetail(applicationId: String)
    case decisionPortal
    case waitlistStrategy(applicationId: String)

    // MARK: - Checklists & Roadmap
    case roadmap
    case activityChecklist
    case enrollmentChecklist(collegeId: String)
    case volunteeringLog

    // MARK: - AI Advisor
    case advisorChat(sessionId: String?)
    case interviewFeedback(sessionId: String)
    case interviewPrepHub
    case essayHub
    case lociGenerator(collegeId: String?)
    case thankYouNote(collegeId: String)
    case scoreImprovement

    // MARK: - Financial
    case scholarshipSearch
    case scholarshipMatch
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
    case legalSettings

    // MARK: - Shared / Modals
    case customReminder
    case milestone(milestoneId: String)
    case careerQuiz
    case messaging(recipientId: String)

    // MARK: - New Features
    case wheelOfCareer
    case transcriptUpload
    case alternativePaths
    case brightFuturesTracker

    // MARK: - Deadline Heatmap
    case deadlineHeatmap

    // MARK: - Phase 1: College Intelligence 2.0
    case gapAnalysis(collegeId: String)
    case acceptanceWarning

    // MARK: - Phase 2: Application Command Center
    case lorTracker
    case housingTimeline
    case dualEnrollmentGuide

    // MARK: - Phase 3: Academic Intelligence
    case satScoreTracker
    case classRecommendations
    case aiClassPlanner
    case graduationTracker
    case feeWaiverChecker

    // MARK: - Phase 4: AI Writing Studio
    case mockInterviewFull(collegeId: String?)
    case mockInterviewFeedback(sessionId: String)
    case academicResume
    case activityImpact
    case cssProfileGuide
    case ncaaTrack

    // MARK: - Phase 5: Financial Intelligence
    case fafsaGuide
    case freshmanGuide(collegeId: String)
    case notificationCenter

    // MARK: - Writing
    case essayTracker

    // MARK: - Phase 6: Community
    case counselorDashboard
    case counselorMarketplace
    case parentAccess
    case peerTutoring
    case ambassadorProgram
    case activitiesPortfolio
    case commonAppExport

    // MARK: - Phase 7: Essay & Checklist Tools
    case whyThisSchool(collegeId: String)
    case aiCollegeSummary(collegeId: String)
    case admissionChecklist(collegeId: String)

    // MARK: - Career & Academic Intelligence
    case adaptiveCareerQuiz
    case careerExplorer
    case apSuggestions
    case gpaTracker

    // MARK: - Phase 8: College Intelligence Tools
    case whatIfSimulator
    case myChances
    case visitPlanner

    // MARK: - Phase 9: App Season & Student Life
    case appSeasonDashboard
    case first100Days
    case testPrepResources

    // MARK: - Phase 10: Counselor B2B
    case caseloadManager
    case studentDetailCounselor(studentId: String)
    case genericDeadlineCalendar
    case counselorVerification
    case classApprovalList
    case classApprovalDetail(studentId: String)
    case bulkStudentImport
    case addSingleStudent

    // MARK: - Module G: Counselor Marketplace Enhancement
    case bookSession(counselorName: String, counselorSpecialty: String?)
    case counselorImpactReport
    case counselorReview(counselorName: String, counselorId: String)

    // MARK: - Module H: School Admin
    case schoolAdminDashboard
    case districtAnalytics
    case classCatalogUpload
    case clubsUpload
    case sportsUpload
    case schoolCalendarUpload
    case mySchool

    // MARK: - Module I: Parent
    case parentDashboard
    case peerComparison

    // MARK: - Module J: Reports & Export
    case pdfPortfolio
    case internshipGuide
    case postGraduation

    // MARK: - College Preference & Level System
    case collegePreferenceQuiz
}
