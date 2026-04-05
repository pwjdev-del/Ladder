import SwiftUI

// MARK: - AI Advisor Chat View

struct AdvisorChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdvisorChatViewModel()
    @FocusState private var isInputFocused: Bool
    let sessionId: String?

    var body: some View {
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
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
                ForEach(AdvisorChatViewModel.quickPrompts.prefix(4)) { prompt in
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

#Preview {
    NavigationStack {
        AdvisorChatView(sessionId: nil)
    }
}
