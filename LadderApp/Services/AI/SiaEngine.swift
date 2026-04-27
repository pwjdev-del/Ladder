import Foundation
import SwiftData

// SiaEngine — the central intelligence powering every screen.
//
// Design contract (from Ladder_Sia_Architecture_v1.md):
//   - Rules decide WHAT to surface. LLM decides HOW to phrase it.
//   - Every screen calls in for its personalized content.
//   - Output is typed; views render without knowing about LLM plumbing.

@Observable
@MainActor
final class SiaEngine {
    static let shared = SiaEngine()
    private init() {}

    // MARK: - Home: "3 things this week"

    func generateHomeRecommendations(
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
        student: StudentContext,
        colleges: [CollegeModel],
        temporal: TemporalContext
    ) -> [CollegeInsight] {
        var insights: [CollegeInsight] = []

        // Categorize each saved college using middle-50% SAT range.
        let collegesByName = Dictionary(grouping: colleges, by: { $0.name })

        var reach = 0, target = 0, safety = 0

        for saved in student.savedColleges {
            guard let college = collegesByName[saved.name]?.first,
                  let p25 = college.satAvg ?? averageP25(college),
                  let _ = college.satAvg
            else { continue }

            let computed = category(studentSAT: student.latestSAT, p25: averageP25(college), p75: averageP75(college))
            switch computed {
            case "reach": reach += 1
            case "target": target += 1
            case "safety": safety += 1
            default: break
            }

            if computed != saved.category {
                insights.append(CollegeInsight(
                    collegeId: saved.id,
                    message: "\(saved.name) moved from \(saved.category) to \(computed) based on your latest SAT (\(student.latestSAT ?? 0)).",
                    kind: .categoryShift
                ))
            }
            _ = p25  // silence unused
        }

        // List balance
        let total = student.savedColleges.count
        if total >= 3 {
            if reach >= 5 && safety <= 1 {
                insights.append(CollegeInsight(
                    collegeId: "list",
                    message: "Your list is top-heavy — \(reach) reaches but only \(safety) safeties. Worth finding 2-3 targets where you'd be genuinely excited.",
                    kind: .listBalance
                ))
            }
            if safety >= total - 1 && reach == 0 {
                insights.append(CollegeInsight(
                    collegeId: "list",
                    message: "Your list is all safeties. Nothing wrong with that, but add 1-2 targets or reaches if there are schools you actually love.",
                    kind: .listBalance
                ))
            }
        }

        // Deadline warnings
        for app in student.applicationStatus {
            guard let dl = app.deadline else { continue }
            let days = Calendar.current.dateComponents([.day], from: temporal.today, to: dl).day ?? 0
            if days >= 0 && days <= 30 && app.status != "submitted" {
                insights.append(CollegeInsight(
                    collegeId: app.college,
                    message: "\(app.college) \(app.type) deadline in \(days) days — still showing \(app.status).",
                    kind: .deadlineWarning
                ))
            }
        }

        return insights
    }

    // MARK: - Activities

    func analyzeActivityGaps(
        student: StudentContext,
        school: SchoolContext
    ) -> [ActivityRecommendation] {
        var out: [ActivityRecommendation] = []

        // 4 generals check
        if student.volunteering.isEmpty {
            out.append(.init(category: "volunteering", suggestion: "No volunteer hours logged yet.",
                             rationale: "Colleges (and Bright Futures in FL) expect sustained volunteering. Even 2 hrs/week adds up."))
        }
        if student.clubs.isEmpty {
            out.append(.init(category: "clubs", suggestion: "Pick one club this month.",
                             rationale: "Depth in 2-3 clubs beats a long shallow list. Any start is better than none."))
        }
        if student.jobs.isEmpty && student.grade >= 10 {
            out.append(.init(category: "jobs", suggestion: "A part-time job or internship by junior summer.",
                             rationale: "Shows maturity and real-world exposure — valuable signal on applications."))
        }

        // Career-specific coverage
        if student.careerElectives.isEmpty, let path = student.careerPath {
            out.append(.init(category: "career-specific", suggestion: "Nothing \(path)-specific yet.",
                             rationale: "A research project, internship, or sustained career-aligned activity is what separates serious applicants."))
        }

        // Bright Futures volunteer hours gap (FL)
        if student.state == "FL", let bf = student.brightFuturesStatus, let gap = bf.hoursGapToFAS, gap > 0 {
            out.append(.init(category: "volunteering", suggestion: "\(Int(gap)) more hours for Bright Futures FAS.",
                             rationale: "At 5 hrs/month, you'd hit it in \(Int(ceil(gap / 5.0))) months."))
        }

        return out
    }

    // MARK: - SAT

    func evaluateSATProgress(student: StudentContext) -> SATInsight? {
        let real = student.satScores.filter { !$0.isPractice }
        let all = student.satScores
        guard !all.isEmpty else { return nil }

        let scores = (real.isEmpty ? all : real).map(\.total)
        let latest = scores.last!

        // Plateau detection: last 3 within ±20.
        var label = "improving"
        if scores.count >= 3 {
            let last3 = scores.suffix(3)
            let spread = (last3.max() ?? 0) - (last3.min() ?? 0)
            if spread <= 20 { label = "plateauing" }
            else if (last3.last ?? 0) < (last3.first ?? 0) { label = "declining" }
        } else if scores.count == 2 {
            let delta = scores[1] - scores[0]
            label = delta > 20 ? "improving" : (delta < -20 ? "declining" : "stable")
        } else {
            label = "no trend yet"
        }

        // Target = student.targetSAT OR 1330 if FL (Bright Futures FAS) OR 1200 default.
        let target = student.targetSAT ?? (student.state == "FL" ? 1330 : 1200)
        let gap = max(0, target - latest)

        // Weak sections heuristic: compare latest RW vs Math against target proportional split.
        var weak: [String] = []
        if let rw = student.satScores.last?.readingWriting, let math = student.satScores.last?.math {
            if rw < math - 30 { weak.append("Reading & Writing") }
            if math < rw - 30 { weak.append("Math") }
        }

        let drill: String = {
            switch weak.first {
            case "Math": return "20 Algebra problems from Khan Academy this week — it's 35% of the Math section."
            case "Reading & Writing": return "Drill 10 Craft & Structure questions — biggest R&W content area."
            default: return "Take a full Bluebook practice test this weekend to pin down your weakest section."
            }
        }()

        return SATInsight(
            trajectoryLabel: label,
            gapToTarget: gap,
            weakSections: weak,
            nextDrillSuggestion: drill,
            weeklyPlanAvailable: true
        )
    }

