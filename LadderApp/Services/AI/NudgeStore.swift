import Foundation
import SwiftData
import Supabase

// MARK: - NudgeStore
//
// Observable store that wraps NudgeRules.evaluate(), applies the 30-day dismissal
// suppression window (read from student_nudge_log), and enforces the 2-per-session cap.
//
// D-003: refresh(studentId:) asserts studentId == auth.uid() before ANY nudge
//        data is fetched or returned. Mismatch → throws SiaIsolationError.contextMismatch.
//        RLS on student_nudge_log already enforces this at the DB layer (migration 0014),
//        but the code-level assert runs first so the violation surfaces locally.

// MARK: - Session counter (app-lifetime singleton)

private enum NudgeSession {
    static let id = UUID()
    /// How many new nudges have been surfaced during this process lifetime.
    static var surfacedCount = 0
    /// Max new nudges per session (SPEC_v2.md §2.4).
    static let maxPerSession = 2
}

// MARK: - Supabase row types (Codable, for PostgREST responses)

private struct NudgeLogRow: Decodable {
    let nudgeType: String

    enum CodingKeys: String, CodingKey {
        case nudgeType = "nudge_type"
    }
}

private struct NudgeInsertPayload: Encodable {
    let tenantId: String
    let studentUserId: String
    let nudgeType: String
    let dismissed: Bool
    let acted: Bool

    enum CodingKeys: String, CodingKey {
        case tenantId       = "tenant_id"
        case studentUserId  = "student_user_id"
        case nudgeType      = "nudge_type"
        case dismissed
        case acted
    }
}

// MARK: - NudgeStore

@Observable
@MainActor
final class NudgeStore {

    static let shared = NudgeStore()
    private init() {}

    // MARK: - Published state

    var currentNudges: [NudgeIntent] = []
    var isLoading = false
    var error: String?

    // MARK: - Session dedup

    /// Nudge topic IDs surfaced to the student this session (in-memory; resets on cold launch).
    private var sessionSurfaced: Set<String> = []

    // MARK: - Refresh

    /// Evaluates nudges for the student, filters dismissed-within-30-days, caps at 2/session.
    ///
    /// - Parameters:
    ///   - studentId: auth.uid() of the student. Must match the live JWT (D-003).
    ///   - profile: The student's SwiftData profile (used to build StudentContext).
    ///   - context: Active SwiftData ModelContext.
    func refresh(studentId: String, profile: StudentProfileModel, context: ModelContext) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            // D-003: assert studentId == live auth.uid()
            try await assertIdentity(studentId: studentId)

            // Already capped for this session.
            if NudgeSession.surfacedCount >= NudgeSession.maxPerSession {
                return
            }

            // Build StudentContext + TemporalContext (pure, no AI call).
            let studentCtx = try await StudentContextBuilder.build(
                studentId: studentId,
                from: profile,
                context: context
            )
            let temporal = TemporalContextBuilder.build(for: studentCtx)
            let school = SchoolContext.unknown(state: studentCtx.state)

            // All candidate nudges from pure rules engine.
            let candidates = NudgeRules.evaluate(student: studentCtx, temporal: temporal, school: school)

            // Fetch dismissed nudge_types from student_nudge_log (last 30 days).
            let suppressedTopics = try await fetchSuppressedTopics(studentId: studentId)

            // Filter: exclude suppressed, already surfaced this session, then cap.
            let remaining = candidates
                .sorted { $0.priority.rank < $1.priority.rank }
                .filter { !suppressedTopics.contains($0.topic) }
                .filter { !sessionSurfaced.contains($0.topic) }

            let slots = NudgeSession.maxPerSession - NudgeSession.surfacedCount
            let toSurface = Array(remaining.prefix(max(0, slots)))

            // Track surfaced topics for session dedup.
            toSurface.forEach { sessionSurfaced.insert($0.topic) }
            NudgeSession.surfacedCount += toSurface.count

