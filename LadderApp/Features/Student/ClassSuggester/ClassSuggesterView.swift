import SwiftUI
import SwiftData

// §9 — class suggester. AI-backed research on career pathway requirements +
// college admission expectations + rigor vs. capacity. Every suggestion
// carries "why this fits" and a citable source.
//
// S2 (T018): wired to AIGatewayClient.shared.call(feature: .classSuggester).
// Input includes student_id (D-003), grade, and career_path from the student's
// profile. Shows a loading state during the request, renders suggestions on
// success, and shows a retry empty-state on failure or empty response.
// No sleep calls.

public struct SuggestedClass: Identifiable, Sendable, Decodable {
    public let id: UUID
    public let title: String
    public let code: String
    public let fitReason: String
    public let sourceURL: URL?
    public let rigorLabel: String   // "standard", "honors", "ap"

    enum CodingKeys: String, CodingKey {
        case id, title, code
        case fitReason = "fit_reason"
        case sourceURL = "source_url"
        case rigorLabel = "rigor"
    }
}

// MARK: - Codable I/O types

private struct ClassSuggesterInput: Encodable {
    let student_id: String
    let academic_year: String
    let grade: Int
    let career_path: String?
}

private struct ClassSuggesterOutput: Decodable {
    let suggestions: [SuggestedClass]
}

// MARK: - View

public struct ClassSuggesterView: View {
    @Query private var profiles: [StudentProfileModel]

    @State private var suggestions: [SuggestedClass] = []
    @State private var loading = false
    @State private var error: String?
    /// Resolved from the live Supabase JWT on appear (D-003).
    @State private var resolvedStudentId: String?

    public init() {}

    private var profile: StudentProfileModel? { profiles.first }

    public var body: some View {
        // T023 — iPad parity: MaxWidthContainer(640) prevents the suggestion list
        // from spanning the full width of an iPad Pro 12.9"/13" screen.
        MaxWidthContainer(maxWidth: 640) {
            List {
                if loading {
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Consulting Gemini (via ai-gateway)…")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }

                if let errorMessage = error {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(errorMessage).foregroundStyle(.red)
                            Button("Try again") { Task { await load() } }
                        }
                    }
                } else if !loading && suggestions.isEmpty && error == nil {
                    Section {
                        ContentUnavailableView(
                            "No suggestions yet",
                            systemImage: "graduationcap",
                            description: Text("We need your career quiz + at least one grade to suggest classes.")
                        )
                        Button("Try again") { Task { await load() } }
                    }
                }

                if !suggestions.isEmpty {
                    Section("Recommended for next year") {
                        ForEach(suggestions) { s in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(s.code).font(.caption.monospaced())
                                    Spacer()
                                    Text(s.rigorLabel.uppercased())
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Text(s.title).font(.headline)
                                Text(s.fitReason).font(.body).foregroundStyle(.secondary)
                                if let url = s.sourceURL {
                                    Link("Source", destination: url).font(.footnote)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Next year's classes")
            .task {
                // Resolve studentId from JWT once (D-003).
                if resolvedStudentId == nil {
                    let session = await SupabaseAuthService.shared.currentSession
                    resolvedStudentId = session?.user.id.uuidString
                }
                await load()
            }
            .refreshable { await load() }
        }
    }

    // MARK: - Previews (placed inside the public struct for access to internal types)
    // Actual #Preview macros must be file-scope; see below.

    // MARK: - AI call

    private func load() async {
        guard !loading else { return }
        loading = true
        error = nil
        defer { loading = false }

        // D-003: studentId must come from the live JWT, never inferred from profile.
        guard let studentId = resolvedStudentId else {
            // Attempt a late resolution before giving up.
            let session = await SupabaseAuthService.shared.currentSession
            resolvedStudentId = session?.user.id.uuidString
            guard resolvedStudentId != nil else {
                error = "You need to sign in again."
                return
            }
            await load()
            return
        }

        guard let session = await SupabaseAuthService.shared.currentSession else {
            error = "You need to sign in again."
            return
        }

        let year = nextAcademicYearLabel()
        let input = ClassSuggesterInput(
            student_id: studentId,
            academic_year: year,
            grade: profile?.grade ?? 9,
            career_path: profile?.careerPath
        )

        do {
            let response = try await AIGatewayClient.shared.call(
                feature: .classSuggester,
                input: input,
                accessToken: session.accessToken
            )
            let data = Data(response.output.utf8)
            let parsed = (try? JSONDecoder().decode(ClassSuggesterOutput.self, from: data))
                ?? ClassSuggesterOutput(suggestions: [])
            suggestions = parsed.suggestions
        } catch AIGatewayError.budgetExhausted {
            error = "Your school's AI budget for this month has been reached. Please try again next month."
        } catch AIGatewayError.rateLimited {
            error = "You're making requests too quickly. Wait a moment and try again."
        } catch AIGatewayError.unauthenticated {
            error = "Your session expired. Please sign in again."
        } catch {
            self.error = "We couldn't reach the suggester. Try again in a sec."
        }
    }

    // MARK: - Helpers

    private func nextAcademicYearLabel() -> String {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        let start = month >= 7 ? year : year - 1
        return "\(start + 1)-\(start + 2)"
    }
}

// MARK: - Previews

#if DEBUG
#Preview("iPhone 15", traits: .sizeThatFitsLayout) {
    NavigationStack { ClassSuggesterView() }
        .frame(width: 393, height: 852)
        .modelContainer(for: [StudentProfileModel.self], inMemory: true)
}

#Preview("iPad Air portrait", traits: .sizeThatFitsLayout) {
    NavigationStack { ClassSuggesterView() }
        .frame(width: 820, height: 1180)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [StudentProfileModel.self], inMemory: true)
}

#Preview("iPad Air landscape", traits: .sizeThatFitsLayout) {
    NavigationStack { ClassSuggesterView() }
        .frame(width: 1180, height: 820)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [StudentProfileModel.self], inMemory: true)
}

#Preview("iPad Pro 12.9 portrait", traits: .sizeThatFitsLayout) {
    NavigationStack { ClassSuggesterView() }
        .frame(width: 1024, height: 1366)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [StudentProfileModel.self], inMemory: true)
}
#endif
