import SwiftUI

// §10 — iterative AI session. Not a static list. Session state persisted in
// extracurricular_sessions table; student can resume.

public struct ExtracurricularSuggestion: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let fitRationale: String
    public let timeCommitment: String
    public let costSignal: String
    public let goalLink: String
    public let nextStep: String
}

// MARK: - Chat turn model

private struct ChatTurn: Identifiable {
    let id: UUID
    let role: String   // "you" | "ai"
    var text: String
    var isLoading: Bool

    init(role: String, text: String, isLoading: Bool = false) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.isLoading = isLoading
    }
}

// MARK: - AI input shape

private struct ExtracurricularInput: Encodable {
    let transcript: String
}

public struct ExtracurricularsView: View {
    @State private var draft = ""
    @State private var turns: [ChatTurn] = []
    @State private var suggestions: [ExtracurricularSuggestion] = []

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(turns) { turn in
                        HStack {
                            if turn.role == "you" { Spacer() }
                            if turn.isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Thinking…")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(10)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Text(turn.text)
                                    .padding(10)
                                    .background(turn.role == "you" ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            if turn.role == "ai" { Spacer() }
                        }
                    }
                    ForEach(suggestions) { s in
                        SuggestionCard(suggestion: s)
                    }
                }.padding()
            }
            Divider()
            HStack {
                TextField("Tell me what you like doing…", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button("Send") { send() }.disabled(draft.isEmpty)
            }.padding()
        }
        .navigationTitle("Things to try")
    }

    private func send() {
        let msg = draft
        draft = ""
        turns.append(ChatTurn(role: "you", text: msg))

        // Insert a placeholder assistant turn that shows a spinner while loading.
        let placeholder = ChatTurn(role: "ai", text: "", isLoading: true)
        let capturedID = placeholder.id
        turns.append(placeholder)

        Task {
            // Fetch the access token from the current session (non-throwing; nil if signed out).
            let token: String
            if let session = await SupabaseAuthService.shared.currentSession {
                token = session.accessToken
            } else {
                await replacePlaceholder(id: capturedID, text: "I couldn't reach the assistant. Try again?")
                return
            }

            // Build a plain-text transcript for the gateway input.
            let transcriptText = turns
                .filter { !$0.isLoading }
                .map { "\($0.role == "you" ? "Student" : "Advisor"): \($0.text)" }
                .joined(separator: "\n")

            do {
                let response = try await AIGatewayClient.shared.call(
                    feature: .extracurricularSession,
                    input: ExtracurricularInput(transcript: transcriptText),
                    accessToken: token
                )
                await replacePlaceholder(id: capturedID, text: response.output)
            } catch {
                await replacePlaceholder(id: capturedID, text: "I couldn't reach the assistant. Try again?")
            }
        }
    }

    @MainActor
    private func replacePlaceholder(id: UUID, text: String) {
        guard let idx = turns.firstIndex(where: { $0.id == id }) else { return }
        turns[idx].text = text
        turns[idx].isLoading = false
    }
}

private struct SuggestionCard: View {
    let suggestion: ExtracurricularSuggestion
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(suggestion.title).font(.headline)
            Text(suggestion.fitRationale).font(.body)
            HStack {
                Label(suggestion.timeCommitment, systemImage: "clock")
                Label(suggestion.costSignal, systemImage: "dollarsign.circle")
            }.font(.caption).foregroundStyle(.secondary)
            Text("Next step: \(suggestion.nextStep)").font(.footnote)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