            currentNudges = toSurface

        } catch let e as SiaIsolationError {
            error = e.localizedDescription
        } catch {
            self.error = "Could not load nudges."
        }
    }

    // MARK: - Dismiss

    /// Writes dismissed=true to student_nudge_log and removes the nudge from currentNudges.
    /// The 30-day suppression window is enforced at the DB layer via created_at comparison
    /// in fetchSuppressedTopics(); this call just inserts the row.
    func dismiss(nudge: NudgeIntent, studentId: String) async {
        currentNudges.removeAll { $0.topic == nudge.topic }
        do {
            try await writeLog(nudge: nudge, studentId: studentId, dismissed: true, acted: false)
        } catch {
            // Non-fatal — nudge is already removed from UI. DB write will not retry.
            Log.warn("[NudgeStore] dismiss write failed: \(error)")
        }
    }

    // MARK: - Act

    /// Writes acted=true to student_nudge_log and removes the nudge from currentNudges.
    func act(nudge: NudgeIntent, studentId: String) async {
        currentNudges.removeAll { $0.topic == nudge.topic }
        do {
            try await writeLog(nudge: nudge, studentId: studentId, dismissed: false, acted: true)
        } catch {
            Log.warn("[NudgeStore] act write failed: \(error)")
        }
    }

    // MARK: - Private: fetch suppressed topics (dismissed in last 30 days)

    private func fetchSuppressedTopics(studentId: String) async throws -> Set<String> {
        guard (await SupabaseAuthService.shared.currentSession) != nil else {
            throw SiaIsolationError.noActiveSession
        }

        // Build ISO-8601 timestamp for now() - 30 days.
        let cutoff = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        let isoFormatter = ISO8601DateFormatter()
        let cutoffString = isoFormatter.string(from: cutoff)

        // PostgREST query on student_nudge_log:
        //   dismissed = true AND created_at > <cutoff>
        // RLS on the table ensures only the authenticated student's rows are returned.
        let db = await SupabaseAuthService.shared.supabase

        let rows: [NudgeLogRow] = try await db
            .from("student_nudge_log")
            .select("nudge_type")
            .eq("student_user_id", value: studentId)
            .eq("dismissed", value: true)
            .gte("created_at", value: cutoffString)
            .execute()
            .value

        return Set(rows.map(\.nudgeType))
    }

    // MARK: - Private: write log row

    private func writeLog(
        nudge: NudgeIntent,
        studentId: String,
        dismissed: Bool,
        acted: Bool
    ) async throws {
        guard (await SupabaseAuthService.shared.currentSession) != nil else {
            throw SiaIsolationError.noActiveSession
        }

        // Resolve tenant_id from TenantContext (required column — non-null).
        // Throw rather than silently dropping the write so callers can decide
        // whether to surface an error or swallow it with `try?`.
        let tenantId = TenantContext.shared.claim?.tenantId?.uuidString ?? ""
        guard !tenantId.isEmpty else {
            throw SiaIsolationError.tenantUnavailable
        }

        let payload = NudgeInsertPayload(
            tenantId: tenantId,
            studentUserId: studentId,
            nudgeType: nudge.topic,
            dismissed: dismissed,
            acted: acted
        )

        let db = await SupabaseAuthService.shared.supabase
        try await db
            .from("student_nudge_log")
            .insert(payload)
            .execute()
    }

    // MARK: - D-003 identity assertion

    private func assertIdentity(studentId: String) async throws {
        let session = await SupabaseAuthService.shared.currentSession
        guard let uid = session?.user.id.uuidString else {
            throw SiaIsolationError.noActiveSession
        }
        guard uid == studentId else {
            Log.warn("[NudgeStore] D-003 mismatch — expected=\(studentId) actual=\(uid)")
            throw SiaIsolationError.contextMismatch(expected: studentId, actual: uid)
        }
    }
}
