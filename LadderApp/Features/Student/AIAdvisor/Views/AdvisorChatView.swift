import SwiftUI
import SwiftData

// MARK: - AdvisorChatView
//
// Student-facing SIA chat surface. Headline feature for v1.0.
// Pure SwiftUI — no UIKit hacks, no UIHostingController.
// Ported and rewritten from Features/Legacy/AIAdvisor/Views/AdvisorChatView.swift.
//
// NO references to legacy AIService or AuthManager.
//
// T023 — iPad parity:
//   Compact (iPhone, iPad multitask): full-width chat capped at 640pt via MaxWidthContainer.
//   Regular + portrait: MaxWidthContainer(640pt) centered.
//   Regular + landscape: AdaptiveContainer — chat primary (left) + memory sidebar detail (right).
//   Input bar uses .safeAreaInset(edge: .bottom) so the iPad software keyboard doesn't
//   push content behind the bar.

struct AdvisorChatView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @State private var viewModel: AdvisorChatViewModel
    @FocusState private var isInputFocused: Bool

    init(viewModel: AdvisorChatViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            BrandGradient.list.ignoresSafeArea()
            layoutBody
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                siaNavTitle
            }
        }
        .task {
            await viewModel.loadInitialState(context: modelContext)
        }
    }

    // MARK: - Adaptive layout

    @ViewBuilder
    private var layoutBody: some View {
        if hSizeClass == .regular {
            // iPad regular size class — use AdaptiveContainer for landscape split pane.
            // Portrait on iPad also gets MaxWidthContainer centering via the primary pane cap.
            AdaptiveContainer(primaryMaxWidth: 640) {
                chatPane
            } detail: {
                memorySidebarPane
            }
        } else {
            // iPhone (compact) — single column, no width cap needed on 390pt screens.
            chatPane
        }
    }

    // MARK: - Chat pane

    private var chatPane: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if let errorText = viewModel.error {
                    errorBanner(errorText)
                }

                messageList
            }

            // Use safeAreaInset so the input bar is above the home indicator AND
            // the keyboard pushes the chat scroll region up correctly on iPad.
            Color.clear
                .frame(height: 0)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            inputBar
        }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        welcomeSection
                    }

                    ForEach(viewModel.messages) { message in
                        ChatBubbleRow(message: message)
                            .id(message.id)
                    }

                    if viewModel.isLoading {
                        typingIndicator
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    if let lastId = viewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isLoading) { _, loading in
                if loading {
                    withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                }
            }
        }
    }

    // MARK: - Memory sidebar (iPad landscape detail pane)
    //
    // Read-only summary of what SIA remembers about the student.
    // Sourced from ConversationMemoryStore (local SwiftData) — no extra network call.
    // The sidebar shows: last session summary, open actions, topic history, preferences.

    private var memorySidebarPane: some View {
        MemorySidebarView(studentId: viewModel.studentId)
    }

    // MARK: - SIA nav title

    private var siaNavTitle: some View {
        VStack(spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LadderBrand.lime500)
                Text("SIA")
                    .font(.ladderDisplay(17, relativeTo: .headline))
                    .foregroundStyle(LadderBrand.cream100)
            }
            Text("your guide")
                .font(.ladderCaps(10))
                .tracking(0.8)
                .foregroundStyle(LadderBrand.cream100.opacity(0.6))
        }
    }

    // MARK: - Welcome (empty state)

    private var welcomeSection: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 32)

            ZStack {
                Circle()
                    .fill(LadderBrand.lime500.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(LadderBrand.lime500)
            }

            VStack(spacing: 8) {
                Text("Hi — I'm SIA")
                    .font(.ladderDisplay(22, relativeTo: .title2))
                    .foregroundStyle(LadderBrand.cream100)

                Text("Ask me anything — college prep, applications,\nessays, SAT, activities. I know your profile.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Typing indicator

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(LadderBrand.cream100.opacity(0.5))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(LadderBrand.forest700.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer()
        }
    }

    // MARK: - Error banner

    private func errorBanner(_ message: String) -> some View {
        Button {
            let ctx = modelContext
            Task { await viewModel.retryLastSend(context: ctx) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                Text(message)
                    .font(.ladderBody(13))
                Spacer()
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13))
            }
            .foregroundStyle(LadderBrand.ink900)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(LadderBrand.lime500.opacity(0.85))
        }
        .buttonStyle(.plain)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Input bar
    //
    // Pinned to the bottom via .safeAreaInset on the parent ZStack.
    // On iPad with the software keyboard, SwiftUI's safeArea adjusts correctly
    // without needing UIKeyboardLayoutGuide hacks.

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask SIA...", text: $viewModel.currentInput, axis: .vertical)
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.ink900)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LadderBrand.cream100)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .onSubmit {
                    submitIfNonEmpty()
                }

            Button {
                submitIfNonEmpty()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? LadderBrand.cream100.opacity(0.3)
                            : LadderBrand.lime500
                    )
            }
            .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      || viewModel.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(LadderBrand.forest900)
    }

    // MARK: - Helpers

    private func submitIfNonEmpty() {
        guard !viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let ctx = modelContext
        Task { await viewModel.send(context: ctx) }
    }
}

// MARK: - MemorySidebarView
//
// iPad landscape only — shown in the detail pane of AdaptiveContainer.
// Read-only view of what SIA remembers about the student from ConversationMemoryStore.
// No network call — reads local SwiftData. Refreshes when the view appears.

private struct MemorySidebarView: View {
    let studentId: String

    @Environment(\.modelContext) private var modelContext
    @State private var memory: ConversationMemory = .empty

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                sidebarHeader

                if !memory.allTimeSummary.isEmpty || memory.lastSessionSummary != nil {
                    memorySummarySection
                }

