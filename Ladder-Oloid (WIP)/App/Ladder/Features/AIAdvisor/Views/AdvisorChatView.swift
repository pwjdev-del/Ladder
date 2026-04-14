import SwiftUI
import SwiftData

// MARK: - AI Advisor Chat View

struct AdvisorChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]
    @State private var viewModel = AdvisorChatViewModel()
    @FocusState private var isInputFocused: Bool
    let sessionId: String?

    // Sample session history for iPad left rail (UI only)
    private let sessionHistory: [ChatSessionPreview] = ChatSessionPreview.samples

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onAppear { viewModel.configure(with: profiles.first) }
    }

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: LadderSpacing.md) {
                            if viewModel.messages.isEmpty {
                                welcomeSection
                            }

                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isTyping {
                                typingIndicator
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.top, LadderSpacing.md)
                        .padding(.bottom, LadderSpacing.lg)
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input bar
                inputBar
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(spacing: 0) {
                iPadSessionRail
                    .frame(width: 320)
                    .background(LadderColors.surfaceContainerLow)

                Rectangle()
                    .fill(LadderColors.outlineVariant)
                    .frame(width: 1)

                iPadChatPane
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var iPadSessionRail: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.accentLime)
                Text("AI Advisor")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.top, LadderSpacing.lg)

            Button {
                viewModel.messages = []
                viewModel.inputText = ""
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "plus.bubble")
                        .font(.system(size: 14, weight: .semibold))
                    Text("New Chat")
                        .font(LadderTypography.labelLarge)
                    Spacer()
                }
                .foregroundStyle(LadderColors.primary)
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primaryContainer.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, LadderSpacing.md)

            Text("RECENT")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.sm)

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xs) {
                    ForEach(sessionHistory) { session in
                        iPadSessionRow(session)
                    }
                }
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.bottom, LadderSpacing.lg)
            }

            Divider()
                .padding(.horizontal, LadderSpacing.md)

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("QUICK TOOLS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.top, LadderSpacing.xs)

                ForEach(viewModel.quickPrompts.prefix(3)) { prompt in
                    Button {
                        viewModel.sendQuickPrompt(prompt)
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: prompt.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.primary)
                            Text(prompt.title)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                        }
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, LadderSpacing.md)
        }
    }

    private func iPadSessionRow(_ session: ChatSessionPreview) -> some View {
        Button { } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                HStack {
                    Text(session.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(1)
                    Spacer()
                    Text(session.timestamp)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Text(session.preview)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineLimit(2)
            }
            .padding(LadderSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LadderColors.surfaceContainer.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var iPadChatPane: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: LadderSpacing.md) {
                        if viewModel.messages.isEmpty {
                            welcomeSection
                        }

                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        if viewModel.isTyping {
                            typingIndicator
                        }
                    }
                    .padding(.horizontal, LadderSpacing.xl)
                    .padding(.top, LadderSpacing.lg)
                    .padding(.bottom, LadderSpacing.lg)
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            inputBar
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, LadderSpacing.xl)
                .padding(.bottom, LadderSpacing.md)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.accentLime)
                    Text("AI Advisor")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
    }

    // MARK: - Welcome Section (empty state)

    private var welcomeSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xxl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(spacing: LadderSpacing.sm) {
                Text("Hi! I'm your college advisor")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Ask me anything about college prep, applications, essays, or SAT strategies.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

            // Quick prompt chips
            VStack(spacing: LadderSpacing.sm) {
                ForEach(viewModel.quickPrompts.prefix(4)) { prompt in
                    Button {
                        viewModel.sendQuickPrompt(prompt)
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: prompt.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(LadderColors.primary)

                            Text(prompt.title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(LadderColors.onSurfaceVariant)
                        .frame(width: 6, height: 6)
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

            Spacer()
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: LadderSpacing.sm) {
            TextField("Ask your advisor...", text: $viewModel.inputText, axis: .vertical)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .onSubmit { viewModel.sendMessage() }

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? LadderColors.onSurfaceVariant.opacity(0.3)
                            : LadderColors.primary
                    )
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerLow)
    }
}

// MARK: - Chat Bubble View

struct ChatBubbleView: View {
    let message: ChatBubble

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: LadderSpacing.xs) {
                if message.role == .assistant {
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundStyle(LadderColors.accentLime)
                        Text("Advisor")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Text(LocalizedStringKey(message.content))
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(message.role == .user ? .white : LadderColors.onSurface)
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(
                        message.role == .user
                            ? LadderColors.primary
                            : LadderColors.surfaceContainerLow
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }

            if message.role == .assistant { Spacer(minLength: 60) }
        }
    }
}

// MARK: - iPad Session Preview Model (UI only)

struct ChatSessionPreview: Identifiable {
    let id = UUID()
    let title: String
    let timestamp: String
    let preview: String

    static let samples: [ChatSessionPreview] = [
        ChatSessionPreview(title: "Building my college list", timestamp: "Today", preview: "Help me find reach, match, and safety schools..."),
        ChatSessionPreview(title: "Common App essay ideas", timestamp: "Yesterday", preview: "I was thinking about writing about my robotics team..."),
        ChatSessionPreview(title: "SAT Math prep", timestamp: "Mon", preview: "How should I approach the no-calculator section?"),
        ChatSessionPreview(title: "EC strategy for junior year", timestamp: "Mar 30", preview: "What extracurriculars should I focus on to stand out..."),
        ChatSessionPreview(title: "Financial aid & scholarships", timestamp: "Mar 22", preview: "Looking into merit aid options for out-of-state..."),
    ]
}

#Preview {
    NavigationStack {
        AdvisorChatView(sessionId: nil)
    }
}
