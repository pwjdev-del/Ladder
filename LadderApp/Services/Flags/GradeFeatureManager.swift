import Foundation

// MARK: - Grade Feature Manager
// Controls feature visibility per grade level.
// Every feature has a visibility tier: active, available, preview, or hidden.

@Observable
final class GradeFeatureManager {
    static let shared = GradeFeatureManager()
    private init() {}

    enum Visibility {
        case active      // On dashboard, fully functional
        case available   // In Profile -> Tools, explorable
        case preview     // Shows "Unlocks in Xth grade" overlay
        case hidden      // Not visible
    }

    // MARK: - Feature Catalog

    enum Feature: String, CaseIterable {
        // Core (all grades active)
        case careerQuiz, activitiesPortfolio, gpaTracker, graduationTracker
        case classPlanner, collegeDiscovery, careerExplorer, volunteeringLog
        case messaging, brightFutures

        // College prep
        case collegeProfiles, saveColleges, apCredits, apSuggestions
        case dualEnrollment, scholarshipSearch, scholarshipMatch

        // Test prep
        case satTracker, testPrepResources, feeWaiver

        // Application tools
        case whatIfSimulator, myChances, collegeComparison, gapAnalysis
        case visitPlanner, deadlineHeatmap, essayTracker, whyThisSchool
        case mockInterview, lorTracker, thankYouNote, commonAppExport
        case academicResume, admissionChecklist

        // Application management (mostly 12th)
        case decisionPortal, appSeasonDashboard, lociGenerator
        case acceptanceWarning, waitlistStrategy

        // Financial aid
        case fafsaGuide, cssProfileGuide, financialAidComparison

        // Post-acceptance
        case enrollmentChecklist, housing, first100Days, freshmanGuide, postGraduation

        // Reports
        case pdfPortfolio, impactReport, alternativePaths, internshipGuide

        // MARK: - Display Info

        var displayName: String {
            switch self {
            case .careerQuiz: return "Career Quiz"
            case .activitiesPortfolio: return "Activities Portfolio"
            case .gpaTracker: return "GPA Tracker"
            case .graduationTracker: return "Graduation Tracker"
            case .classPlanner: return "Class Planner"
            case .collegeDiscovery: return "College Discovery"
            case .careerExplorer: return "Career Explorer"
            case .volunteeringLog: return "Volunteering Log"
            case .messaging: return "Messaging"
            case .brightFutures: return "Bright Futures"
            case .collegeProfiles: return "College Profiles"
            case .saveColleges: return "Save Colleges"
            case .apCredits: return "AP Credits"
            case .apSuggestions: return "AP Suggestions"
            case .dualEnrollment: return "Dual Enrollment"
            case .scholarshipSearch: return "Scholarship Search"
            case .scholarshipMatch: return "Scholarship Match"
            case .satTracker: return "SAT Tracker"
            case .testPrepResources: return "Test Prep Resources"
            case .feeWaiver: return "Fee Waiver"
            case .whatIfSimulator: return "What-If Simulator"
            case .myChances: return "My Chances"
            case .collegeComparison: return "College Comparison"
            case .gapAnalysis: return "Gap Analysis"
            case .visitPlanner: return "Visit Planner"
            case .deadlineHeatmap: return "Deadline Heatmap"
            case .essayTracker: return "Essay Tracker"
            case .whyThisSchool: return "Why This School"
            case .mockInterview: return "Mock Interview"
            case .lorTracker: return "Rec Letter Tracker"
            case .thankYouNote: return "Thank You Notes"
            case .commonAppExport: return "Common App Export"
            case .academicResume: return "Academic Resume"
            case .admissionChecklist: return "Admission Checklist"
            case .decisionPortal: return "Decision Portal"
            case .appSeasonDashboard: return "App Season Dashboard"
            case .lociGenerator: return "LOCI Generator"
            case .acceptanceWarning: return "Acceptance Warning"
            case .waitlistStrategy: return "Waitlist Strategy"
            case .fafsaGuide: return "FAFSA Guide"
            case .cssProfileGuide: return "CSS Profile Guide"
            case .financialAidComparison: return "Financial Aid Comparison"
            case .enrollmentChecklist: return "Enrollment Checklist"
            case .housing: return "Housing"
            case .first100Days: return "First 100 Days"
            case .freshmanGuide: return "Freshman Guide"
            case .postGraduation: return "Post-Graduation"
            case .pdfPortfolio: return "PDF Portfolio"
            case .impactReport: return "Impact Report"
            case .alternativePaths: return "Alternative Paths"
            case .internshipGuide: return "Internship Guide"
            }
        }

