import Foundation
import SwiftData

// MARK: - Connection Engine
// Central glue that updates downstream features when core data changes.
// Connects career quiz results, saved colleges, and grade to downstream features.

@MainActor
@Observable
final class ConnectionEngine {
    static let shared = ConnectionEngine()
    private init() {}

    // Notifications for downstream consumers to observe cross-cutting changes.
    static let careerPathDidChange = Notification.Name("ConnectionEngine.careerPathDidChange")
    static let gradeDidChange = Notification.Name("ConnectionEngine.gradeDidChange")
    static let stateDidChange = Notification.Name("ConnectionEngine.stateDidChange")
    static let applicationDidAccept = Notification.Name("ConnectionEngine.applicationDidAccept")

    // MARK: - State Changed

    /// When student changes their state, update downstream systems
    func onStateChanged(newState: String, context: ModelContext) {
        UserDefaults.standard.set(newState, forKey: "student_state")
        NotificationCenter.default.post(name: Self.stateDidChange, object: newState)
    }

    /// When grade changes (school-year rollover or manual edit), let observers refresh.
    func onGradeChanged(newGrade: Int, context: ModelContext) {
        UserDefaults.standard.set(newGrade, forKey: "student_grade")
        NotificationCenter.default.post(name: Self.gradeDidChange, object: newGrade)
    }

    /// When an application transitions to `.accepted`, generate post-acceptance checklist items
    /// and notify observers so housing / enrollment views can react.
    func onApplicationAccepted(_ application: ApplicationModel, context: ModelContext) {
        // Guard: only generate once per application
        let alreadyGenerated = application.checklistItems.contains {
            $0.category == "post_acceptance"
        }
        guard !alreadyGenerated else {
            NotificationCenter.default.post(name: Self.applicationDidAccept, object: application.collegeId)
            return
        }

        let items: [(String, Int)] = [
            ("Submit enrollment deposit", 0),
            ("Complete FAFSA verification (if required)", 1),
            ("Apply for housing", 2),
            ("Sign up for orientation", 3),
            ("Send final transcript", 4),
            ("Complete health forms & immunizations", 5)
        ]
        for (title, order) in items {
            let item = ChecklistItemModel(title: title)
            item.category = "post_acceptance"
            item.status = "pending"
            item.sortOrder = order
            item.application = application
            context.insert(item)
        }

        do {
            try context.save()
        } catch {
            Log.error("onApplicationAccepted save failed: \(error)")
        }
        NotificationCenter.default.post(name: Self.applicationDidAccept, object: application.collegeId)
    }

    // MARK: - Career Path Changed

    /// When career quiz result changes, update all downstream systems
    func onCareerPathChanged(newPath: String, context: ModelContext) {
        // 1. Store career-specific activity suggestions in UserDefaults
        // REPLACES previous suggestions entirely (no append)
        let suggestions = activitySuggestionsForPath(newPath)
        UserDefaults.standard.set(suggestions, forKey: "career_activity_suggestions")
        UserDefaults.standard.set(newPath, forKey: "last_career_path")

        // 2. Log the change timestamp for year-over-year tracking
        // Guard against duplicate entries when user retakes quiz multiple times quickly
        let history = UserDefaults.standard.array(forKey: "career_path_history") as? [[String: String]] ?? []
        var updated = history
        let formatter = ISO8601DateFormatter()
        let todayStr = formatter.string(from: Date())

        // If the last entry is the same path on the same day, skip (prevents duplicates on retake)
        if let last = updated.last, last["path"] == newPath,
           let lastDate = last["date"], lastDate.prefix(10) == todayStr.prefix(10) {
            // Already logged this path today — skip duplicate
        } else {
            updated.append([
                "path": newPath,
                "date": todayStr
            ])
            UserDefaults.standard.set(updated, forKey: "career_path_history")
        }

        NotificationCenter.default.post(name: Self.careerPathDidChange, object: newPath)
    }

    // MARK: - College Saved

    /// When student saves a college, trigger downstream updates
    func onCollegeSaved(collegeId: String, collegeName: String, context: ModelContext) {
        // 1. Auto-create essay slots if essay feature is active for the student's grade
        let grade = currentStudentGrade(context: context)
        if GradeFeatureManager.shared.isAccessible(.essayTracker, grade: grade) {
            autoCreateEssaySlots(collegeId: collegeId, collegeName: collegeName, context: context)
        }

        // 2. Admission checklist updates happen naturally via SwiftData queries
    }