    // MARK: - Essays

    func generateEssayStatus(student: StudentContext, temporal: TemporalContext) -> [EssayInsight] {
        var out: [EssayInsight] = []
        let now = temporal.today

        for essay in student.essays {
            let stale: Int = {
                guard let e = essay.lastEdited else { return 999 }
                return Calendar.current.dateComponents([.day], from: e, to: now).day ?? 0
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
                out.append(EssayInsight(
                    college: essay.college,
                    type: essay.type,
                    message: "\(essay.college) \(essay.type): last edited \(stale) days ago, draft #\(essay.draftNumber). Time to pick it back up.",
                    severity: .normal
                ))
            } else if let limit = essay.wordLimit, essay.wordCount > limit {
                out.append(EssayInsight(
                    college: essay.college,
                    type: essay.type,
                    message: "\(essay.college) \(essay.type): \(essay.wordCount)/\(limit) words — over the limit by \(essay.wordCount - limit).",
                    severity: .high
                ))
            }
        }

        return out
    }

    // MARK: - Timeline

    func generateTimelineItems(
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

    func evaluateFinancialAidStatus(student: StudentContext) -> FinancialAidInsight {
        var bullets: [String] = []

        let fafsa = student.fafsaStatus ?? "not started"
        bullets.append("FAFSA: \(fafsa)\(fafsa == "not started" ? " — filing Oct-Nov = ~2x grant money" : "")")

        if let css = student.cssProfileStatus {
            bullets.append("CSS Profile: \(css)")
        }

        if student.state == "FL", let bf = student.brightFuturesStatus {
            bullets.append("Bright Futures \(bf.level): GPA \(bf.gpaMet ? "✓" : "✗"), SAT \(bf.satMet ? "✓" : "✗")\(bf.satGapToFAS.map { " (\($0) pts to go)" } ?? ""), Hours \(bf.hoursMet ? "✓" : "✗")\(bf.hoursGapToFAS.map { " (\(Int($0)) hrs to go)" } ?? "")")
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
            case let c where c.contains("stem") || c.contains("engineer"):
                return $0.contains("Calc") || $0.contains("Physics") || $0.contains("CS") || $0.contains("Computer")
            case let c where c.contains("medic"):
                return $0.contains("Bio") || $0.contains("Chem")
            case let c where c.contains("business"):
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

    // MARK: - Helpers

    private func averageP25(_ c: CollegeModel) -> Int? {
        switch (c.satMath25, c.satReading25) {
        case let (m?, r?): return m + r
        default: return c.satAvg.map { Int(Double($0) * 0.95) }
        }
    }

    private func averageP75(_ c: CollegeModel) -> Int? {
        switch (c.satMath75, c.satReading75) {
        case let (m?, r?): return m + r
        default: return c.satAvg.map { Int(Double($0) * 1.05) }
        }
    }

    private func category(studentSAT: Int?, p25: Int?, p75: Int?) -> String {
        guard let sat = studentSAT else { return "target" }
        if let p75, sat >= p75 + 50 { return "safety" }
        if let p25, sat < p25 - 30 { return "reach" }
        return "target"
    }
}

// MARK: - Return types

struct HomeCard: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var body: String
    var priority: SiaPriority
    var specialist: SessionType?
    var deepLink: String?
}

enum SiaPriority: String, Codable, Equatable {
    case critical
    case high
    case normal
    case low

    var rank: Int {
        switch self {
        case .critical: return 0
        case .high:     return 1
        case .normal:   return 2
        case .low:      return 3
        }
    }
}

struct CollegeInsight: Identifiable, Equatable {
    let id = UUID()
    var collegeId: String
    var message: String
    var kind: Kind
    enum Kind: String, Codable { case categoryShift, deadlineWarning, missingItem, listBalance, newSuggestion }
}

struct ActivityRecommendation: Identifiable, Equatable {
    let id = UUID()
    var category: String
    var suggestion: String
    var rationale: String
}

struct ClassPlan: Equatable {
    var tier: Tier
    var courses: [Course]
    var rationale: String
    var workloadEstimate: String
    enum Tier: String, Codable { case balanced, challenging, maximum }
}

struct SATInsight: Equatable {
    var trajectoryLabel: String
    var gapToTarget: Int
    var weakSections: [String]
    var nextDrillSuggestion: String
    var weeklyPlanAvailable: Bool
}

struct EssayInsight: Identifiable, Equatable {
    let id = UUID()
    var college: String
    var type: String
    var message: String
    var severity: SiaPriority
}

struct TimelineItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var date: Date
    var kind: String
    var status: Status
    enum Status: String, Codable { case done, upcoming, overdue }
}

struct FinancialAidInsight: Equatable {
    var headline: String
    var bullets: [String]
}

struct NotificationPayload: Equatable {
    var title: String
    var body: String
    var deepLink: String?
    var priority: SiaPriority
}
