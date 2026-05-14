import SwiftUI
import SwiftData

// MARK: - AdvisorChatViewModel
//
// Drives the student-facing SIA chat surface.
//
// D-003 CONTRACT: `studentId` is a required init param sourced from
// `auth.uid()`. No default, no Optional — a missing studentId means
// the caller has broken the auth gate and must resolve it upstream.
//
// NO references to legacy AIService or AuthManager.

@Observable
@MainActor
final class AdvisorChatViewModel {

    // MARK: - Observed state

    var messages: [ChatMessage] = []
    var isLoading: Bool = false
    var error: String?
    var currentInput: String = ""
    /// Non-nil when the backend safety scan flagged crisis content in the last exchange.
    /// AdvisorChatView observes this to route the session to the counselor safety queue.
    /// v1.1: wire to a proper counselor-alert flow; for v1.0 this is observable state only.
    var activeSafetyFlag: String?
    /// Accumulates SSE deltas for the in-flight SIA response.
    /// The view renders this as a live-updating assistant bubble while the stream
    /// is open; it is reset to "" at the start of each new send.
    var streamingContent: String = ""

    // MARK: - Identity

    let studentId: String

    // MARK: - Init

    /// - Parameters:
    ///   - studentId: auth.uid() of the student (D-003 required).
    ///   - seedMessage: Optional pre-filled input text — set when launched from a nudge card
    ///                  so the student can see and edit the opening message before sending.
    ///                  Per SIA_PERSONA_RESEARCH.md §4: shown pre-filled, NOT auto-sent.
    init(studentId: String, seedMessage: String? = nil) {
        self.studentId = studentId
        if let seed = seedMessage, !seed.isEmpty {
            self.currentInput = seed
        }
    }

    // MARK: - Load initial state

    /// Seeds `messages` from persisted memory (migration 0014 / `ConversationMemoryStore`).
    ///
    /// T012 load order:
    ///   1. Attempt remote load from `student_memory_summaries` (most authoritative — survives reinstall).
    ///   2. On success: merge remote summary into local SwiftData store so it is available offline next time.
    ///   3. On any failure (offline, RLS error, no session): fall back to local SwiftData silently.
    ///   4. Show "Last time we talked…" header if any summary exists; otherwise D-001 warm-mentor opening.
    func loadInitialState(context: ModelContext) async {
        guard messages.isEmpty else { return }

        // Remote-first: try Supabase. On failure, fall through to local.
        var lastSummary: String? = nil

        do {
            let remoteEntries = try await ConversationMemoryStore.loadFromRemote(studentId: studentId)
            if let newest = remoteEntries.first {
                lastSummary = newest.summaryText

                // Merge the most recent remote summary into local SwiftData so the next
                // offline session can still surface it without a network round-trip.
                var local = ConversationMemoryStore.load(studentId: studentId, context: context)
                if local.lastSessionSummary != newest.summaryText {
                    local.lastSessionSummary = newest.summaryText
                    local.lastSessionDate = newest.createdAt
                    local.daysSinceLastSession = Calendar.current.dateComponents(
                        [.day], from: newest.createdAt, to: Date()
                    ).day
                    ConversationMemoryStore.save(local, studentId: studentId, context: context)
                }
            }
        } catch is SiaIsolationError {
            // Identity mismatch or missing session — do not surface to user; fall back to local.
            let sid = self.studentId
            Log.warn("[T012-LoadInitial] isolation error prevented remote load for studentId=\(sid)")
            let local = ConversationMemoryStore.load(studentId: self.studentId, context: context)
            lastSummary = local.lastSessionSummary
        } catch {
            // Offline, network failure, RLS rejection, etc.
            let sid = self.studentId
            Log.warn("[T012-LoadInitial] remote load failed for studentId=\(sid): \(error)")
            let local = ConversationMemoryStore.load(studentId: self.studentId, context: context)
            lastSummary = local.lastSessionSummary
        }

        // Surface the appropriate opening message.
        //
        // First-session detection: lastSessionSummary is nil AND chat history is empty.
        // This matches the ConversationMemory.empty state for brand-new students.
        // A returning student always has a non-nil lastSummary OR a non-empty chat history
        // from the SwiftData persistence layer (ChatMessageModel / ChatSessionModel).
        //
        // The opening message is prepended here as an `assistant` turn BEFORE any
        // gateway call, so the backend system prompt does not bake the opening in —
        // the client controls first-session detection via local SwiftData state.
        let isFirstSession = (lastSummary == nil || lastSummary!.isEmpty)

        // For the returning-session opener, extract a short topic phrase from the
        // full lastSessionSummary so the welcome-back references something specific.
        // Use the first sentence of the summary as the topic anchor.
        let lastSessionTopic: String? = {
            guard let summary = lastSummary, !summary.isEmpty else { return nil }
            // First sentence (up to the first period, "!", or "?") capped at 80 chars
            // so the welcome-back message stays concise on mobile.
            let sentence = summary
                .components(separatedBy: CharacterSet(charactersIn: ".!?"))
                .first?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? summary
            return sentence.count > 80 ? String(sentence.prefix(77)) + "..." : sentence
        }()

        let openingContent = SpecialistPrompts.siaOpeningMessage(
            forFirstSession: isFirstSession,
            lastSessionTopic: lastSessionTopic
        )
        messages.append(ChatMessage(role: .assistant, content: openingContent))
    }