        var icon: String {
            switch self {
            case .careerQuiz: return "sparkle.magnifyingglass"
            case .activitiesPortfolio: return "star.fill"
            case .gpaTracker: return "chart.bar.fill"
            case .graduationTracker: return "checkmark.seal.fill"
            case .classPlanner: return "book.fill"
            case .collegeDiscovery: return "building.columns.fill"
            case .careerExplorer: return "briefcase.fill"
            case .volunteeringLog: return "heart.circle.fill"
            case .messaging: return "message.fill"
            case .brightFutures: return "star.circle.fill"
            case .collegeProfiles: return "building.columns"
            case .saveColleges: return "bookmark.fill"
            case .apCredits: return "a.circle.fill"
            case .apSuggestions: return "lightbulb.fill"
            case .dualEnrollment: return "graduationcap.fill"
            case .scholarshipSearch: return "banknote.fill"
            case .scholarshipMatch: return "dollarsign.arrow.circlepath"
            case .satTracker: return "pencil.and.list.clipboard"
            case .testPrepResources: return "books.vertical.fill"
            case .feeWaiver: return "tag.fill"
            case .whatIfSimulator: return "slider.horizontal.3"
            case .myChances: return "percent"
            case .collegeComparison: return "arrow.left.arrow.right"
            case .gapAnalysis: return "chart.dots.scatter"
            case .visitPlanner: return "map.fill"
            case .deadlineHeatmap: return "calendar.badge.clock"
            case .essayTracker: return "doc.text.fill"
            case .whyThisSchool: return "questionmark.circle.fill"
            case .mockInterview: return "person.wave.2.fill"
            case .lorTracker: return "envelope.badge.person.crop"
            case .thankYouNote: return "hand.thumbsup.fill"
            case .commonAppExport: return "square.and.arrow.up.fill"
            case .academicResume: return "doc.richtext.fill"
            case .admissionChecklist: return "checklist"
            case .decisionPortal: return "tray.full.fill"
            case .appSeasonDashboard: return "gauge.with.dots.needle.33percent"
            case .lociGenerator: return "envelope.fill"
            case .acceptanceWarning: return "exclamationmark.triangle.fill"
            case .waitlistStrategy: return "hourglass"
            case .fafsaGuide: return "dollarsign.circle.fill"
            case .cssProfileGuide: return "doc.badge.gearshape.fill"
            case .financialAidComparison: return "chart.bar.xaxis"
            case .enrollmentChecklist: return "list.bullet.clipboard.fill"
            case .housing: return "house.fill"
            case .first100Days: return "calendar.badge.checkmark"
            case .freshmanGuide: return "figure.walk"
            case .postGraduation: return "arrow.up.forward.circle.fill"
            case .pdfPortfolio: return "doc.fill"
            case .impactReport: return "chart.pie.fill"
            case .alternativePaths: return "arrow.triangle.branch"
            case .internshipGuide: return "briefcase.fill"
            }
        }

        var featureDescription: String {
            switch self {
            case .careerQuiz: return "Discover your ideal career path with an adaptive quiz"
            case .activitiesPortfolio: return "Track all your extracurriculars, clubs, and achievements"
            case .gpaTracker: return "Monitor your GPA and academic progress"
            case .graduationTracker: return "Track credits toward graduation requirements"
            case .classPlanner: return "Get AI-recommended class schedules"
            case .collegeDiscovery: return "Browse and explore 6,300+ colleges"
            case .careerExplorer: return "Deep-dive into career fields and requirements"
            case .volunteeringLog: return "Log community service and volunteer hours"
            case .messaging: return "Message counselors and advisors"
            case .brightFutures: return "Track Florida Bright Futures eligibility"
            case .collegeProfiles: return "View detailed college profiles with stats and insights"
            case .saveColleges: return "Build and manage your college list"
            case .apCredits: return "See which AP credits transfer to your target schools"
            case .apSuggestions: return "Get AI-recommended AP courses for your goals"
            case .dualEnrollment: return "Explore dual enrollment opportunities"
            case .scholarshipSearch: return "Search thousands of scholarships"
            case .scholarshipMatch: return "Get matched to scholarships you qualify for"
            case .satTracker: return "Track SAT scores and study progress"
            case .testPrepResources: return "Access curated test prep materials"
            case .feeWaiver: return "Check if you qualify for application fee waivers"
            case .whatIfSimulator: return "Simulate how changes affect your college chances"
            case .myChances: return "See your admission probability at each school"
            case .collegeComparison: return "Compare colleges side-by-side on key metrics"
            case .gapAnalysis: return "Identify gaps between your profile and college requirements"
            case .visitPlanner: return "Plan and organize your college campus visits"
            case .deadlineHeatmap: return "Visualize all your deadlines in a heatmap calendar"
            case .essayTracker: return "Track and manage all your college essays"
            case .whyThisSchool: return "Generate personalized 'Why This School' essay drafts"
            case .mockInterview: return "Practice college admissions interviews with AI"
            case .lorTracker: return "Track recommendation letter requests and status"
            case .thankYouNote: return "Generate thank-you notes for recommenders"
            case .commonAppExport: return "Export your activities in Common App format"
            case .academicResume: return "Build a polished academic resume"
            case .admissionChecklist: return "Track every requirement for each college application"
            case .decisionPortal: return "Track admission decisions as they arrive"
            case .appSeasonDashboard: return "Full overview of your application season"
            case .lociGenerator: return "Generate Letters of Continued Interest for waitlists"
            case .acceptanceWarning: return "Alerts for acceptance rate changes and red flags"
            case .waitlistStrategy: return "Strategic advice for waitlisted schools"
            case .fafsaGuide: return "Step-by-step FAFSA completion guide"
            case .cssProfileGuide: return "Step-by-step CSS Profile completion guide"
            case .financialAidComparison: return "Compare financial aid packages side-by-side"
            case .enrollmentChecklist: return "Post-acceptance enrollment tasks and deadlines"
            case .housing: return "Research and compare housing options"
            case .first100Days: return "Plan your first 100 days at college"
            case .freshmanGuide: return "Essential tips for your freshman year"
            case .postGraduation: return "Start planning beyond college"
            case .pdfPortfolio: return "Export your full student portfolio as a PDF"
            case .impactReport: return "See the impact of your extracurricular activities"
            case .alternativePaths: return "Explore alternative education and career paths"
            case .internshipGuide: return "Find and apply to internships"
            }
        }
    }

