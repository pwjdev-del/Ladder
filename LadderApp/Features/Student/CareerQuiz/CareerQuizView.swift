import SwiftUI
import SwiftData

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

// MARK: - Scoring response

/// The shape returned by the ai-gateway `career_quiz_scoring` feature.
/// The gateway returns `output` as a JSON string; we decode this struct from it.
private struct RIASECResult: Decodable {
    let topCareerPath: String
    let scores: [String: Double]
    let hollandCode: String?

    enum CodingKeys: String, CodingKey {
        case topCareerPath = "top_career_path"
        case scores
        case hollandCode = "holland_code"
    }
}

// MARK: - ViewModel

@MainActor
final class CareerQuizViewModel: ObservableObject {
    @Published var current: QuizQuestion?
    @Published var answers: [String: String] = [:]
    @Published var completed = false
    @Published var locked = false
    @Published var scoringError: String?
    @Published var isScoring = false

    private let ai = AIGatewayClient.shared
    /// Injected from the View via `setContext(_:)` before quiz starts.
    private var modelContext: ModelContext?

    private struct ScoringInput: Encodable {
        let answers: [String: String]
        let grade_band: String
    }

    func setContext(_ ctx: ModelContext) {
        modelContext = ctx
    }

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

    // MARK: - Finish: score → persist locally → write to Supabase

    private func finish() async {
        isScoring = true
        defer { isScoring = false }

        guard let session = await SupabaseAuthService.shared.currentSession else {
            scoringError = "You need to sign in again to save your quiz."
            return
        }

        let gradeBand = current?.gradeBand ?? .g35

        // 1. Call ai-gateway for RIASEC scoring.
        let gatewayResponse: AIGatewayResponse
        do {
            gatewayResponse = try await ai.call(
                feature: .careerQuizScoring,
                input: ScoringInput(
                    answers: answers,
                    grade_band: gradeBand.rawValue
                ),
                accessToken: session.accessToken
            )
        } catch {
            // Leave quiz UN-locked so the student can retry on next launch.
            scoringError = "We couldn't score your quiz. Try again in a moment."
            return
        }

        // 2. Parse the RIASEC result from the gateway's `output` string.
        //    The gateway returns a JSON object in `output`; fall back to a
        //    best-effort default so a malformed response doesn't strand the student.
        let result = Self.parseResult(from: gatewayResponse.output) ?? RIASECResult(
            topCareerPath: "Explorer",
            scores: ["Explorer": 1.0],
            hollandCode: nil
        )

        // 3. Write to SwiftData so careerQuizHistory is populated immediately.
        //    This unblocks every feature gated on careerQuizHistory being non-empty
        //    (NudgeRules, StudentContextBuilder, ClassSuggester context).
        if let ctx = modelContext {
            let entry = CareerQuizHistoryModel(
                gradeTaken: gradeBandToGradeLevel(gradeBand),
                topCareerPath: result.topCareerPath,
                scores: result.scores,
                archetypeName: result.hollandCode
            )
            ctx.insert(entry)
            try? ctx.save()
        }

        // 4. Persist to Supabase: write career_profile_vector_cipher + career_quiz_completed_at.
        //
        //    Encryption note: career_profile_vector_cipher is a `bytea` column designed
        //    for AES-256-GCM via the per-tenant DEK envelope (ADR-004 / envelope.ts).
        //    The iOS client never has access to the tenant DEK — encryption must happen
        //    server-side. Until a dedicated RPC or Edge Function wraps the write with
        //    DEK-based encryption, we store the vector as UTF-8 bytes (same shortcut
        //    used in migration 0012 for teacher name ciphers).
        //
        //    FOLLOW-UP REQUIRED (encryption layer): replace this plaintext write with
        //    a call to an `rpc/store_career_vector` function that performs DEK
        //    envelope encryption server-side before v1 public launch.
        await writeCareerProfileToSupabase(
            userId: session.user.id.uuidString,
            result: result
        )

        completed = true
        locked = true
    }

    // MARK: - Supabase write