    // MARK: - Send

    /// Appends the user's message immediately, builds the SIA context,
    /// opens the SSE stream from the ai-gateway, and streams SIA's response
    /// delta-by-delta into `streamingContent` so the view can render a live
    /// typing effect. On completion the full response is committed to `messages`.
    /// On failure, `error` is set so the view can show the retry banner.
    func send(context: ModelContext) async {
        let text = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        currentInput = ""
        isLoading = true
        streamingContent = ""
        error = nil

        defer {
            isLoading = false
            streamingContent = ""
        }

        do {
            // Auth — bearer token + user identity.
            guard let session = await SupabaseAuthService.shared.currentSession else {
                throw AdvisorChatError.unauthenticated
            }
            let accessToken = session.accessToken

            // Student profile — required by StudentContextBuilder (D-003).
            let descriptor = FetchDescriptor<StudentProfileModel>()
            guard let profile = (try? context.fetch(descriptor))?.first else {
                throw AdvisorChatError.profileMissing
            }

            // D-003: assertIdentity inside build() will throw SiaIsolationError
            // if studentId doesn't match the live JWT uid.
            let studentContext = try await StudentContextBuilder.build(
                studentId: studentId,
                from: profile,
                context: context
            )

            let temporal = TemporalContextBuilder.build(for: studentContext)
            let school = SchoolContext.unknown(state: studentContext.state)
            let memory = ConversationMemoryStore.load(studentId: studentId, context: context)
            let behavior = BehaviorSignals.empty

            // `.counselor` here is the AI persona's "hat" (Sia acting as a counselor
            // TO the student), NOT the role of the human user. SessionType describes
            // Sia's specialist mode, not who is sitting on the other end of the chat.
            // Changing this to a non-existent `.student` case would be wrong.
            let systemPrompt = PromptBuilder.buildSystemPrompt(
                for: .counselor,
                student: studentContext,
                temporal: temporal,
                school: school,
                memory: memory,
                behavior: behavior
            )

            // Build message history for the gateway (strip system bubbles).
            // Exclude the still-empty in-flight assistant bubble if present.
            let historyMessages = messages
                .filter { $0.role != .system }
                .map { SiaChatMessage(role: $0.role == .user ? "user" : "assistant", content: $0.content) }

            let input = SiaChatInput(systemPrompt: systemPrompt, messages: historyMessages)

            // --- SSE streaming path for sia_chat (A4 contract) ---
            var accumulated = ""
            var finalSafetyFlag: String? = nil

            for try await delta in AIGatewayClient.shared.streamSiaChat(
                input: input,
                accessToken: accessToken
            ) {
                switch delta {
                case .token(let chunk):
                    accumulated += chunk
                    streamingContent = accumulated
                case .done(let safetyFlag):
                    finalSafetyFlag = safetyFlag
                }
            }

            // Commit the fully-assembled response into the message list.
            let siaMessage = ChatMessage(role: .assistant, content: accumulated)
            messages.append(siaMessage)

            // Propagate any backend safety flag so the view can act on it.
            // v1.1: route to counselor safety queue via a Supabase RPC call here.
            if let flag = finalSafetyFlag {
                activeSafetyFlag = flag
                Log.warn("[SIA-SAFETY] safety_flag=\(flag) in response for studentId=\(self.studentId)")
            }

        } catch {
            self.error = "Something went wrong — tap to retry"
        }
    }

    // MARK: - Retry

    /// Re-queues the last user message and clears the error banner.
    func retryLastSend(context: ModelContext) async {
        guard let last = messages.last(where: { $0.role == .user }) else { return }
        currentInput = last.content
        messages.removeAll(where: { $0.id == last.id })
        error = nil
        await send(context: context)
    }
}

// MARK: - Private errors

private enum AdvisorChatError: LocalizedError {
    case unauthenticated
    case profileMissing

    var errorDescription: String? {
        switch self {
        case .unauthenticated: return "Session expired — please sign in again."
        case .profileMissing:  return "Student profile not found — please complete onboarding."
        }
    }
}

// MARK: - Gateway payload types

private struct SiaChatInput: Encodable {
    // S1-002: CodingKey raw value renamed from "system_prompt" → "context_payload"
    // to match ai-gateway A4 contract. Swift property name kept as `systemPrompt`
    // to avoid cascading caller churn.
    let systemPrompt: String
    let messages: [SiaChatMessage]

    enum CodingKeys: String, CodingKey {
        case systemPrompt = "context_payload"
        case messages
    }
}

private struct SiaChatMessage: Encodable {
    let role: String
    let content: String
}

// MARK: - SSE stream event

/// Decoded from each `data:` line of the sia_chat SSE stream.
private struct SiaStreamEvent: Decodable {
    let delta: String?
    let done: Bool?
    let safetyFlag: String?
    let inTokens: Int?
    let outTokens: Int?

    enum CodingKeys: String, CodingKey {
        case delta
        case done
        case safetyFlag  = "safety_flag"
        case inTokens    = "in_tokens"
        case outTokens   = "out_tokens"
    }
}

// MARK: - ChatMessage

/// Lightweight in-memory bubble for the active SIA chat surface.
/// Raw transcripts are persisted via ChatMessageModel / ChatSessionModel
/// when the persistence layer is wired (separate task).
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()

    enum Role {
        case user, assistant, system
    }
}