                if !memory.openActions.isEmpty {
                    openActionsSection
                }

                if !memory.topicHistory.isEmpty {
                    topicsSection
                }

                if !memory.learnedPreferences.isEmpty {
                    preferencesSection
                }

                if memory.allTimeSummary.isEmpty && memory.lastSessionSummary == nil {
                    emptyMemoryPlaceholder
                }
            }
            .padding(16)
        }
        .background(LadderBrand.forest900.opacity(0.6))
        .onAppear {
            memory = ConversationMemoryStore.load(studentId: studentId, context: modelContext)
        }
    }

    private var sidebarHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LadderBrand.lime500)
                Text("SIA REMEMBERS")
                    .font(.ladderCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(LadderBrand.lime500)
            }
            Text("What SIA knows about you so far.")
                .font(.ladderBody(12))
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))
        }
    }

    private var memorySummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LAST SESSION")
                .font(.ladderCaps(10))
                .tracking(1.0)
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))

            if let summary = memory.lastSessionSummary, !summary.isEmpty {
                Text(summary)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            } else if !memory.allTimeSummary.isEmpty {
                Text(memory.allTimeSummary)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var openActionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OPEN ACTIONS")
                .font(.ladderCaps(10))
                .tracking(1.0)
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))

            VStack(alignment: .leading, spacing: 6) {
                ForEach(memory.openActions.prefix(5)) { action in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle")
                            .font(.system(size: 10))
                            .foregroundStyle(LadderBrand.lime500.opacity(0.7))
                            .padding(.top, 2)
                        Text(action.description)
                            .font(.ladderBody(12))
                            .foregroundStyle(LadderBrand.cream100.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOPICS DISCUSSED")
                .font(.ladderCaps(10))
                .tracking(1.0)
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))

            // Deduplicated recent topics — show up to 10.
            let uniqueTopics = Array(NSOrderedSet(array: memory.topicHistory.suffix(20)))
                .compactMap { $0 as? String }
                .suffix(10)

            FlowLayout(spacing: 6) {
                ForEach(uniqueTopics, id: \.self) { topic in
                    Text(topic)
                        .font(.ladderCaps(10))
                        .tracking(0.6)
                        .foregroundStyle(LadderBrand.forest900)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(LadderBrand.lime500.opacity(0.85))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR PREFERENCES")
                .font(.ladderCaps(10))
                .tracking(1.0)
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))

            VStack(alignment: .leading, spacing: 6) {
                ForEach(memory.learnedPreferences.prefix(4)) { pref in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(LadderBrand.lime500.opacity(0.7))
                            .padding(.top, 2)
                        Text(pref.description)
                            .font(.ladderBody(12))
                            .foregroundStyle(LadderBrand.cream100.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyMemoryPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(LadderBrand.lime500.opacity(0.4))
            Text("Start chatting with SIA and your topics, actions, and preferences will appear here.")
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.cream100.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
    }
}

// FlowLayout — file-private, only used in MemorySidebarView for topic chips.

// MARK: - ChatBubbleRow

private struct ChatBubbleRow: View {
    let message: ChatMessage

    var body: some View {
        switch message.role {
        case .user:
            userBubble
        case .assistant:
            assistantBubble
        case .system:
            EmptyView() // system messages are internal; never rendered
        }
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 56)
            Text(message.content)
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.ink900)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LadderBrand.lime500)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var assistantBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            // SIA avatar mark
            ZStack {
                Circle()
                    .fill(LadderBrand.lime500.opacity(0.2))
                    .frame(width: 28, height: 28)
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderBrand.lime500)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("SIA")
                    .font(.ladderCaps(10))
                    .tracking(0.6)
                    .foregroundStyle(LadderBrand.cream100.opacity(0.55))

                Text(message.content)
                    .font(.ladderBody(15))
                    .foregroundStyle(LadderBrand.cream100)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(LadderBrand.forest700.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Spacer(minLength: 56)
        }
    }
}

// MARK: - Previews

#if DEBUG
private func makePreviewContainer() -> ModelContainer {
    (try? ModelContainer(for: ConversationMemoryModel.self, StudentProfileModel.self,
                         configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    ?? { fatalError("Preview container failed") }()
}

#Preview("iPhone 15", traits: .sizeThatFitsLayout) {
    NavigationStack {
        AdvisorChatView(
            viewModel: AdvisorChatViewModel(studentId: "preview-student-id")
        )
    }
    .frame(width: 393, height: 852)
    .modelContainer(makePreviewContainer())
}

#Preview("iPad Air portrait", traits: .sizeThatFitsLayout) {
    NavigationStack {
        AdvisorChatView(
            viewModel: AdvisorChatViewModel(studentId: "preview-student-id")
        )
    }
    .frame(width: 820, height: 1180)
    .environment(\.horizontalSizeClass, .regular)
    .modelContainer(makePreviewContainer())
}

#Preview("iPad Air landscape — split pane", traits: .sizeThatFitsLayout) {
    NavigationStack {
        AdvisorChatView(
            viewModel: AdvisorChatViewModel(studentId: "preview-student-id")
        )
    }
    .frame(width: 1180, height: 820)
    .environment(\.horizontalSizeClass, .regular)
    .modelContainer(makePreviewContainer())
}

#Preview("iPad Pro 12.9 portrait", traits: .sizeThatFitsLayout) {
    NavigationStack {
        AdvisorChatView(
            viewModel: AdvisorChatViewModel(studentId: "preview-student-id",
                                            seedMessage: "I want to talk about college apps")
        )
    }
    .frame(width: 1024, height: 1366)
    .environment(\.horizontalSizeClass, .regular)
    .modelContainer(makePreviewContainer())
}
#endif
