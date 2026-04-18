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

public struct ExtracurricularsView: View {
    @State private var draft = ""
    @State private var transcript: [(role: String, text: String)] = []
    @State private var suggestions: [ExtracurricularSuggestion] = []

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(transcript.enumerated()), id: \.offset) { _, turn in
                        HStack {
                            if turn.role == "you" { Spacer() }
                            Text(turn.text)
                                .padding(10)
                                .background(turn.role == "you" ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
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
        let msg = draft; draft = ""
        transcript.append((role: "you", text: msg))
        // TODO: AIGatewayClient.shared.call(feature: .extracurricularSession, input: state)
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
