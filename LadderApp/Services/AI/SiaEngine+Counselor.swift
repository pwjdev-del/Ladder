import Foundation

// SiaEngine+Counselor — counselor surface methods and supporting types.
//
// Separated from SiaEngine.swift to keep both files under the 500-line warning
// threshold (file_length rule). The extension is in the same module so it has
// access to all internal SiaEngine members.
//
// D-002 CONTRACT:
//   Counselors see SIA-generated summaries + safety flags + last-active.
//   They never see raw student_ai_chats rows. RLS on student_ai_chats enforces
//   this at the DB layer; assertCounselorIdentity() enforces it at the engine layer.

// MARK: - Counselor surface (D-002)

extension SiaEngine {

    /// Returns a counselor-facing topic summary for a given student.
    /// Reads ONLY from student_memory_summaries (counselor-read RLS) — never raw chat.
    /// D-002: Counselor may see SIA-generated summary + safety flags + last-active. Nothing else.
    func summarize(
        studentId: String,
        requestingCounselorAuthUid: String
    ) async throws -> StudentSiaSummary {
        try await assertCounselorIdentity(counselorAuthUid: requestingCounselorAuthUid)

        let client = SupabaseAuthService.shared.supabase

        // 1. Fetch up to 5 most-recent memory summaries for this student.
        // NOTE: student_memory_summaries uses student_user_id (migration 0014) — correct.
        let summaryRows: [MemorySummaryRow] = try await client
            .from("student_memory_summaries")
            .select("summary_text, created_at")
            .eq("student_user_id", value: studentId)
            .order("created_at", ascending: false)
            .limit(5)
            .execute()
            .value

        // Extract lightweight topic phrases from summary text.
        let combinedText = summaryRows.map(\.summaryText).joined(separator: " ")
        let topics = Self.extractTopics(from: combinedText)

        let summaryText: String = summaryRows.isEmpty
            ? ""
            : summaryRows.prefix(2).map(\.summaryText).joined(separator: " ")

        // 2. Fetch unreviewed safety flags.
        // Column map (migration 0019): student_id, triggered_by — NOT student_user_id / source.
        var flags: [SafetyFlag] = []
        do {
            let flagRows: [SafetyEventRow] = try await client
                .from("sia_safety_events")
                .select("id, flag_type, triggered_by, context_snippet, created_at, reviewed_at")
                .eq("student_id", value: studentId)
                .is("reviewed_at", value: nil)
                .order("created_at", ascending: false)
                .limit(10)
                .execute()
                .value
            flags = flagRows.compactMap { row -> SafetyFlag? in
                guard let uid = UUID(uuidString: row.id) else { return nil }
                return SafetyFlag(
                    id: uid,
                    type: row.flagType,
                    triggeredBy: row.triggeredBy,
                    createdAt: row.createdAt,
                    snippet: row.contextSnippet,
                    reviewed: row.reviewedAt != nil
                )
            }
        } catch {
            // D-002: a failed safety query means the counselor is seeing stale/missing
            // safety state. Log loudly — this is not benign in production.
            Log.error(
                "[D-002][SAFETY-QUERY-FAIL] sia_safety_events query failed"
                + " for studentId=\(studentId). Counselor safety panel is STALE."
                + " Error: \(error)"
            )
        }

        // 3. last-active = MAX(created_at) from student_memory_summaries (v1.0 proxy).
        let lastActiveAt = summaryRows.first?.createdAt

        return StudentSiaSummary(
            topics: topics,
            activeSafetyFlags: flags,
            lastActiveAt: lastActiveAt,
            summaryText: summaryText
        )
    }

    /// Counselor "Ask SIA" — the counselor types a question; SIA returns a short brief.
    /// SIA reads ONLY from student summaries, never raw chat.
    func briefCounselor(
        studentId: String,
        requestingCounselorAuthUid: String,
        question: String
    ) async throws -> String {
        try await assertCounselorIdentity(counselorAuthUid: requestingCounselorAuthUid)

        let client = SupabaseAuthService.shared.supabase

        // Build context payload from recent summaries ONLY — no raw chat reads.
        let summaryRows: [MemorySummaryRow] = try await client
            .from("student_memory_summaries")
            .select("summary_text, created_at")
            .eq("student_user_id", value: studentId)
            .order("created_at", ascending: false)
            .limit(5)
            .execute()
            .value

        guard !summaryRows.isEmpty else {
            return "SIA hasn't talked with this student yet,"
                + " so I don't have enough context to answer your question."
        }

        let summaryContext = summaryRows.enumerated().map { index, row in
            "Summary \(index + 1): \(row.summaryText)"
        }.joined(separator: "\n")

        struct BriefInput: Encodable {
            let studentId: String
            let counselorQuestion: String
            let summaryContext: String
        }

        guard let session = await SupabaseAuthService.shared.currentSession else {
            throw SiaIsolationError.noActiveSession
        }
        let accessToken = session.accessToken

        let response = try await AIGatewayClient.shared.call(
            feature: .counselorBrief,
            input: BriefInput(
                studentId: studentId,
                counselorQuestion: question,
                summaryContext: summaryContext
            ),
            accessToken: accessToken
        )

        return response.output
    }

