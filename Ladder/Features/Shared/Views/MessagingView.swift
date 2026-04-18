import SwiftUI
import SwiftData

// MARK: - Messaging View

struct MessagingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let recipientId: String

    @State private var messageText = ""
    @State private var session: ChatSessionModel?
    @State private var messages: [ChatMessageModel] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    if messages.isEmpty {
                        // Empty state
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "hand.wave.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("Start a conversation")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Send a message to get started")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 120)
                    } else {
                        LazyVStack(spacing: LadderSpacing.sm) {
                            ForEach(messages) { message in
                                let isUser = message.role == "user"
                                HStack {
                                    if isUser { Spacer() }
                                    Text(message.content)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(isUser ? .white : LadderColors.onSurface)
                                        .padding(LadderSpacing.md)
                                        .background(isUser ? LadderColors.primary : LadderColors.surfaceContainerLow)
                                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
                                        .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
                                    if !isUser { Spacer() }
                                }
                            }
                        }
                        .padding(LadderSpacing.lg)
                    }
                }

                // Input bar
                HStack(spacing: LadderSpacing.sm) {
                    TextField("Type a message...", text: $messageText)
                        .font(LadderTypography.bodyMedium)
                        .padding(LadderSpacing.md)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(Capsule())

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(LadderColors.primary)
                    }
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainer)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Messages").font(LadderTypography.titleSmall)
            }
        }
        .task {
            loadOrCreateSession()
        }
    }

    // MARK: - Data

    private func loadOrCreateSession() {
        // Find an existing messaging session for this recipient
        let descriptor = FetchDescriptor<ChatSessionModel>(
            predicate: #Predicate<ChatSessionModel> { s in
                s.sessionType == "messaging" && s.collegeId == recipientId
            }
        )
        if let existing = try? context.fetch(descriptor).first {
            session = existing
            loadMessages()
        } else {
            let newSession = ChatSessionModel(sessionType: "messaging")
            newSession.collegeId = recipientId
            newSession.title = "Messages"
            context.insert(newSession)
            try? context.save()
            session = newSession
        }
    }

    private func loadMessages() {
        guard let session else { return }
        messages = session.messages.sorted { $0.createdAt < $1.createdAt }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let session else { return }

        let msg = ChatMessageModel(role: "user", content: text)
        msg.session = session
        session.messages.append(msg)
        session.updatedAt = Date()
        context.insert(msg)
        try? context.save()

        messageText = ""
        loadMessages()
    }
}
