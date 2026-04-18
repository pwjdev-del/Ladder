import SwiftUI

// §9 — class suggester. AI-backed research on career pathway requirements +
// college admission expectations + rigor vs. capacity. Every suggestion
// carries "why this fits" and a citable source.

public struct SuggestedClass: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let code: String
    public let fitReason: String
    public let sourceURL: URL?
    public let rigorLabel: String   // "standard", "honors", "ap"
}

public struct ClassSuggesterView: View {
    @State private var suggestions: [SuggestedClass] = []
    @State private var loading = true

    public init() {}

    public var body: some View {
        List {
            if loading {
                Section { ProgressView("Consulting Gemini (via ai-gateway)…") }
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
    }

    private func load() async {
        loading = true
        defer { loading = false }
        // TODO: call AIGatewayClient.shared.call(feature: .classSuggester, input: ...)
        try? await Task.sleep(nanoseconds: 500_000_000)
        suggestions = []
    }
}
