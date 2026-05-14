import Foundation
import SwiftData

// End-of-session memory extraction.
// Takes the chat transcript, runs a secondary LLM call with the extraction prompt,
// decodes the structured JSON, merges into the persisted ConversationMemory.
//
// Called from AdvisorChatView on disappear (if the session had substantive turns).
//
// ChatBubble is defined here so MemoryExtractorService is self-contained and
// independent of Features/Legacy/AIAdvisor. When AdvisorChatView is un-quarantined
// it should import this canonical definition rather than redefining it.

struct ChatBubble: Identifiable {
    enum Role { case user, assistant, system }
    let id = UUID()
    var role: Role
    var content: String
}

@MainActor
enum MemoryExtractorService {

    /// Extract + merge + persist. No-op if the session is too short to be worth analyzing.
    /// `accessToken` is the Supabase session token forwarded to the ai-gateway Edge Function.
    /// `sessionId` is a stable UUID for this chat session — used as the Supabase upsert key
    ///  so retries never duplicate rows (idempotent via ON CONFLICT session_id).
    static func extractAndPersist(
        transcript: [ChatBubble],
        studentId: String,
        accessToken: String,
        sessionId: UUID = UUID(),
        context: ModelContext
    ) async {
        // Only extract if the conversation had real content (at least 2 student turns).
        let userTurns = transcript.filter { $0.role == .user }.count
        guard userTurns >= 2 else { return }

        let current = ConversationMemoryStore.load(studentId: studentId, context: context)

        let formatted = transcript
            .filter { $0.role != .system }
            .map { bubble -> String in
                let speaker = bubble.role == .user ? "Student" : "Sia"
                return "\(speaker): \(bubble.content)"
            }
            .joined(separator: "\n\n")

        // Wrap the transcript + extraction context as the AI gateway input.
        // S1-002: field renamed system_prompt → context_payload to match ai-gateway A4 contract.
        // S1-CR1: `studentId` added — required by MemoryExtractionInputSchema
        //         (ai-gateway/index.ts:141). Wire key is camelCase `studentId`.
        struct MemoryInput: Encodable {
            let studentId: String
            let transcript: String
            let contextPayload: String

            enum CodingKeys: String, CodingKey {
                case studentId    = "studentId"
                case transcript
                case contextPayload = "context_payload"
            }
        }

        do {
            let response = try await AIGatewayClient.shared.call(
                feature: .memoryExtraction,
                input: MemoryInput(
                    studentId: studentId,
                    transcript: formatted,
                    contextPayload: MemoryExtractor.systemPrompt
                ),
                accessToken: accessToken
            )
            guard let extraction = parse(response.output) else { return }

            let merged = MemoryExtractor.merge(into: current, extraction: extraction)

            // 1. Local write — source of truth. Always happens first.
            ConversationMemoryStore.save(merged, studentId: studentId, context: context)

            // 2. Remote sync — non-fatal backup. Runs after local write succeeds.
            //    Failure is logged loudly for QA but never surfaced to the user.
            if let summaryText = merged.lastSessionSummary, !summaryText.isEmpty {
                await syncSummaryToSupabase(
                    summaryText: summaryText,
                    studentId: studentId,
                    sessionId: sessionId
                )
            }
        } catch {
            // Extraction failure is non-fatal — we keep the prior memory intact.
        }
    }

    // MARK: - Supabase sync (T012)

    /// Upserts a session summary row to `student_memory_summaries`.
    /// Uses ON CONFLICT on `session_id` so repeated calls for the same session are idempotent.
    /// Failure is non-fatal: the local SwiftData write is the source of truth.
    private static func syncSummaryToSupabase(
        summaryText: String,
        studentId: String,
        sessionId: UUID
    ) async {
        // Resolve tenant_id from the live session claim. Required for RLS to allow INSERT.
        guard let tenantId = await TenantContext.shared.claim?.tenantId?.uuidString else {
            Log.warn("[T012-MemorySync] tenant_id unavailable — skipping Supabase sync for session \(sessionId)")
            return
        }

        struct SummaryRow: Encodable {
            let tenantId: String
            let studentUserId: String
            let summaryText: String
            let sessionId: String
            // embedding intentionally omitted — v1.1 will compute via AI pipeline

            enum CodingKeys: String, CodingKey {
                case tenantId       = "tenant_id"
                case studentUserId  = "student_user_id"
                case summaryText    = "summary_text"
                case sessionId      = "session_id"
            }
        }

        let row = SummaryRow(
            tenantId: tenantId,
            studentUserId: studentId,
            summaryText: summaryText,
            sessionId: sessionId.uuidString
        )

        do {
            try await SupabaseAuthService.shared.supabase
                .from("student_memory_summaries")
                .upsert(row, onConflict: "session_id", ignoreDuplicates: true)
                .execute()
            Log.info("[T012-MemorySync] summary synced for session \(sessionId)")
        } catch {
            // Loud warn — QA should catch this in console; user is never shown an error.
            // S3-2: redact studentId to last-4 chars (UUIDs of minors are PII);
            //        truncate error to 120 chars to avoid leaking schema detail in logs.
            let idSuffix = studentId.suffix(4)
            let truncatedError = String(error.localizedDescription.prefix(120))
            Log.warn("[T012-MemorySync] Supabase sync FAILED for session \(sessionId), student=...\(idSuffix) — \(truncatedError)")
        }
    }

    /// Tolerant JSON extraction. Models sometimes wrap JSON in markdown fences or
    /// leading prose — strip common wrappers before decoding.
    private static func parse(_ raw: String) -> MemoryExtractor.ExtractionResult? {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("```") {
            s = s.replacingOccurrences(of: "```json", with: "")
                 .replacingOccurrences(of: "```", with: "")
                 .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Find first { and last } to isolate the JSON object.
        if let start = s.firstIndex(of: "{"), let end = s.lastIndex(of: "}"), start < end {
            s = String(s[start...end])
        }
        guard let data = s.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MemoryExtractor.ExtractionResult.self, from: data)
    }
}