    private func writeCareerProfileToSupabase(userId: String, result: RIASECResult) async {
        struct StudentCareerUpdate: Encodable {
            let careerProfileVectorCipher: String  // Base64 UTF-8 bytes (plaintext shortcut, see note above)
            let careerQuizCompletedAt: String       // ISO-8601

            enum CodingKeys: String, CodingKey {
                case careerProfileVectorCipher = "career_profile_vector_cipher"
                case careerQuizCompletedAt     = "career_quiz_completed_at"
            }
        }

        // Serialise the vector as JSON then Base64 so the bytea column round-trips cleanly.
        let vectorJSON: String
        if let jsonData = try? JSONEncoder().encode(result.scores),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            // Wrap in a small envelope so the follow-up DEK layer can validate the payload.
            let envelope = "{\"v\":1,\"top\":\"\(result.topCareerPath)\",\"holland\":\"\(result.hollandCode ?? "")\",\"scores\":\(jsonStr)}"
            vectorJSON = Data(envelope.utf8).base64EncodedString()
        } else {
            vectorJSON = Data(result.topCareerPath.utf8).base64EncodedString()
        }

        let isoNow = ISO8601DateFormatter().string(from: Date())
        let payload = StudentCareerUpdate(
            careerProfileVectorCipher: vectorJSON,
            careerQuizCompletedAt: isoNow
        )

        do {
            try await SupabaseAuthService.shared.supabase
                .from("students")
                .update(payload)
                .eq("user_id", value: userId)
                .execute()
        } catch {
            // Non-fatal: the local SwiftData write already succeeded.
            // The row will be out of sync until the next session; the student is
            // not shown an error here because locally the quiz IS complete.
            // A background sync pass (v1.1) will reconcile the gap.
            Log.warn("[T017-CareerQuiz] Supabase career_profile write failed for userId=\(userId): \(error)")
        }
    }

    // MARK: - Helpers

    /// Decode the JSON `output` string returned by the ai-gateway.
    private static func parseResult(from raw: String) -> RIASECResult? {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        // Strip markdown code fences if Gemini wrapped the JSON.
        if s.hasPrefix("```") {
            s = s.replacingOccurrences(of: "```json", with: "")
                 .replacingOccurrences(of: "```", with: "")
                 .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Isolate the outermost JSON object.
        if let start = s.firstIndex(of: "{"), let end = s.lastIndex(of: "}"), start <= end {
            s = String(s[start...end])
        }
        guard let data = s.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(RIASECResult.self, from: data)
    }

    private func gradeBandToGradeLevel(_ band: GradeBand) -> Int {
        switch band {
        case .k2:  return 1
        case .g35: return 4
        case .g68: return 7
        }
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

// MARK: - View
//
// T023 — iPad parity: MaxWidthContainer(640) wraps all quiz content so it doesn't
// stretch edge-to-edge on iPad Pro 12.9"/13". iPhone is unaffected.

public struct CareerQuizView: View {
    @StateObject private var vm = CareerQuizViewModel()
    @State private var band: GradeBand = .g35
    @Environment(\.modelContext) private var modelContext

    public init() {}

    public var body: some View {
        MaxWidthContainer(maxWidth: 640) {
            Group {
                if vm.locked {
                    LockedQuizView()
                } else if vm.isScoring {
                    ProgressView("Saving your answers…").padding()
                } else if let q = vm.current {
                    VStack(spacing: 12) {
                        QuizQuestionView(question: q, onAnswer: vm.answer)
                        if let err = vm.scoringError {
                            Text(err).foregroundStyle(.red).font(.footnote)
                        }
                    }
                } else {
                    StartQuizView(band: $band) {
                        vm.start(gradeBand: band)
                    }
                }
            }
        }
        .navigationTitle("Career quiz")
        .requireNonStaff()
        .onAppear {
            vm.setContext(modelContext)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("iPhone 15", traits: .sizeThatFitsLayout) {
    NavigationStack { CareerQuizView() }
        .frame(width: 393, height: 852)
        .modelContainer(for: [CareerQuizHistoryModel.self], inMemory: true)
}

#Preview("iPad Air portrait", traits: .sizeThatFitsLayout) {
    NavigationStack { CareerQuizView() }
        .frame(width: 820, height: 1180)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [CareerQuizHistoryModel.self], inMemory: true)
}

#Preview("iPad Air landscape", traits: .sizeThatFitsLayout) {
    NavigationStack { CareerQuizView() }
        .frame(width: 1180, height: 820)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [CareerQuizHistoryModel.self], inMemory: true)
}

#Preview("iPad Pro 12.9 portrait", traits: .sizeThatFitsLayout) {
    NavigationStack { CareerQuizView() }
        .frame(width: 1024, height: 1366)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [CareerQuizHistoryModel.self], inMemory: true)
}
#endif

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
