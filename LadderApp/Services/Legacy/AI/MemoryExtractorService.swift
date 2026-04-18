import Foundation
import SwiftData

// End-of-session memory extraction.
// Takes the chat transcript, runs a secondary LLM call with the extraction prompt,
// decodes the structured JSON, merges into the persisted ConversationMemory.
//
// Called from AdvisorChatView on disappear (if the session had substantive turns).

@MainActor
enum MemoryExtractorService {

    /// Extract + merge + persist. No-op if the session is too short to be worth analyzing.
    static func extractAndPersist(
        transcript: [ChatBubble],
        studentId: String,
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

        do {
            let raw = try await AIService.shared.sendMessage(
                messages: [AIMessage(role: "user", content: formatted)],
                systemPrompt: MemoryExtractor.systemPrompt
            )
            guard let extraction = parse(raw) else { return }

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
