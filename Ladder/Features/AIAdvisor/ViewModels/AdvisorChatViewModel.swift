import SwiftUI
import SwiftData

// MARK: - Advisor Chat ViewModel
//
// Sia's chat surface. One relationship, seven specialist "hats" (see SessionType
// in Core/AI/Prompts/SessionType.swift). The system prompt for every message is
// assembled by PromptBuilder from the student's full context.
//
// Callers must `configure(profile:context:)` on appear so the ViewModel can build
// a fresh StudentContext each turn. Without configuration, the chat falls back to
// mock responses so the UI stays functional in dev.

@Observable
@MainActor
final class AdvisorChatViewModel {

    var messages: [ChatBubble] = []
    var inputText = ""
    var isTyping = false
    var sessionType: SessionType = .counselor
    var handoffBanner: String?              // set briefly when routing between specialists

    // Wired at view-appear time so we can build the full student context per turn.
    private weak var modelContext: ModelContext?
    private var profile: StudentProfileModel?
    private var memory: ConversationMemory = .empty
    private var behavior: BehaviorSignals = .empty
    private var school: SchoolContext = .unknown(state: nil)
    private(set) var activeSession: ChatSessionModel?

    // MARK: - Configuration (called from the View)

    func configure(
        profile: StudentProfileModel,
        context: ModelContext,
        memory: ConversationMemory = .empty,
        behavior: BehaviorSignals = .empty,
        school: SchoolContext? = nil,
        sessionId: String? = nil
    ) {
        self.profile = profile
        self.modelContext = context
        self.memory = memory
        self.behavior = behavior
        self.school = school ?? .unknown(state: profile.state)

        if let sid = sessionId, !sid.isEmpty {
            loadOrCreateSession(sessionId: sid, context: context)
        } else {
            createSession(context: context)
        }
    }

    // MARK: - Session persistence

    private func loadOrCreateSession(sessionId: String, context: ModelContext) {
        let descriptor = FetchDescriptor<ChatSessionModel>(
            predicate: #Predicate { $0.supabaseId == sessionId }
        )
        if let existing = (try? context.fetch(descriptor))?.first {
            activeSession = existing
            messages = existing.messages
                .sorted(by: { $0.createdAt < $1.createdAt })
                .map { stored in
                    ChatBubble(
                        role: stored.role == "user" ? .user : .assistant,
                        content: stored.content
                    )
                }
            return
        }
        createSession(context: context, supabaseId: sessionId)
    }

    private func createSession(context: ModelContext, supabaseId: String? = nil) {
        let session = ChatSessionModel(sessionType: sessionType.rawValue)
        session.supabaseId = supabaseId ?? UUID().uuidString
        context.insert(session)
        activeSession = session
        do { try context.save() } catch { Log.error("ChatSession create save failed: \(error)") }
    }

    private func persist(_ bubble: ChatBubble) {
        guard let ctx = modelContext, let session = activeSession else { return }
        guard bubble.role != .system else { return }
        let stored = ChatMessageModel(
            role: bubble.role == .user ? "user" : "assistant",
            content: bubble.content
        )
        stored.session = session
        session.updatedAt = Date()
        ctx.insert(stored)
        do { try ctx.save() } catch { Log.error("ChatMessage save failed: \(error)") }
    }

    // MARK: - Quick Prompts (surfaced at start of a session)

    static let quickPrompts: [QuickPrompt] = [
        QuickPrompt(title: "College List",     subtitle: "Help me build my list",   icon: "building.columns",            prompt: "Help me build a balanced college list with reach, match, and safety schools based on my profile."),
        QuickPrompt(title: "Essay Help",       subtitle: "Review my essay",         icon: "text.alignleft",              prompt: "I need help brainstorming ideas for my Common App personal statement."),
        QuickPrompt(title: "SAT Strategy",     subtitle: "Improve my score",        icon: "chart.line.uptrend.xyaxis",   prompt: "What's the best strategy to improve my SAT score based on my latest results?"),
        QuickPrompt(title: "Extracurriculars", subtitle: "Strengthen activities",   icon: "star.circle",                 prompt: "How can I strengthen my extracurricular profile for college applications?"),
        QuickPrompt(title: "Financial Aid",    subtitle: "Scholarship tips",        icon: "dollarsign.circle",           prompt: "What scholarships should I look into given my state and profile?"),
        QuickPrompt(title: "Timeline",         subtitle: "What to do now",          icon: "calendar.badge.clock",        prompt: "Given my grade and the current month, what should I be focused on right now?")
    ]

