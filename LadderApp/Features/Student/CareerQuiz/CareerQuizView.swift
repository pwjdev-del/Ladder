import SwiftUI

// §8.3 — sector-adaptive career quiz. Once-ever, locked after completion.
// Retake requires counselor override (audited).
// §6.2 — under-13 must have a parent co-present (COPPA gate).

public struct QuizQuestion: Identifiable, Sendable {
    public let id: String
    public let text: String
    public let gradeBand: GradeBand
    public let options: [QuizOption]
    public let nextByAnswer: [String: String]  // answerId -> nextQuestionId
}

public struct QuizOption: Identifiable, Sendable {
    public let id: String
    public let text: String
    public let imageSystemName: String?
}

public enum GradeBand: String, Sendable, Codable { case k2, g35, g68 }

@MainActor
final class CareerQuizViewModel: ObservableObject {
    @Published var current: QuizQuestion?
    @Published var answers: [String: String] = [:]
    @Published var completed = false
    @Published var locked = false

    private let tenantContext = TenantContext.shared
    private let ai = AIGatewayClient.shared

    func start(gradeBand: GradeBand) {
        guard !locked else { return }
        current = Self.placeholderQuestion(for: gradeBand)
    }

    func answer(_ option: QuizOption) {
        guard let q = current else { return }
        answers[q.id] = option.id
        if let nextId = q.nextByAnswer[option.id] {
            current = Self.nextStub(id: nextId, grade: q.gradeBand)
        } else {
            Task { await finish() }
        }
    }

    private func finish() async {
        completed = true
        locked = true
        // TODO: POST answers to /functions/v1/ai-gateway feature=career_quiz_scoring
        //       store career_profile_vector_cipher on students row.
    }

    private static func placeholderQuestion(for band: GradeBand) -> QuizQuestion {
        QuizQuestion(
            id: "q1",
            text: "Which do you like more?",
            gradeBand: band,
            options: [
                QuizOption(id: "a", text: "Building things",  imageSystemName: "hammer"),
                QuizOption(id: "b", text: "Telling stories",  imageSystemName: "book"),
            ],
            nextByAnswer: ["a": "q2_build", "b": "q2_story"]
        )
    }

    private static func nextStub(id: String, grade: GradeBand) -> QuizQuestion {
        QuizQuestion(id: id, text: "Another question about what you love.",
                     gradeBand: grade, options: [], nextByAnswer: [:])
    }
}

public struct CareerQuizView: View {
    @StateObject private var vm = CareerQuizViewModel()
    @State private var band: GradeBand = .g35

    public init() {}

    public var body: some View {
        Group {
            if vm.locked {
                LockedQuizView()
            } else if let q = vm.current {
                QuizQuestionView(question: q, onAnswer: vm.answer)
            } else {
                StartQuizView(band: $band) {
                    vm.start(gradeBand: band)
                }
            }
        }
        .navigationTitle("Career quiz")
    }
}

private struct StartQuizView: View {
    @Binding var band: GradeBand
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("You'll take this quiz once. Your answers help Ladder suggest classes, activities, and future pathways you'll love.")
                .font(.body)
            Text("A grown-up should sit with you if you're in K–5.")
                .font(.footnote).foregroundStyle(.secondary)

            Picker("Your grade band", selection: $band) {
                Text("K–2").tag(GradeBand.k2)
                Text("3–5").tag(GradeBand.g35)
                Text("6–8").tag(GradeBand.g68)
            }
            .pickerStyle(.segmented)

            Button("Start") { onStart() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct QuizQuestionView: View {
    let question: QuizQuestion
    let onAnswer: (QuizOption) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text(question.text).font(.title2)
            VStack(spacing: 12) {
                ForEach(question.options) { option in
                    Button {
                        onAnswer(option)
                    } label: {
                        HStack {
                            if let name = option.imageSystemName {
                                Image(systemName: name).font(.title2)
                            }
                            Text(option.text).font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding()
    }
}

private struct LockedQuizView: View {
    var body: some View {
        ContentUnavailableView(
            "Quiz completed",
            systemImage: "lock.fill",
            description: Text("You've already taken the career quiz. Ask your counselor if you need a retake — it has to be approved and is audited (§8.3).")
        )
    }
}
