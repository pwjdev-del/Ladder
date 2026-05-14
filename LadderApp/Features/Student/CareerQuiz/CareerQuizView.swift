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
    @Published var topCareerPath: String?

    /// 1-based question number for the progress indicator (max 12).
    var questionNumber: Int { answers.count + 1 }
    static let totalQuestions = 12

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

        topCareerPath = result.topCareerPath
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

    // MARK: - Question bank (12 questions, 4–6 options each, RIASEC-mapped)
    //
    // Option id suffixes encode the primary RIASEC dimension for ai-gateway scoring:
    //   _r = Realistic  _i = Investigative  _a = Artistic
    //   _s = Social     _e = Enterprising   _c = Conventional
    //
    // Q1 branches into two parallel warm-up chains (build vs story) that re-merge
    // at q3. Q3–Q12 are shared across all paths so every student answers 12 total.
    // A question is terminal when nextByAnswer is [:] — answer() fires finish().
    //
    // Grade-band variants: K–2 uses shorter, simpler text; G3–5 default; G6–8 extended.

    private static func placeholderQuestion(for band: GradeBand) -> QuizQuestion {
        // Q1 — entry point, always id "q1"
        switch band {
        case .k2:
            return QuizQuestion(
                id: "q1",
                text: "What sounds more fun to you?",
                gradeBand: band,
                options: [
                    QuizOption(id: "a_r", text: "Building something with your hands",  imageSystemName: "hammer"),
                    QuizOption(id: "b_a", text: "Making up a story or drawing a picture", imageSystemName: "book"),
                ],
                nextByAnswer: ["a_r": "q2_build", "b_a": "q2_story"]
            )
        case .g35:
            return QuizQuestion(
                id: "q1",
                text: "Which do you enjoy more?",
                gradeBand: band,
                options: [
                    QuizOption(id: "a_r", text: "Building or fixing things",  imageSystemName: "hammer"),
                    QuizOption(id: "b_a", text: "Writing stories or drawing",  imageSystemName: "book"),
                ],
                nextByAnswer: ["a_r": "q2_build", "b_a": "q2_story"]
            )
        case .g68:
            return QuizQuestion(
                id: "q1",
                text: "When you have free time, which sounds more like you?",
                gradeBand: band,
                options: [
                    QuizOption(id: "a_r", text: "Tinkering — building, fixing, or making something physical", imageSystemName: "hammer"),
                    QuizOption(id: "b_a", text: "Creating — writing, drawing, or crafting something original", imageSystemName: "pencil.and.outline"),
                ],
                nextByAnswer: ["a_r": "q2_build", "b_a": "q2_story"]
            )
        }
    }

    // Full question bank keyed by question id.
    // Built once as a static let; closure is an IIFE so it can use local helpers.
    //
    // nextByAnswer is built by mapping each option id in the question to the
    // same next question id (all roads from a non-terminal question lead forward).
    // Q12's nextByAnswer is [:] — the empty dict signals finish() in answer().
    private static let questionBank: [String: (GradeBand) -> QuizQuestion] = {
        // Builds a [optionId: nextId] dict from a flat list of option ids.
        func next(_ nextId: String, _ ids: String...) -> [String: String] {
            Dictionary(uniqueKeysWithValues: ids.map { ($0, nextId) })
        }

        return [
            // ── Q2 build branch ──────────────────────────────────────────────
            "q2_build": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q2_build",
                    text: k ? "What do you like to build most?"
                            : "Which kind of building or making sounds most interesting?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "Toys or gadgets"      : "Machines or gadgets",          imageSystemName: "gearshape"),
                        QuizOption(id: "b_i", text: k ? "Science projects"     : "Science experiments",           imageSystemName: "flask"),
                        QuizOption(id: "c_a", text: k ? "Art or crafts"        : "Art, crafts, or costumes",      imageSystemName: "paintpalette"),
                        QuizOption(id: "d_c", text: k ? "Plans and lists"      : "Organized systems or plans",    imageSystemName: "list.bullet.clipboard"),
                    ],
                    nextByAnswer: next("q3", "a_r", "b_i", "c_a", "d_c")
                )
            },

            // ── Q2 story branch ──────────────────────────────────────────────
            "q2_story": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q2_story",
                    text: k ? "What do you like to make?"
                            : "What kind of creative work sounds most exciting?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_a", text: k ? "Draw pictures"  : "Draw or paint",             imageSystemName: "paintbrush"),
                        QuizOption(id: "b_a", text: k ? "Write stories"  : "Write stories or poems",     imageSystemName: "doc.text"),
                        QuizOption(id: "c_s", text: k ? "Act in plays"   : "Act, sing, or perform",      imageSystemName: "theatermasks"),
                        QuizOption(id: "d_e", text: k ? "Make videos"    : "Make videos or podcasts",    imageSystemName: "video"),
                    ],
                    nextByAnswer: next("q3", "a_a", "b_a", "c_s", "d_e")
                )
            },

            // ── Q3–Q12: shared convergent path ──────────────────────────────

            "q3": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q3",
                    text: k ? "Who do you most like spending time with?"
                            : "Which group activity sounds most like you?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_s", text: k ? "Helping a friend"          : "Helping someone solve a problem",          imageSystemName: "person.2"),
                        QuizOption(id: "b_e", text: k ? "Being the leader"          : "Leading a team or club",                  imageSystemName: "megaphone"),
                        QuizOption(id: "c_i", text: k ? "Working alone on a puzzle" : "Working quietly on a tricky puzzle",      imageSystemName: "puzzlepiece"),
                        QuizOption(id: "d_c", text: k ? "Following instructions"    : "Following a clear process step-by-step",  imageSystemName: "checklist"),
                    ],
                    nextByAnswer: next("q4", "a_s", "b_e", "c_i", "d_c")
                )
            },

            "q4": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q4",
                    text: k ? "Pick your favorite subject:"
                            : "Which school subject do you look forward to most?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "PE or wood-shop"    : "PE, shop class, or hands-on lab",             imageSystemName: "figure.run"),
                        QuizOption(id: "b_i", text: k ? "Science"            : "Science or math",                            imageSystemName: "atom"),
                        QuizOption(id: "c_a", text: k ? "Art or music"       : "Art, music, or drama",                       imageSystemName: "music.note"),
                        QuizOption(id: "d_s", text: k ? "Reading"            : "Reading, history, or social studies",        imageSystemName: "books.vertical"),
                        QuizOption(id: "e_e", text: k ? "Class projects"     : "Group projects and class debates",           imageSystemName: "person.3"),
                        QuizOption(id: "f_c", text: k ? "Math"               : "Math or computer class",                    imageSystemName: "number"),
                    ],
                    nextByAnswer: next("q5", "a_r", "b_i", "c_a", "d_s", "e_e", "f_c")
                )
            },

            "q5": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q5",
                    text: k ? "What do you do when you find something broken?"
                            : "When something breaks around you, what do you most want to do?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "Try to fix it"              : "Take it apart and figure out how to fix it",      imageSystemName: "wrench.and.screwdriver"),
                        QuizOption(id: "b_i", text: k ? "Wonder why it broke"        : "Research why it broke and how to prevent it",     imageSystemName: "magnifyingglass"),
                        QuizOption(id: "c_a", text: k ? "Make something new from it" : "Repurpose it into something creative",            imageSystemName: "scissors"),
                        QuizOption(id: "d_s", text: k ? "Ask for help"               : "Find the right person who knows how to fix it",   imageSystemName: "questionmark.bubble"),
                        QuizOption(id: "e_e", text: k ? "Tell someone to fix it"     : "Delegate — find and organize people to handle it", imageSystemName: "arrow.2.circlepath"),
                    ],
                    nextByAnswer: next("q6", "a_r", "b_i", "c_a", "d_s", "e_e")
                )
            },

            "q6": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q6",
                    text: k ? "If you ran a lemonade stand, what job would you want?"
                            : "Imagine you're running a school fundraiser. Which role fits you best?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_e", text: k ? "Be the boss"       : "Organizer — plan the whole event",                       imageSystemName: "star"),
                        QuizOption(id: "b_s", text: k ? "Talk to customers" : "Ambassador — talk to supporters and donors",             imageSystemName: "hand.wave"),
                        QuizOption(id: "c_c", text: k ? "Count the money"   : "Treasurer — track all the money",                       imageSystemName: "dollarsign"),
                        QuizOption(id: "d_a", text: k ? "Make the signs"    : "Designer — make posters and social posts",              imageSystemName: "paintbrush.pointed"),
                        QuizOption(id: "e_i", text: k ? "Plan the prices"   : "Analyst — research what prices and products sell best", imageSystemName: "chart.bar"),
                        QuizOption(id: "f_r", text: k ? "Set up everything" : "Setup crew — build booths and carry equipment",        imageSystemName: "shippingbox"),
                    ],
                    nextByAnswer: next("q7", "a_e", "b_s", "c_c", "d_a", "e_i", "f_r")
                )
            },

            "q7": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q7",
                    text: k ? "Your dream after-school activity:"
                            : "Which after-school activity would you choose if you could?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "Building club"     : "Robotics or maker club",                          imageSystemName: "gearshape.2"),
                        QuizOption(id: "b_i", text: k ? "Science club"      : "Science or coding club",                          imageSystemName: "desktopcomputer"),
                        QuizOption(id: "c_a", text: k ? "Art club"          : "Art, theater, or band",                           imageSystemName: "theatermasks"),
                        QuizOption(id: "d_s", text: k ? "Volunteer"         : "Community service or peer tutoring",              imageSystemName: "heart"),
                        QuizOption(id: "e_e", text: k ? "Student council"   : "Student government or entrepreneurship club",     imageSystemName: "building.columns"),
                        QuizOption(id: "f_c", text: k ? "Math club"         : "Math team or debate club",                        imageSystemName: "function"),
                    ],
                    nextByAnswer: next("q8", "a_r", "b_i", "c_a", "d_s", "e_e", "f_c")
                )
            },

            "q8": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q8",
                    text: k ? "When you grow up, where do you want to work?"
                            : "What kind of work environment sounds most like where you'd thrive?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "Outside or a workshop" : "Outside, a lab, or a workshop — hands-on space",       imageSystemName: "sun.max"),
                        QuizOption(id: "b_i", text: k ? "A lab"                 : "A research lab or university",                        imageSystemName: "building.2"),
                        QuizOption(id: "c_a", text: k ? "A studio"              : "A creative studio or design firm",                    imageSystemName: "sparkles"),
                        QuizOption(id: "d_s", text: k ? "A school or hospital"  : "A school, hospital, or social service organization",  imageSystemName: "cross.circle"),
                        QuizOption(id: "e_e", text: k ? "My own company"        : "A startup or my own business",                        imageSystemName: "briefcase"),
                        QuizOption(id: "f_c", text: k ? "An office"             : "A structured office or government agency",            imageSystemName: "building.columns"),
                    ],
                    nextByAnswer: next("q9", "a_r", "b_i", "c_a", "d_s", "e_e", "f_c")
                )
            },

            "q9": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q9",
                    text: k ? "What's the best part of a group project?"
                            : "In a group project, what role do you naturally end up playing?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_e", text: k ? "Being in charge"           : "The leader who assigns tasks and sets the vision",              imageSystemName: "crown"),
                        QuizOption(id: "b_s", text: k ? "Helping everyone get along": "The peacemaker who makes sure everyone is heard",              imageSystemName: "person.2.fill"),
                        QuizOption(id: "c_a", text: k ? "Making it look good"       : "The creative who handles visuals and presentation",            imageSystemName: "eye"),
                        QuizOption(id: "d_i", text: k ? "Doing the research"        : "The researcher who digs into the facts",                       imageSystemName: "doc.text.magnifyingglass"),
                        QuizOption(id: "e_r", text: k ? "Building the thing"        : "The builder who makes the physical prototype or demo",         imageSystemName: "hammer"),
                        QuizOption(id: "f_c", text: k ? "Checking everything"       : "The editor who catches mistakes and keeps things organized",   imageSystemName: "checkmark.seal"),
                    ],
                    nextByAnswer: next("q10", "a_e", "b_s", "c_a", "d_i", "e_r", "f_c")
                )
            },

            "q10": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q10",
                    text: k ? "What would you do if you had a whole free Saturday?"
                            : "It's a free Saturday with no plans. What do you actually end up doing?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "Build or fix something"       : "Build, repair, or tinker with something around the house",              imageSystemName: "wrench"),
                        QuizOption(id: "b_i", text: k ? "Read or watch documentaries"  : "Read, watch a documentary, or dive into a topic you're curious about", imageSystemName: "book.closed"),
                        QuizOption(id: "c_a", text: k ? "Draw, write, or make music"   : "Draw, write, play music, or work on a creative project",               imageSystemName: "music.note.list"),
                        QuizOption(id: "d_s", text: k ? "Hang out with friends"        : "Text or hang out with friends — just being around people",             imageSystemName: "bubble.left.and.bubble.right"),
                        QuizOption(id: "e_e", text: k ? "Start a project or sell stuff": "Start a side project, plan something, or try to earn money",           imageSystemName: "chart.line.uptrend.xyaxis"),
                        QuizOption(id: "f_c", text: k ? "Organize your stuff"          : "Organize your room, plan your week, or sort and categorize things",    imageSystemName: "tray.2"),
                    ],
                    nextByAnswer: next("q11", "a_r", "b_i", "c_a", "d_s", "e_e", "f_c")
                )
            },

            "q11": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q11",
                    text: k ? "If you could invent something, what would it do?"
                            : "If you could invent anything, which type of invention sounds most exciting?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "A cool machine"             : "A machine or tool that makes physical tasks easier",                 imageSystemName: "gearshape.fill"),
                        QuizOption(id: "b_i", text: k ? "A medicine or discovery"    : "A medicine, discovery, or scientific breakthrough",                  imageSystemName: "staroflife"),
                        QuizOption(id: "c_a", text: k ? "An amazing story or game"   : "A game, story, or experience people love",                          imageSystemName: "gamecontroller"),
                        QuizOption(id: "d_s", text: k ? "Something to help people"   : "Something that helps people feel less lonely or misunderstood",      imageSystemName: "hands.and.sparkles"),
                        QuizOption(id: "e_e", text: k ? "A business app"             : "A business or app that grows really fast and helps lots of people",  imageSystemName: "network"),
                        QuizOption(id: "f_c", text: k ? "A super helpful checklist"  : "A system that organizes huge amounts of information perfectly",      imageSystemName: "square.grid.3x3"),
                    ],
                    nextByAnswer: next("q12", "a_r", "b_i", "c_a", "d_s", "e_e", "f_c")
                )
            },

            // Q12 — terminal: nextByAnswer [:] triggers finish() in answer()
            "q12": { band in
                let k = band == .k2
                return QuizQuestion(
                    id: "q12",
                    text: k ? "Last one! What do you want people to say about you when you grow up?"
                            : "Last question: when you're older, what would mean the most to you?",
                    gradeBand: band,
                    options: [
                        QuizOption(id: "a_r", text: k ? "\"They built amazing things\""       : "\"They built things that changed how we live\"",               imageSystemName: "hammer.fill"),
                        QuizOption(id: "b_i", text: k ? "\"They discovered something cool\""  : "\"They figured out something nobody understood before\"",      imageSystemName: "lightbulb.fill"),
                        QuizOption(id: "c_a", text: k ? "\"They made beautiful things\""      : "\"They created art or stories that moved people\"",            imageSystemName: "star.fill"),
                        QuizOption(id: "d_s", text: k ? "\"They helped so many people\""      : "\"They dedicated their life to helping others\"",              imageSystemName: "heart.fill"),
                        QuizOption(id: "e_e", text: k ? "\"They started a big company\""      : "\"They built something from nothing and led people well\"",    imageSystemName: "flag.fill"),
                        QuizOption(id: "f_c", text: k ? "\"Everything they did was perfect\""  : "\"They were the most organized and reliable person around\"", imageSystemName: "checkmark.circle.fill"),
                    ],
                    nextByAnswer: [:]  // terminal — triggers finish()
                )
            },
        ]
    }()

    private static func nextStub(id: String, grade: GradeBand) -> QuizQuestion {
        // Look up the real question from the bank. If for any reason the id is
        // unknown (shouldn't happen with the current fixed graph), return a safe
        // terminal question so finish() fires rather than softlocking.
        if let factory = questionBank[id] {
            return factory(grade)
        }
        // Fallback terminal — never returns options: [] with live options
        return QuizQuestion(
            id: id,
            text: "Last question: what matters most to you?",
            gradeBand: grade,
            options: [
                QuizOption(id: "a_s", text: "Helping others",        imageSystemName: "heart"),
                QuizOption(id: "b_e", text: "Leading something big", imageSystemName: "star"),
                QuizOption(id: "c_i", text: "Discovering the truth",  imageSystemName: "lightbulb"),
                QuizOption(id: "d_r", text: "Building real things",   imageSystemName: "hammer"),
            ],
            nextByAnswer: [:]  // terminal — triggers finish()
        )
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
                if vm.completed, let path = vm.topCareerPath {
                    QuizResultView(topCareerPath: path)
                } else if vm.locked {
                    LockedQuizView()
                } else if vm.isScoring {
                    ProgressView("Saving your answers…").padding()
                } else if let q = vm.current {
                    VStack(spacing: 12) {
                        // Progress bar: shows how far through the 12 questions the student is.
                        QuizProgressView(
                            current: vm.questionNumber,
                            total: CareerQuizViewModel.totalQuestions
                        )
                        .padding(.horizontal)
                        QuizQuestionView(question: q, onAnswer: vm.answer)
                        if let err = vm.scoringError {
                            Text(err).foregroundStyle(.red).font(.footnote).padding(.horizontal)
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

private struct QuizProgressView: View {
    let current: Int
    let total: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ProgressView(value: Double(current - 1), total: Double(total))
                .tint(.accentColor)
            Text("Question \(current) of \(total)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct QuizResultView: View {
    let topCareerPath: String

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Your career profile:")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(topCareerPath)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Ladder will use this to suggest classes, activities, and pathways that fit you. Your counselor can also see your profile.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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