    // MARK: - Counselor isolation assertion

    /// Verifies the requesting counselor's UID matches the live JWT uid AND that
    /// the bound TenantContext role is counselor or admin (D-003 defence-in-depth).
    private func assertCounselorIdentity(counselorAuthUid: String) async throws {
        let session = await SupabaseAuthService.shared.currentSession
        guard let uid = session?.user.id.uuidString else {
            Log.warn("[D-002] assertCounselorIdentity: no active session"
                     + " for counselorAuthUid=\(counselorAuthUid)")
            throw SiaIsolationError.noActiveSession
        }
        guard uid == counselorAuthUid else {
            Log.warn("[D-002] assertCounselorIdentity:"
                     + " uid mismatch — expected=\(counselorAuthUid) actual=\(uid)")
            throw SiaIsolationError.contextMismatch(expected: counselorAuthUid, actual: uid)
        }
        // D-003: UID match alone is insufficient — a student passing their own UID
        // would clear the UID check. Verify the JWT-bound role is counselor or admin.
        let boundRole = await TenantContext.shared.claim?.role
        guard boundRole == .counselor || boundRole == .admin else {
            let roleLabel = boundRole?.rawValue ?? "nil"
            Log.warn("[D-002] assertCounselorIdentity: role gate failed"
                     + " — uid=\(uid) role=\(roleLabel)")
            throw SiaIsolationError.roleNotCounselor(actual: roleLabel)
        }
    }

    // MARK: - Topic extraction heuristic (v1.1)

    /// Splits summary text into short topic phrases for the counselor surface.
    /// D-002: must produce "topics, not transcript" — no verbatim chat phrasing.
    ///
    /// v1.1 improvements over v1.0:
    ///   - Hard cap at 40 chars (v1.0 was 60 — leaked sentence-length phrasing).
    ///   - Strips leading first-person pronouns so the topic reads as a noun phrase.
    ///   - Title-cases the result for consistent display.
    ///   - Deduplicates by case-insensitive substring match (not just prefix).
    ///
    /// TODO v1.2: replace this heuristic with the structured `topics` JSONB column
    /// from `memory_extraction` once that field is being populated by the Edge Function.
    private static func extractTopics(from text: String) -> [String] {
        let sentences = text
            .components(separatedBy: CharacterSet(charactersIn: ".!?;"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count > 10 }

        // Drop leading first-person pronouns (I, My, i, my) so topics read as
        // noun phrases rather than verbatim student speech.
        let leadingPronounPattern = try? NSRegularExpression(
            pattern: "^(I|My|i|my)\\s+",
            options: []
        )
        var topics: [String] = []
        for sentence in sentences {
            let cleaned = strippingLeadingPronoun(sentence, pattern: leadingPronounPattern)
            let titled = titleCased(String(cleaned.prefix(40)))
            // Dedup: skip if any existing topic contains this one or vice versa.
            let titledLower = titled.lowercased()
            let isDuplicate = topics.contains {
                let existing = $0.lowercased()
                return existing.contains(titledLower) || titledLower.contains(existing)
            }
            if !isDuplicate {
                topics.append(titled)
            }
            if topics.count >= 5 { break }
        }
        return topics
    }

    private static func strippingLeadingPronoun(
        _ input: String,
        pattern: NSRegularExpression?
    ) -> String {
        guard let pattern else { return input }
        let range = NSRange(input.startIndex..., in: input)
        return pattern.stringByReplacingMatches(in: input,
                                                options: [],
                                                range: range,
                                                withTemplate: "")
    }

    private static func titleCased(_ input: String) -> String {
        guard let first = input.first else { return input }
        return first.uppercased() + input.dropFirst()
    }
}

// MARK: - Counselor data models

struct StudentSiaSummary {
    let topics: [String]
    let activeSafetyFlags: [SafetyFlag]
    let lastActiveAt: Date?
    let summaryText: String
}

struct SafetyFlag: Identifiable {
    let id: UUID
    let type: String
    /// Maps to `triggered_by` in `sia_safety_events` (migration 0019).
    let triggeredBy: String
    let createdAt: Date
    let snippet: String?
    let reviewed: Bool
}

// MARK: - Supabase row decoders (counselor surface)

private struct MemorySummaryRow: Decodable {
    let summaryText: String
    let createdAt: Date
    enum CodingKeys: String, CodingKey {
        case summaryText = "summary_text"
        case createdAt = "created_at"
    }
}

private struct SafetyEventRow: Decodable {
    let id: String
    let flagType: String
    /// Maps to `triggered_by` column (migration 0019). Was incorrectly `source` in v1.0.
    let triggeredBy: String
    let contextSnippet: String?
    let createdAt: Date
    let reviewedAt: Date?
    enum CodingKeys: String, CodingKey {
        case id
        case flagType = "flag_type"
        case triggeredBy = "triggered_by"
        case contextSnippet = "context_snippet"
        case createdAt = "created_at"
        case reviewedAt = "reviewed_at"
    }
}
