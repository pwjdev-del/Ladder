import Foundation
import SwiftData

// SiaEngine — the central intelligence powering every screen.
//
// Design contract (from Ladder_Sia_Architecture_v1.md):
//   - Rules decide WHAT to surface. LLM decides HOW to phrase it.
//   - Every screen calls in for its personalized content.
//   - Output is typed; views render without knowing about LLM plumbing.
//
// D-003 CONTRACT:
//   Every public method carries `studentId: String` as a required parameter.
//   No default values. No global/singleton-cached StudentContext keyed on
//   "current user" — every call site must supply the explicit student UUID.

@Observable
@MainActor
final class SiaEngine {
    static let shared = SiaEngine()
    private init() {}

    // MARK: - Home: "3 things this week"

    // Rationale for 6-param signature: all context objects are mandatory and structurally
    // distinct. Merging them into a wrapper struct is deferred to the Context-refactor milestone.
    func generateHomeRecommendations( // swiftlint:disable:this function_parameter_count
        studentId: String,
        student: StudentContext,
        temporal: TemporalContext,
        school: SchoolContext,
        memory: ConversationMemory,
        behavior: BehaviorSignals
    ) async -> [HomeCard] {
        let intents = NudgeRules.evaluate(student: student, temporal: temporal, school: school)
        let top3 = intents
            .sorted { $0.priority.rank < $1.priority.rank }
            .prefix(3)

        return top3.map { intent in
            HomeCard(
                title: intent.title,
                body: intent.rawMessage,
                priority: intent.priority,
                specialist: intent.specialist,
                deepLink: intent.deepLink
            )
        }
    }

    // MARK: - College List

    func evaluateCollegeList(
        studentId: String,
        student: StudentContext,
        colleges: [CollegeModel],
        temporal: TemporalContext
    ) -> [CollegeInsight] {
        var insights = categorizationInsights(student: student, colleges: colleges)
        insights += deadlineInsights(student: student, today: temporal.today)
        return insights
    }

    // MARK: - Activities

    func analyzeActivityGaps(
        studentId: String,
        student: StudentContext,
        school: SchoolContext
    ) -> [ActivityRecommendation] {
        var out: [ActivityRecommendation] = []

        // 4 generals check
        if student.volunteering.isEmpty {
            out.append(.init(
                category: "volunteering",
                suggestion: "No volunteer hours logged yet.",
                rationale: "Colleges (and Bright Futures in FL) expect sustained volunteering."
                    + " Even 2 hrs/week adds up."
            ))
        }
        if student.clubs.isEmpty {
            out.append(.init(
                category: "clubs",
                suggestion: "Pick one club this month.",
                rationale: "Depth in 2-3 clubs beats a long shallow list. Any start is better than none."
            ))
        }
        if student.jobs.isEmpty && student.grade >= 10 {
            out.append(.init(
                category: "jobs",
                suggestion: "A part-time job or internship by junior summer.",
                rationale: "Shows maturity and real-world exposure — valuable signal on applications."
            ))
        }

        // Career-specific coverage
        if student.careerElectives.isEmpty, let path = student.careerPath {
            out.append(.init(
                category: "career-specific",
                suggestion: "Nothing \(path)-specific yet.",
                rationale: "A research project, internship, or sustained career-aligned activity"
                    + " is what separates serious applicants."
            ))
        }

        // Bright Futures volunteer hours gap (FL)
        if student.state == "FL", let bf = student.brightFuturesStatus,
           let gap = bf.hoursGapToFAS, gap > 0 {
            out.append(.init(
                category: "volunteering",
                suggestion: "\(Int(gap)) more hours for Bright Futures FAS.",
                rationale: "At 5 hrs/month, you'd hit it in \(Int(ceil(gap / 5.0))) months."
            ))
        }

        return out
    }

    // MARK: - SAT

    func evaluateSATProgress(
        studentId: String,
        student: StudentContext
    ) -> SATInsight? {
        let real = student.satScores.filter { !$0.isPractice }
        let all = student.satScores
        guard !all.isEmpty else { return nil }

        let scores = (real.isEmpty ? all : real).map(\.total)
        guard let latest = scores.last else { return nil }

        let label = satTrajectoryLabel(scores: scores)
        let target = student.targetSAT ?? (student.state == "FL" ? 1330 : 1200)
        let gap = max(0, target - latest)
        let weak = satWeakSections(from: student.satScores.last)
        let drill = satDrillSuggestion(weakSections: weak)

        return SATInsight(
            trajectoryLabel: label,
            gapToTarget: gap,
            weakSections: weak,
            nextDrillSuggestion: drill,
            weeklyPlanAvailable: true
        )
    }

    // MARK: - Essays

