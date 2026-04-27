import Foundation
import SwiftData

// Maps the live SwiftData world -> a Codable StudentContext snapshot for the
// prompt layer. Called once per AI session (or whenever the prompt needs to
// rebuild). Keeps the prompt layer oblivious to SwiftData specifics.

enum StudentContextBuilder {

    /// Build a full StudentContext from the active student profile + related
    /// SwiftData models fetched from `context`.
    @MainActor
    static func build(
        from profile: StudentProfileModel,
        context: ModelContext
    ) -> StudentContext {

        let satScores = fetchSAT(context)
        let latest = satScores.last  // already sorted chronological

        let activities = fetchActivities(context)
        let gpaHistory = fetchGPA(context)
        let essays = fetchEssays(context)
        let apps = fetchApplications(context)
        let quizHistory = fetchQuizHistory(context)
        let collegeNameById = fetchCollegeNameIndex(context)

        let volunteering = activities.filter { $0.category == "Volunteering" }
        let clubs = activities.filter { $0.category == "Club" }
        let jobs = activities.filter { $0.category == "Job" || $0.category == "Internship" }
        let ath = activities.filter { $0.category == "Athletics" }
        let careerSpecific = activities.filter { isCareerSpecific($0.category) }

        let volunteerHours = volunteering.reduce(0.0) { acc, a in
            let hpw = a.hoursPerWeek ?? 0
            let wpy = a.weeksPerYear ?? 40
            return acc + hpw * wpy
        }

        let gpaTrend = computeGPATrend(gpaHistory)
        let satTrajectory = computeSATTrajectory(satScores)

        return StudentContext(
            name: profile.fullName,
            preferredName: profile.firstName,
            pronouns: nil,
            grade: profile.grade,
            age: nil,
            state: profile.state,
            firstGen: profile.isFirstGen,
            homeLanguage: nil,
            siblingsCollegeStatus: nil,

            gpaUnweighted: profile.gpa,
            gpaWeighted: gpaHistory.last?.weightedGPA,
            classRank: nil,
            gpaTrend: gpaTrend,
            strongSubjects: [],
            weakSubjects: [],
            currentClasses: [],
            pastTranscript: [],
            advancedCourses: profile.apCourses,
            apExamScores: [],

            satScores: satScores.map {
                SATScore(
                    date: $0.testDate,
                    total: $0.totalScore,
                    readingWriting: $0.readingScore,
                    math: $0.mathScore,
                    isPractice: $0.isPractice
                )
            },
            latestSAT: latest?.totalScore,
            latestSATDate: latest?.testDate,
            satSectionBreakdown: nil,
            satTrajectory: satTrajectory,
            targetSAT: nil,
            nextTestDate: nil,
            practiceTestHistory: [],
            feeWaiverEligible: profile.freeReducedLunch,
            feeWaiverUsed: false,

            careerPath: profile.careerPath,
            intendedMajor: profile.selectedMajor,
            careerQuizHistory: quizHistory.map {
                CareerQuizResult(
                    date: $0.dateTaken,
                    topResult: $0.topCareerPath,
                    secondaryResult: nil,
                    hollandCode: nil
                )
            },
            careerPathChanges: [],
            familyCareerExpectations: nil,
            hobbies: profile.interests,

            volunteering: volunteering.map(mapActivity),
            volunteerHours: volunteerHours,
            clubs: clubs.map {
                ClubActivity(
                    name: $0.name,
                    role: $0.role,
                    yearsIn: $0.gradeYears.count,
                    leadershipLevel: $0.isLeadership ? "officer" : "member"
                )
            },
            jobs: jobs.compactMap {
                guard let start = $0.startDate else { return nil }
                return JobActivity(
                    title: $0.role ?? $0.name,
                    employer: $0.organization ?? "",
                    hoursPerWeek: $0.hoursPerWeek ?? 0,
                    startDate: start,
                    endDate: $0.endDate
                )
            },
            athletics: ath.map {
                AthleticActivity(
                    sport: $0.name,
                    level: $0.role ?? "",
                    yearsIn: $0.gradeYears.count,
                    awards: []
                )
            },
            careerElectives: careerSpecific.map(mapActivity),
            awards: activities.filter { $0.category == "Award" }.map { $0.name },
            leadershipPositions: activities.filter { $0.isLeadership }.compactMap { $0.role },
            ecTierAssessment: ecTierLabel(activities),

            savedColleges: profile.savedCollegeIds.map { id in
                SavedCollege(
                    id: id,
                    name: collegeNameById[id] ?? id,
                    category: "target",
                    interestLevel: 3,
                    visited: false,
                    infoSession: false,
                    applied: apps.contains { $0.collegeId == id },
                    status: apps.first { $0.collegeId == id }?.status
                )
            },
            removedColleges: [],
            applicationStatus: apps.map {
                ApplicationStatus(
                    college: $0.collegeName,
                    type: $0.deadlineType ?? "RD",
                    status: $0.status,
                    deadline: $0.deadlineDate,
                    submittedAt: $0.submittedAt
                )
            },
            essays: essays.map {
                EssayStatus(
                    college: $0.collegeName,
                    type: $0.prompt.isEmpty ? "Personal Statement" : "Supplement",
                    prompt: $0.prompt,
                    draftNumber: 1,
                    wordCount: $0.wordCount,
                    wordLimit: $0.wordLimit,
                    lastEdited: $0.updatedAt,
                    latestFeedback: nil
                )
            },
            personalStatementStatus: essays.first(where: { $0.prompt.contains("Common App") })?.status,
            recLetters: [],

            fafsaStatus: nil,
            cssProfileStatus: nil,
            familyFinancialContext: profile.parentIncomeBracket,
            aidPackages: [],

            brightFuturesStatus: profile.state == "FL"
                ? computeBrightFutures(gpa: profile.gpa, sat: latest?.totalScore, hours: volunteerHours)
                : nil
        )
    }

