import SwiftUI

// §9 — class suggester. AI-backed research on career pathway requirements +
// college admission expectations + rigor vs. capacity. Every suggestion
// carries "why this fits" and a citable source.
//
// Bug-fix (S2-2): wired to AIGatewayClient. Shows an empty-state with a
// retry button when the call fails or returns nothing, instead of silently
// finishing the spinner with no data.

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

private struct ClassSuggesterInput: Encodable {
    let academic_year: String
}

private struct ClassSuggesterOutput: Decodable {
    let suggestions: [SuggestedClass]
}

public struct ClassSuggesterView: View {
    @State private var suggestions: [SuggestedClass] = []
    @State private var loading = true
    @State private var error: String?

    public init() {}

    public var body: some View {
        List {
            if loading {
                Section { ProgressView("Consulting Gemini (via ai-gateway)…") }
            }
            if let error {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error).foregroundStyle(.red)
                        Button("Try again") { Task { await load() } }
                    }
                }
            } else if !loading && suggestions.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No suggestions yet",
                        systemImage: "graduationcap",
                        description: Text("We need your career quiz + at least one grade to suggest classes.")
                    )
                    Button("Try again") { Task { await load() } }
                }
            }
            ForEach(suggestions) { s in
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text(s.code).font(.caption.monospaced()); Spacer(); Text(s.rigorLabel.uppercased()).font(.caption2).foregroundStyle(.secondary) }
                    Text(s.title).font(.headline)
                    Text(s.fitReason).font(.body).foregroundStyle(.secondary)
                    if let url = s.sourceURL {
                        Link("Source", destination: url).font(.footnote)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Next year's classes")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        loading = true
        error = nil
        defer { loading = false }

        guard let session = await SupabaseAuthService.shared.currentSession else {
            error = "You need to sign in again."
            return
        }

        let year = nextAcademicYearLabel()
        do {
            let response = try await AIGatewayClient.shared.call(
                feature: .classSuggester,
                input: ClassSuggesterInput(academic_year: year),
                accessToken: session.accessToken
            )
            // The gateway returns a JSON object in `output`. Try to decode it.
            let data = Data(response.output.utf8)
            let parsed = (try? JSONDecoder().decode(ClassSuggesterOutput.self, from: data))
                ?? ClassSuggesterOutput(suggestions: [])
            suggestions = parsed.suggestions
        } catch {
            self.error = "We couldn't reach the suggester. Try again in a sec."
        }
    }

    private func nextAcademicYearLabel() -> String {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        let start = month >= 7 ? year : year - 1
        return "\(start + 1)-\(start + 2)"
    }
}