    func generateEssayStatus(
        studentId: String,
        student: StudentContext,
        temporal: TemporalContext
    ) -> [EssayInsight] {
        var out: [EssayInsight] = []
        let now = temporal.today

        for essay in student.essays {
            let stale: Int = {
                guard let editedDate = essay.lastEdited else { return 999 }
                return Calendar.current.dateComponents([.day], from: editedDate, to: now).day ?? 0
            }()

            // Priority and message based on draft count, staleness, and word count.
            if essay.draftNumber == 0 || (essay.wordCount == 0) {
                out.append(EssayInsight(
                    college: essay.college,
                    type: essay.type,
                    message: "\(essay.college) \(essay.type): not started.",
                    severity: .high
                ))
            } else if stale >= 14 {
                let msg = "\(essay.college) \(essay.type): last edited \(stale) days ago,"
                    + " draft #\(essay.draftNumber). Time to pick it back up."
                out.append(EssayInsight(college: essay.college, type: essay.type,
                                        message: msg, severity: .normal))
            } else if let limit = essay.wordLimit, essay.wordCount > limit {
                let over = essay.wordCount - limit
                let msg = "\(essay.college) \(essay.type): \(essay.wordCount)/\(limit) words"
                    + " — over the limit by \(over)."
                out.append(EssayInsight(college: essay.college, type: essay.type,
                                        message: msg, severity: .high))
            }
        }

        return out
    }

    // MARK: - Timeline

    func generateTimelineItems(
        studentId: String,
        student: StudentContext,
        temporal: TemporalContext
    ) -> [TimelineItem] {
        var items: [TimelineItem] = []

        // Upcoming real deadlines
        let now = temporal.today
        for dl in temporal.upcomingDeadlines {
            let status: TimelineItem.Status = dl.daysAway < 0 ? .overdue : .upcoming
            items.append(TimelineItem(title: dl.title, date: dl.date, kind: dl.kind, status: status))
        }

        // Seasonal priorities from the month-by-month calendar
        for priority in temporal.seasonalPriorities {
            items.append(TimelineItem(
                title: priority,
                date: now,
                kind: "milestone",
                status: .upcoming
            ))
        }

        return items
    }

    // MARK: - Financial Aid

    func evaluateFinancialAidStatus(
        studentId: String,
        student: StudentContext
    ) -> FinancialAidInsight {
        var bullets: [String] = []

        let fafsa = student.fafsaStatus ?? "not started"
        bullets.append("FAFSA: \(fafsa)\(fafsa == "not started" ? " — filing Oct-Nov = ~2x grant money" : "")")

        if let css = student.cssProfileStatus {
            bullets.append("CSS Profile: \(css)")
        }

        if student.state == "FL", let bf = student.brightFuturesStatus {
            let satGap = bf.satGapToFAS.map { " (\($0) pts to go)" } ?? ""
            let hoursGap = bf.hoursGapToFAS.map { " (\(Int($0)) hrs to go)" } ?? ""
            let bfLine = "Bright Futures \(bf.level): "
                + "GPA \(bf.gpaMet ? "✓" : "✗"), "
                + "SAT \(bf.satMet ? "✓" : "✗")\(satGap), "
                + "Hours \(bf.hoursMet ? "✓" : "✗")\(hoursGap)"
            bullets.append(bfLine)
        }

        if student.firstGen {
            bullets.append("First-gen: check QuestBridge, Posse, Gates, Dell Scholars, Jack Kent Cooke")
        }

        let headline: String = {
            if fafsa == "not started" { return "Your biggest money-left-on-the-table is FAFSA." }
            if student.state == "FL", let bf = student.brightFuturesStatus, !bf.satMet {
                return "Closing the SAT gap unlocks Bright Futures — that's real money."
            }
            return "Financial picture at a glance:"
        }()

        return FinancialAidInsight(headline: headline, bullets: bullets)
    }

    // MARK: - Notifications (max 2/week, only .critical and .high)

    func generateNotification(
        studentId: String,
        student: StudentContext,
        temporal: TemporalContext,
        school: SchoolContext,
        behavior: BehaviorSignals
    ) -> NotificationPayload? {
        let intents = NudgeRules.evaluate(student: student, temporal: temporal, school: school)
        guard let top = intents
            .filter({ $0.priority == .critical || $0.priority == .high })
            .sorted(by: { $0.priority.rank < $1.priority.rank })
            .first
        else { return nil }

        return NotificationPayload(
            title: top.title,
            body: top.rawMessage,
            deepLink: top.deepLink,
            priority: top.priority
        )
    }

    // MARK: - Class Plan (hybrid — rules compute gaps, LLM phrases the plan)

    func generateClassPlan(
        studentId: String,
        student: StudentContext,
        school: SchoolContext,
        temporal: TemporalContext
    ) async -> ClassPlan? {
        // Rule-based skeleton (career path + school offerings). LLM elaboration is
        // deferred until we have per-school class catalogs wired.
        guard let career = student.careerPath else { return nil }

        let targeted = career.lowercased()
        let apPool = school.apClasses.filter {
            switch targeted {
            case let career where career.contains("stem") || career.contains("engineer"):
                return $0.contains("Calc") || $0.contains("Physics")
                    || $0.contains("CS") || $0.contains("Computer")
            case let career where career.contains("medic"):
                return $0.contains("Bio") || $0.contains("Chem")
            case let career where career.contains("business"):
                return $0.contains("Econ") || $0.contains("Stat")
            default: return true
            }
        }

        let courses = apPool.prefix(4).map { Course(name: $0, level: "AP", period: nil, grade: nil) }
        return ClassPlan(
            tier: .challenging,
            courses: Array(courses),
            rationale: "Prioritized AP classes aligned to your \(career) path, drawn from what \(school.name) offers.",
            workloadEstimate: "~\(courses.count) APs — challenging but manageable with consistent study habits."
        )
    }

}