    // MARK: - Fetches

    @MainActor
    private static func fetchSAT(_ ctx: ModelContext) -> [SATScoreEntryModel] {
        let d = FetchDescriptor<SATScoreEntryModel>(sortBy: [SortDescriptor(\.testDate)])
        return (try? ctx.fetch(d)) ?? []
    }

    @MainActor
    private static func fetchActivities(_ ctx: ModelContext) -> [ActivityModel] {
        (try? ctx.fetch(FetchDescriptor<ActivityModel>())) ?? []
    }

    @MainActor
    private static func fetchGPA(_ ctx: ModelContext) -> [GPAEntryModel] {
        let d = FetchDescriptor<GPAEntryModel>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? ctx.fetch(d)) ?? []
    }

    @MainActor
    private static func fetchEssays(_ ctx: ModelContext) -> [EssayModel] {
        (try? ctx.fetch(FetchDescriptor<EssayModel>())) ?? []
    }

    @MainActor
    private static func fetchApplications(_ ctx: ModelContext) -> [ApplicationModel] {
        (try? ctx.fetch(FetchDescriptor<ApplicationModel>())) ?? []
    }

    @MainActor
    private static func fetchQuizHistory(_ ctx: ModelContext) -> [CareerQuizHistoryModel] {
        let d = FetchDescriptor<CareerQuizHistoryModel>(sortBy: [SortDescriptor(\.dateTaken)])
        return (try? ctx.fetch(d)) ?? []
    }

    /// Index every CollegeModel by its saved-id (scorecardId string or name), so saved
    /// college ids in StudentProfileModel can be resolved to human names for AI prompts.
    @MainActor
    private static func fetchCollegeNameIndex(_ ctx: ModelContext) -> [String: String] {
        guard let colleges = try? ctx.fetch(FetchDescriptor<CollegeModel>()) else { return [:] }
        var map: [String: String] = [:]
        for c in colleges {
            if let sid = c.scorecardId { map[String(sid)] = c.name }
            map[c.name] = c.name
        }
        return map
    }

    // MARK: - Mappers / heuristics

    private static func mapActivity(_ a: ActivityModel) -> Activity {
        Activity(
            name: a.name,
            role: a.role,
            hoursPerWeek: a.hoursPerWeek,
            startDate: a.startDate,
            endDate: a.endDate,
            description: a.impactStatement
        )
    }

    private static func isCareerSpecific(_ category: String) -> Bool {
        ["Research", "Internship", "Leadership"].contains(category)
    }

    private static func computeGPATrend(_ history: [GPAEntryModel]) -> String? {
        guard let firstEntry = history.first,
              let lastEntry = history.last,
              history.count >= 2 else { return nil }
        let first = firstEntry.unweightedGPA
        let last = lastEntry.unweightedGPA
        let delta = last - first
        if abs(delta) < 0.1 { return "stable (~\(String(format: "%.2f", last)))" }
        if delta > 0 { return "rising (\(String(format: "%.2f", first)) → \(String(format: "%.2f", last)))" }
        return "dipped (\(String(format: "%.2f", first)) → \(String(format: "%.2f", last)))"
    }

    private static func computeSATTrajectory(_ scores: [SATScoreEntryModel]) -> String? {
        guard let firstScore = scores.first,
              let lastScore = scores.last,
              scores.count >= 2 else { return nil }
        let first = firstScore.totalScore
        let last = lastScore.totalScore
        let delta = last - first
        if abs(delta) < 30 { return "plateauing (\(first) → \(last))" }
        if delta > 0 { return "improving (\(first) → \(last), +\(delta))" }
        return "declining (\(first) → \(last), \(delta))"
    }

    private static func ecTierLabel(_ activities: [ActivityModel]) -> String? {
        guard !activities.isEmpty else { return nil }
        let tiers = activities.map { $0.tier }
        let best = tiers.min() ?? 4
        return "best activity at Tier \(best)"
    }

    private static func computeBrightFutures(gpa: Double?, sat: Int?, hours: Double) -> BrightFuturesStatus {
        let gpaMet = (gpa ?? 0) >= 3.5
        let satMet = (sat ?? 0) >= 1330
        let hoursMet = hours >= 100

        let level: String
        if gpaMet && satMet && hoursMet {
            level = "FAS"
        } else if (gpa ?? 0) >= 3.0 && (sat ?? 0) >= 1210 && hours >= 75 {
            level = "FMS"
        } else {
            level = "Not yet eligible"
        }

        return BrightFuturesStatus(
            level: level,
            gpaMet: gpaMet,
            satMet: satMet,
            hoursMet: hoursMet,
            satGapToFAS: satMet ? nil : max(0, 1330 - (sat ?? 0)),
            hoursGapToFAS: hoursMet ? nil : max(0, 100 - hours)
        )
    }
}