    // MARK: - College Removed

    /// When student removes a college, clean up ALL related downstream data
    func onCollegeRemoved(collegeId: String, context: ModelContext) {
        // 1. Delete ALL essay slots for this college (empty AND with content)
        let essayDescriptor = FetchDescriptor<EssayModel>(
            predicate: #Predicate { $0.collegeId == collegeId }
        )
        if let essays = try? context.fetch(essayDescriptor) {
            for essay in essays {
                context.delete(essay)
            }
        }

        // 2. Delete any applications tied to this college
        // (ChecklistItemModel cascade-deletes via @Relationship on ApplicationModel)
        let appDescriptor = FetchDescriptor<ApplicationModel>(
            predicate: #Predicate { $0.collegeId == collegeId }
        )
        if let apps = try? context.fetch(appDescriptor) {
            for app in apps {
                context.delete(app)
            }
        }

        do { try context.save() } catch { Log.error("ConnectionEngine save failed: \(error)") }
    }

    // MARK: - Auto-Create Essay Slots

    private func autoCreateEssaySlots(collegeId: String, collegeName: String, context: ModelContext) {
        // Check if essays already exist for this college
        let descriptor = FetchDescriptor<EssayModel>(
            predicate: #Predicate { $0.collegeId == collegeId }
        )
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        // Fetch college to get supplemental essay count
        let collegeDescriptor = FetchDescriptor<CollegeModel>(
            predicate: #Predicate { $0.name == collegeName }
        )
        if let college = try? context.fetch(collegeDescriptor).first {
            let essayCountStr = college.supplementalEssaysCount ?? "1"
            let essayCount = max(1, Int(essayCountStr) ?? 1)
            for i in 1...essayCount {
                let essay = EssayModel(
                    collegeId: collegeId,
                    collegeName: collegeName,
                    prompt: "Supplemental Essay \(i)",
                    wordLimit: 650
                )
                context.insert(essay)
            }
            do { try context.save() } catch { Log.error("ConnectionEngine save failed: \(error)") }
        }
    }

    // MARK: - Dashboard Actions (Grade + Career Specific)

    /// Get grade-appropriate dashboard actions based on career path
    func dashboardActions(grade: Int, careerPath: String?) -> [DashboardAction] {
        let career = careerPath ?? "General"

        switch grade {
        case 9:
            let ca = careerAction(career)
            return [
                DashboardAction(title: ca.title, subtitle: ca.subtitle, icon: ca.icon, route: ca.route),
                DashboardAction(title: "Track Activities", subtitle: activitySubtitle(career), icon: "star.fill", route: .activitiesPortfolio),
                DashboardAction(title: "Plan Your Classes", subtitle: "Get AI-recommended schedule", icon: "book.fill", route: .aiClassPlanner),
                DashboardAction(title: "Explore Colleges", subtitle: "Browse 6,300+ schools", icon: "building.columns.fill", route: .collegeDiscovery)
            ]
        case 10:
            return [
                DashboardAction(title: "SAT Prep", subtitle: "Start preparing for the SAT", icon: "pencil.and.list.clipboard", route: .satScoreTracker),
                DashboardAction(title: "Track Activities", subtitle: activitySubtitle(career), icon: "star.fill", route: .activitiesPortfolio),
                DashboardAction(title: "Plan Your Classes", subtitle: "Pick APs for junior year", icon: "book.fill", route: .aiClassPlanner),
                DashboardAction(title: "Explore Colleges", subtitle: "Build your college list", icon: "building.columns.fill", route: .collegeDiscovery)
            ]
        case 11:
            return [
                DashboardAction(title: "College List", subtitle: "Finalize your target schools", icon: "building.columns.fill", route: .collegeDiscovery),
                DashboardAction(title: "Write Essays", subtitle: "Start your supplementals", icon: "doc.text.fill", route: .essayTracker),
                DashboardAction(title: "SAT Score", subtitle: "Track and improve", icon: "chart.line.uptrend.xyaxis", route: .satScoreTracker),
                DashboardAction(title: "Mock Interview", subtitle: "Practice for admissions", icon: "person.wave.2.fill", route: .mockInterviewFull(collegeId: nil))
            ]
        case 12:
            return [
                DashboardAction(title: "Decision Portal", subtitle: "Track your applications", icon: "tray.full.fill", route: .decisionPortal),
                DashboardAction(title: "Financial Aid", subtitle: "Compare aid packages", icon: "dollarsign.circle.fill", route: .financialAidComparison),
                DashboardAction(title: "Enrollment", subtitle: "Post-acceptance tasks", icon: "checkmark.seal.fill", route: .housingTimeline),
                DashboardAction(title: "LOCI Generator", subtitle: "For waitlisted schools", icon: "envelope.fill", route: .lociGenerator(collegeId: nil))
            ]
        default:
            let ca = careerAction(career)
            return [
                DashboardAction(title: ca.title, subtitle: ca.subtitle, icon: ca.icon, route: ca.route),
                DashboardAction(title: "Explore Colleges", subtitle: "Start browsing", icon: "building.columns.fill", route: .collegeDiscovery),
                DashboardAction(title: "Track Activities", subtitle: activitySubtitle(career), icon: "star.fill", route: .activitiesPortfolio),
                DashboardAction(title: "GPA Tracker", subtitle: "Stay on target", icon: "chart.line.uptrend.xyaxis", route: .graduationTracker)
            ]
        }
    }

