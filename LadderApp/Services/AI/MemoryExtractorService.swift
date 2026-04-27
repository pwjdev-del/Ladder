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
    static func extractAndPersist(
        transcript: [ChatBubble],
        studentId: String,
        accessToken: String,
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

        // Wrap the transcript + extraction system prompt as the AI gateway input.
        struct MemoryInput: Encodable {
            let transcript: String
            let systemPrompt: String
        }

        do {
            let response = try await AIGatewayClient.shared.call(
                feature: .helpSurface,
                input: MemoryInput(
                    transcript: formatted,
                    systemPrompt: MemoryExtractor.systemPrompt
                ),
                accessToken: accessToken
            )
            guard let extraction = parse(response.output) else { return }

            let merged = MemoryExtractor.merge(into: current, extraction: extraction)
            ConversationMemoryStore.save(merged, studentId: studentId, context: context)
        } catch {
            // Extraction failure is non-fatal — we keep the prior memory intact.
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
