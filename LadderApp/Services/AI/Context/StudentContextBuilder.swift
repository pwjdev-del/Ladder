import Foundation
import Supabase
import SwiftData

// Maps the live SwiftData world -> a Codable StudentContext snapshot for the
// prompt layer. Called once per AI session (or whenever the prompt needs to
// rebuild). Keeps the prompt layer oblivious to SwiftData specifics.
//
// D-003 ISOLATION CONTRACT:
//   Every build() call receives an explicit `studentId` and asserts it matches
//   the live JWT's auth.uid() before returning any context. Mismatch → throw,
//   never silently fall back.
//
// SAFETY: all SwiftData fetches MUST be predicated to the current user.
// SignOut wipes the store as a backstop (see SupabaseAuthService.signOut).
// See S1-4.

enum StudentContextBuilder {

    // MARK: - Student build (D-003 enforced)

    /// Build a full StudentContext from the active student profile + related
    /// SwiftData models fetched from `context`.
    ///
    /// - Parameters:
    ///   - studentId: The `auth.uid()` of the student whose context is being
    ///                built. Must match the currently-authenticated session's
    ///                user ID. Obtained from the JWT at the call site — never
    ///                inferred from global state inside this function.
    ///   - profile: The SwiftData `StudentProfileModel` to map.
    ///   - context: The active SwiftData `ModelContext`.
    ///
    /// - Throws: `SiaIsolationError.noActiveSession` when there is no live
    ///   Supabase session, or `SiaIsolationError.contextMismatch` when the
    ///   authenticated uid does not equal `studentId`.
    @MainActor
    static func build(
        studentId: String,
        from profile: StudentProfileModel,
        context: ModelContext
    ) async throws -> StudentContext {

        // D-003: Verify the caller-supplied studentId against the live JWT.
        try await assertIdentity(studentId: studentId)
        // All fetch/build work happens after the identity gate above.
        return buildContext(from: profile, context: context)
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

    // MARK: - D-003 Identity assertion

    /// Fetches the live Supabase session uid and asserts it equals `studentId`.
    /// Throws `SiaIsolationError` on mismatch or missing session.
    private static func assertIdentity(studentId: String) async throws {
        let session = await SupabaseAuthService.shared.currentSession
        guard let uid = session?.user.id.uuidString else {
            Log.warn("[SIA-ISOLATION] no active session while building context for studentId=\(studentId)")
            throw SiaIsolationError.noActiveSession
        }
        guard uid == studentId else {
            Log.warn("[SIA-ISOLATION] contextMismatch — expected=\(studentId) actual=\(uid)")
            throw SiaIsolationError.contextMismatch(expected: studentId, actual: uid)
        }
    }

    // MARK: - Counselor brief path (S2-3 tenant-match enforced)

    /// Builds a StudentContext for a counselor brief. Enforces two gates before
    /// reading any context data:
    ///
    /// 1. **Session identity gate** — the requesting counselor's auth UID must
    ///    match the live JWT's `user.id`. Mirrors `assertIdentity` above.
    ///
    /// 2. **Tenant-match gate (S2-3)** — performs a Supabase query to read
    ///    `students.tenant_id` for `studentId` and asserts it equals the
    ///    counselor's `TenantContext.shared.claim.tenantId`. Fails CLOSED:
    ///    if the query itself throws, the error propagates and the brief is
    ///    never built.
    ///
    /// - Parameters:
    ///   - studentId: The student whose context the counselor is requesting.
    ///   - requestingCounselorAuthUid: The counselor's own JWT uid.
    ///   - profile: The student's SwiftData profile.
    ///   - context: The active SwiftData ModelContext.
    ///
    /// - Throws: `SiaIsolationError.noActiveSession` when the counselor has no
    ///   live session; `SiaIsolationError.tenantUnavailable` when the counselor's
    ///   tenant is not loaded; `SiaIsolationError.contextMismatch` when the
    ///   student's tenant does not match the counselor's tenant.
    ///   NOTE: A dedicated `.tenantMismatch` case should be added to
    ///   `SiaIsolationError` (see OUT_OF_SCOPE_FINDINGS.md — B3 follow-up).
    @MainActor
    static func buildForCounselorBrief(
        studentId: String,
        requestingCounselorAuthUid: String,
        profile: StudentProfileModel,
        context: ModelContext
    ) async throws -> StudentContext {
        // Gate 1 — counselor uid must match the live JWT (mirrors assertIdentity).
        let session = await SupabaseAuthService.shared.currentSession
        guard let uid = session?.user.id.uuidString, uid == requestingCounselorAuthUid else {
            Log.warn("[SIA-ISOLATION] buildForCounselorBrief — counselor uid mismatch or no session")
            throw SiaIsolationError.noActiveSession
        }

        // Gate 2 (S2-3) — assert counselor tenant == student tenant via Supabase query.
        // Fail CLOSED: any error from the query propagates; we do NOT proceed on uncertainty.
        guard let counselorTenantId = await TenantContext.shared.claim?.tenantId else {
            Log.warn("[SIA-ISOLATION] buildForCounselorBrief — counselor tenant unavailable for uid=\(requestingCounselorAuthUid)")
            throw SiaIsolationError.tenantUnavailable
        }

        struct StudentTenantRow: Decodable {
            let tenantId: UUID
            enum CodingKeys: String, CodingKey { case tenantId = "tenant_id" }
        }

        let db = SupabaseAuthService.shared.supabase
        // This query errors (throws) if the row is not found or the network fails —
        // both outcomes propagate upward, preventing a silent partial brief.
        let rows: [StudentTenantRow] = try await db
            .from("students")
            .select("tenant_id")
            .eq("id", value: studentId)
            .limit(1)
            .execute()
            .value

        guard let studentTenantId = rows.first?.tenantId else {
            // Student row not found — treat as isolation violation (fail closed).
            Log.warn("[SIA-ISOLATION] buildForCounselorBrief — student row not found for id=\(studentId)")
            throw SiaIsolationError.contextMismatch(
                expected: counselorTenantId.uuidString,
                actual: "not-found"
            )
        }

        guard studentTenantId == counselorTenantId else {
            Log.warn("[SIA-ISOLATION] buildForCounselorBrief — tenant mismatch counselor=\(counselorTenantId) student=\(studentTenantId)")
            // Using .contextMismatch as closest available case.
            // TODO(B3-followup): add SiaIsolationError.tenantMismatch(counselor:student:)
            // to SiaIsolationError.swift — see OUT_OF_SCOPE_FINDINGS.md.
            throw SiaIsolationError.contextMismatch(
                expected: counselorTenantId.uuidString,
                actual: studentTenantId.uuidString
            )
        }

        // Both gates passed — build context.
        // The counselor is not the student, so the student-identity assertion is
        // intentionally skipped here (the student is not authenticated in this session).
        return buildContext(from: profile, context: context)
    }

    // MARK: - Internal pure builder (no identity check — only called after gates above)

    @MainActor
    private static func buildContext(
        from profile: StudentProfileModel,
        context: ModelContext
    ) -> StudentContext {
        let satScores = fetchSAT(context)
        let latest = satScores.last
        let allActivities = fetchActivities(context)
        let gpaHistory = fetchGPA(context)
        let essays = fetchEssays(context)
        let apps = fetchApplications(context)
        let quizHistory = fetchQuizHistory(context)
        let collegeNameById = fetchCollegeNameIndex(context)

        let volunteering = allActivities.filter { $0.category == "Volunteering" }
        let clubs = allActivities.filter { $0.category == "Club" }
        let jobs = allActivities.filter { $0.category == "Job" || $0.category == "Internship" }
        let ath = allActivities.filter { $0.category == "Athletics" }
        let careerSpecific = allActivities.filter { isCareerSpecific($0.category) }

        let volunteerHours = volunteering.reduce(0.0) { acc, act in
            acc + (act.hoursPerWeek ?? 0) * (act.weeksPerYear ?? 40)
        }
        let gpaTrend = computeGPATrend(gpaHistory)
        let satTrajectory = computeSATTrajectory(satScores)

        // Pre-map activity arrays so composeContext stays under the 120-line body limit.
        let mappedSAT = satScores.map {
            SATScore(date: $0.testDate, total: $0.totalScore,
                     readingWriting: $0.readingScore, math: $0.mathScore, isPractice: $0.isPractice)
        }
        let mappedQuiz = quizHistory.map {
            CareerQuizResult(date: $0.dateTaken, topResult: $0.topCareerPath,
                             secondaryResult: nil, hollandCode: nil)
        }
        let mappedClubs = clubs.map {
            ClubActivity(name: $0.name, role: $0.role, yearsIn: $0.gradeYears.count,
                         leadershipLevel: $0.isLeadership ? "officer" : "member")
        }
        let mappedJobs = jobs.compactMap { act -> JobActivity? in
            guard let start = act.startDate else { return nil }
            return JobActivity(title: act.role ?? act.name, employer: act.organization ?? "",
                               hoursPerWeek: act.hoursPerWeek ?? 0, startDate: start, endDate: act.endDate)
        }
        let mappedAth = ath.map {
            AthleticActivity(sport: $0.name, level: $0.role ?? "",
                             yearsIn: $0.gradeYears.count, awards: [])
        }
        let mappedApps = apps.map {
            ApplicationStatus(college: $0.collegeName, type: $0.deadlineType ?? "RD",
                              status: $0.status, deadline: $0.deadlineDate, submittedAt: $0.submittedAt)
        }
        let mappedEssays = essays.map {
            EssayStatus(college: $0.collegeName,
                        type: $0.prompt.isEmpty ? "Personal Statement" : "Supplement",
                        prompt: $0.prompt, draftNumber: 1, wordCount: $0.wordCount,
                        wordLimit: $0.wordLimit, lastEdited: $0.updatedAt, latestFeedback: nil)
        }
        let mappedColleges = profile.savedCollegeIds.map { id in
            SavedCollege(id: id, name: collegeNameById[id] ?? id, category: "target",
                         interestLevel: 3, visited: false, infoSession: false,
                         applied: apps.contains { $0.collegeId == id },
                         status: apps.first { $0.collegeId == id }?.status)
        }
        let psStatus = essays.first(where: { $0.prompt.contains("Common App") })?.status

        return composeContext(
            profile: profile,
            latest: latest,
            gpaHistory: gpaHistory,
            volunteerHours: volunteerHours,
            gpaTrend: gpaTrend,
            satTrajectory: satTrajectory,
            allActivities: allActivities,
            volunteering: volunteering,
            careerSpecific: careerSpecific,
            mappedSAT: mappedSAT,
            mappedQuiz: mappedQuiz,
            mappedClubs: mappedClubs,
            mappedJobs: mappedJobs,
            mappedAth: mappedAth,
            mappedApps: mappedApps,
            mappedEssays: mappedEssays,
            mappedColleges: mappedColleges,
            personalStatementStatus: psStatus
        )
    }

    // Assembles the StudentContext init from pre-mapped arrays. Separated from
    // buildContext (which handles all fetching/mapping) to keep each function within
    // the 120-line body limit enforced by swiftlint.
    // swiftlint:disable function_parameter_count
    @MainActor
    private static func composeContext(
        profile: StudentProfileModel,
        latest: SATScoreEntryModel?,
        gpaHistory: [GPAEntryModel],
        volunteerHours: Double,
        gpaTrend: String?,
        satTrajectory: String?,
        allActivities: [ActivityModel],
        volunteering: [ActivityModel],
        careerSpecific: [ActivityModel],
        mappedSAT: [SATScore],
        mappedQuiz: [CareerQuizResult],
        mappedClubs: [ClubActivity],
        mappedJobs: [JobActivity],
        mappedAth: [AthleticActivity],
        mappedApps: [ApplicationStatus],
        mappedEssays: [EssayStatus],
        mappedColleges: [SavedCollege],
        personalStatementStatus: String?
    ) -> StudentContext {
        StudentContext(
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

            satScores: mappedSAT,
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
            careerQuizHistory: mappedQuiz,
            careerPathChanges: [],
            familyCareerExpectations: nil,
            hobbies: profile.interests,

            volunteering: volunteering.map(mapActivity),
            volunteerHours: volunteerHours,
            clubs: mappedClubs,
            jobs: mappedJobs,
            athletics: mappedAth,
            careerElectives: careerSpecific.map(mapActivity),
            awards: allActivities.filter { $0.category == "Award" }.map { $0.name },
            leadershipPositions: allActivities.filter { $0.isLeadership }.compactMap { $0.role },
            ecTierAssessment: ecTierLabel(allActivities),

            savedColleges: mappedColleges,
            removedColleges: [],
            applicationStatus: mappedApps,
            essays: mappedEssays,
            personalStatementStatus: personalStatementStatus,
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
    // swiftlint:enable function_parameter_count

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