    // MARK: - Career-Specific Helpers

    private func careerAction(_ career: String) -> (title: String, subtitle: String, icon: String, route: Route) {
        switch career {
        case "STEM":
            return ("Explore Engineering", "Discover STEM careers & activities", "gearshape.2.fill", .careerExplorer)
        case "Medical":
            return ("Explore Healthcare", "Discover medical careers", "heart.fill", .careerExplorer)
        case "Business":
            return ("Explore Business", "Discover business careers", "briefcase.fill", .careerExplorer)
        case "Humanities":
            return ("Explore Humanities", "Discover arts & education careers", "book.fill", .careerExplorer)
        case "Sports":
            return ("Explore Sports", "Discover sports science careers", "figure.run", .careerExplorer)
        case "Law":
            return ("Explore Law", "Discover legal careers", "building.columns.fill", .careerExplorer)
        default:
            return ("Take Career Quiz", "Discover your career path", "sparkles", .adaptiveCareerQuiz)
        }
    }

    private func activitySubtitle(_ career: String) -> String {
        switch career {
        case "STEM": return "Science fair, robotics, coding projects"
        case "Medical": return "Hospital volunteering, health club"
        case "Business": return "DECA, business club, entrepreneurship"
        case "Humanities": return "Debate, writing, community theater"
        case "Sports": return "Varsity athletics, coaching, fitness"
        case "Law": return "Mock trial, debate, student government"
        default: return "Volunteering, clubs, athletics, jobs"
        }
    }

    private func activitySuggestionsForPath(_ career: String) -> [String] {
        switch career {
        case "STEM":
            return ["Science Olympiad", "Robotics Club", "Math League", "Coding Bootcamp", "Research Assistant"]
        case "Medical":
            return ["Hospital Volunteering", "Health Occupations Club", "Red Cross", "Biology Research", "First Aid Certification"]
        case "Business":
            return ["DECA", "FBLA", "Junior Achievement", "Mock Stock Market", "Entrepreneurship Club"]
        case "Humanities":
            return ["Debate Team", "Model UN", "Literary Magazine", "Community Theater", "Tutoring"]
        case "Sports":
            return ["Varsity Athletics", "Sports Medicine Club", "Coaching Youth Teams", "Fitness Training", "Athletic Leadership"]
        case "Law":
            return ["Mock Trial", "Debate Team", "Model UN", "Student Government", "Legal Internship"]
        default:
            return ["Student Government", "Community Service", "Academic Club", "Part-time Job", "Creative Project"]
        }
    }

    // MARK: - Student Grade Helper

    private func currentStudentGrade(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<StudentProfileModel>()
        if let profile = try? context.fetch(descriptor).first {
            return profile.grade
        }
        return 9 // Safe default: unlocks fewer features rather than more
    }
}