    // MARK: - Visibility Logic

    func visibility(for feature: Feature, grade: Int) -> Visibility {
        // Grade 12: everything is active
        if grade >= 12 { return .active }

        // Core features: always active for all grades
        let coreFeatures: Set<Feature> = [
            .careerQuiz, .activitiesPortfolio, .gpaTracker, .graduationTracker,
            .classPlanner, .collegeDiscovery, .careerExplorer, .volunteeringLog,
            .messaging, .brightFutures
        ]
        if coreFeatures.contains(feature) { return .active }

        // Grade-specific matrices
        switch grade {
        case 9:
            return grade9Visibility(feature)
        case 10:
            return grade10Visibility(feature)
        case 11:
            return grade11Visibility(feature)
        default:
            // Below 9th grade: same as 9th
            return grade9Visibility(feature)
        }
    }

    // MARK: - Grade 9 Matrix

    private func grade9Visibility(_ feature: Feature) -> Visibility {
        switch feature {
        // PREVIEW
        case .satTracker, .testPrepResources,
             .whatIfSimulator, .myChances,
             .deadlineHeatmap, .gapAnalysis:
            return .preview

        // AVAILABLE
        case .collegeProfiles, .saveColleges, .apCredits,
             .scholarshipSearch, .scholarshipMatch,
             .academicResume, .pdfPortfolio, .impactReport,
             .alternativePaths, .internshipGuide, .feeWaiver,
             .apSuggestions, .dualEnrollment, .visitPlanner,
             .collegeComparison:
            return .available

        // HIDDEN (everything else)
        default:
            return .hidden
        }
    }

    // MARK: - Grade 10 Matrix

    private func grade10Visibility(_ feature: Feature) -> Visibility {
        switch feature {
        // ACTIVE (newly promoted from 9th)
        case .satTracker, .testPrepResources, .feeWaiver,
             .apSuggestions, .dualEnrollment,
             .collegeProfiles, .saveColleges:
            return .active

        // AVAILABLE
        case .whatIfSimulator, .myChances, .visitPlanner,
             .apCredits, .scholarshipSearch, .scholarshipMatch,
             .academicResume, .pdfPortfolio, .impactReport,
             .alternativePaths, .internshipGuide,
             .collegeComparison, .gapAnalysis, .deadlineHeatmap:
            return .available

        // PREVIEW
        case .essayTracker, .mockInterview, .commonAppExport:
            return .preview

        // HIDDEN
        case .decisionPortal, .lociGenerator,
             .appSeasonDashboard, .acceptanceWarning, .waitlistStrategy,
             .fafsaGuide, .cssProfileGuide, .financialAidComparison,
             .enrollmentChecklist, .housing, .first100Days,
             .freshmanGuide, .postGraduation,
             .whyThisSchool, .lorTracker, .thankYouNote,
             .admissionChecklist:
            return .hidden

        default:
            return .hidden
        }
    }

    // MARK: - Grade 11 Matrix

    private func grade11Visibility(_ feature: Feature) -> Visibility {
        switch feature {
        // PREVIEW
        case .decisionPortal,
             .fafsaGuide, .cssProfileGuide, .financialAidComparison:
            return .preview

        // HIDDEN
        case .appSeasonDashboard, .lociGenerator,
             .acceptanceWarning, .waitlistStrategy,
             .enrollmentChecklist, .housing, .first100Days,
             .freshmanGuide, .postGraduation:
            return .hidden

        // Everything else is ACTIVE
        default:
            return .active
        }
    }

    // MARK: - Helpers

    func isAccessible(_ feature: Feature, grade: Int) -> Bool {
        let v = visibility(for: feature, grade: grade)
        return v == .active || v == .available
    }

    func unlockGrade(for feature: Feature) -> Int? {
        // Find the earliest grade where this feature becomes active or available
        for g in 9...12 {
            let v = visibility(for: feature, grade: g)
            if v == .active || v == .available {
                return g
            }
        }
        return nil
    }

    /// Returns all features that are in preview state for a given grade
    func previewFeatures(for grade: Int) -> [Feature] {
        Feature.allCases.filter { visibility(for: $0, grade: grade) == .preview }
    }
}