    // MARK: - Session switching (handoffs)

    /// Switch specialist mode. Carries a short handoff summary that's injected
    /// into the new specialist's system prompt.
    func switchTo(_ newType: SessionType, handoff: String? = nil) {
        guard newType != sessionType else { return }
        sessionType = newType
        handoffBanner = "Now in \(newType.specialistLabel) mode"
        if let h = handoff, !h.isEmpty {
            messages.append(ChatBubble(role: .system, content: h))
        }
        // Auto-clear banner after a beat.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            self.handoffBanner = nil
        }
    }

    // MARK: - Send Message

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userBubble = ChatBubble(role: .user, content: text)
        messages.append(userBubble)
        persist(userBubble)
        inputText = ""
        isTyping = true

        Task { @MainActor in
            do {
                let systemPrompt = try await buildSystemPrompt()
                let aiMessages = messages
                    .filter { $0.role != .system }
                    .map { AIMessage(role: $0.role == .user ? "user" : "assistant", content: $0.content) }

                let response = try await AIService.shared.sendMessage(
                    messages: aiMessages,
                    systemPrompt: systemPrompt
                )
                let assistantBubble = ChatBubble(role: .assistant, content: response)
                messages.append(assistantBubble)
                persist(assistantBubble)

                // Auto-route if Sia says she's handing off.
                if let handoff = HandoffRouter.detect(in: response),
                   handoff.target != sessionType {
                    switchTo(handoff.target, handoff: handoff.summary)
                }
            } catch {
                // AI service unavailable — fall back to a useful mock so UI stays alive.
                let fallback = ChatBubble(role: .assistant, content: generateMockResponse(for: text))
                messages.append(fallback)
                persist(fallback)
                Log.error("AdvisorChat send failed: \(error)")
            }
            isTyping = false
        }
    }

    func sendQuickPrompt(_ prompt: QuickPrompt) {
        inputText = prompt.prompt
        sendMessage()
    }

    // MARK: - Prompt assembly

    private func buildSystemPrompt() async throws -> String {
        guard let profile, let modelContext else {
            // Unconfigured. Use a minimal prompt so dev UIs still work.
            return "You are Sia, a college counselor. The student profile is not yet loaded — ask the student to complete onboarding first."
        }

        let student = StudentContextBuilder.build(from: profile, context: modelContext)
        let temporal = TemporalContextBuilder.build(for: student)

        // Refresh daysSinceLastSession for accurate memory framing.
        var mem = memory
        if let last = mem.lastSessionDate {
            mem.daysSinceLastSession = Calendar.current.dateComponents([.day], from: last, to: Date()).day
        }

        return PromptBuilder.buildSystemPrompt(
            for: sessionType,
            student: student,
            temporal: temporal,
            school: school,
            memory: mem,
            behavior: behavior
        )
    }

    // MARK: - Mock Response (fallback only)

    private func generateMockResponse(for input: String) -> String {
        let name = profile?.firstName ?? "there"
        return """
        Hey \(name) — I'm having trouble reaching the AI service right now. \
        Try again in a moment, or check your connection. I'll keep your message \
        here so we can pick up where we left off.
        """
    }
}

// MARK: - Models

struct ChatBubble: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()

    enum Role {
        case user, assistant, system   // system = internal banners, not sent to LLM
    }
}

struct QuickPrompt: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let prompt: String
}