// Counselor surface → SiaEngine+Counselor.swift
// Return type models → SiaEngine+Models.swift

// MARK: - SiaEngine private college/SAT helpers (outside class body to stay within type_body_length)

private extension SiaEngine {

    func averageP25(_ college: CollegeModel) -> Int? {
        switch (college.satMath25, college.satReading25) {
        case let (math?, reading?): return math + reading
        default: return college.satAvg.map { Int(Double($0) * 0.95) }
        }
    }

    func averageP75(_ college: CollegeModel) -> Int? {
        switch (college.satMath75, college.satReading75) {
        case let (math?, reading?): return math + reading
        default: return college.satAvg.map { Int(Double($0) * 1.05) }
        }
    }

    func category(studentSAT: Int?, p25: Int?, p75: Int?) -> String {
        guard let sat = studentSAT else { return "target" }
        if let p75, sat >= p75 + 50 { return "safety" }
        if let p25, sat < p25 - 30 { return "reach" }
        return "target"
    }

    func satTrajectoryLabel(scores: [Int]) -> String {
        if scores.count >= 3 {
            let last3 = scores.suffix(3)
            let spread = (last3.max() ?? 0) - (last3.min() ?? 0)
            if spread <= 20 { return "plateauing" }
            if (last3.last ?? 0) < (last3.first ?? 0) { return "declining" }
            return "improving"
        } else if scores.count == 2 {
            let delta = scores[1] - scores[0]
            return delta > 20 ? "improving" : (delta < -20 ? "declining" : "stable")
        }
        return "no trend yet"
    }

    func satWeakSections(from score: SATScore?) -> [String] {
        guard let score,
              let rw = score.readingWriting,
              let math = score.math else { return [] }
        var weak: [String] = []
        if rw < math - 30 { weak.append("Reading & Writing") }
        if math < rw - 30 { weak.append("Math") }
        return weak
    }

    func satDrillSuggestion(weakSections: [String]) -> String {
        switch weakSections.first {
        case "Math":
            return "20 Algebra problems from Khan Academy this week — it's 35% of the Math section."
        case "Reading & Writing":
            return "Drill 10 Craft & Structure questions — biggest R&W content area."
        default:
            return "Take a full Bluebook practice test this weekend to pin down your weakest section."
        }
    }

    func categorizationInsights(student: StudentContext, colleges: [CollegeModel]) -> [CollegeInsight] {
        var insights: [CollegeInsight] = []
        let collegesByName = Dictionary(grouping: colleges, by: { $0.name })
        var reach = 0, target = 0, safety = 0

        for saved in student.savedColleges {
            guard let college = collegesByName[saved.name]?.first,
                  college.satAvg != nil
            else { continue }

            let computed = category(
                studentSAT: student.latestSAT,
                p25: averageP25(college),
                p75: averageP75(college)
            )
            switch computed {
            case "reach":  reach += 1
            case "target": target += 1
            case "safety": safety += 1
            default:       break
            }

            if computed != saved.category {
                let msg = "\(saved.name) moved from \(saved.category) to \(computed)"
                    + " based on your latest SAT (\(student.latestSAT ?? 0))."
                insights.append(CollegeInsight(collegeId: saved.id, message: msg, kind: .categoryShift))
            }
        }

        insights += listBalanceInsights(reach: reach, safety: safety, total: student.savedColleges.count)
        return insights
    }

    func listBalanceInsights(reach: Int, safety: Int, total: Int) -> [CollegeInsight] {
        guard total >= 3 else { return [] }
        var insights: [CollegeInsight] = []
        if reach >= 5 && safety <= 1 {
            let msg = "Your list is top-heavy — \(reach) reaches but only \(safety) safeties."
                + " Worth finding 2-3 targets where you'd be genuinely excited."
            insights.append(CollegeInsight(collegeId: "list", message: msg, kind: .listBalance))
        }
        if safety >= total - 1 && reach == 0 {
            let msg = "Your list is all safeties. Nothing wrong with that,"
                + " but add 1-2 targets or reaches if there are schools you actually love."
            insights.append(CollegeInsight(collegeId: "list", message: msg, kind: .listBalance))
        }
        return insights
    }

    func deadlineInsights(student: StudentContext, today: Date) -> [CollegeInsight] {
        var insights: [CollegeInsight] = []
        for app in student.applicationStatus {
            guard let deadline = app.deadline else { continue }
            let days = Calendar.current.dateComponents([.day], from: today, to: deadline).day ?? 0
            if days >= 0 && days <= 30 && app.status != "submitted" {
                let msg = "\(app.college) \(app.type) deadline in \(days) days"
                    + " — still showing \(app.status)."
                insights.append(CollegeInsight(collegeId: app.college, message: msg, kind: .deadlineWarning))
            }
        }
        return insights
    }
}
