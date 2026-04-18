import SwiftUI

// §14.3 — schools grid with per-school cards. NEVER shows student data.

public struct SchoolCard: Identifiable, Sendable {
    public let id: UUID
    public let displayName: String
    public let enrolledStudentCount: Int
    public let billingBalanceUSD: Decimal
    public let aiTokensUsedMonth: Int
    public let aiCostUSD: Decimal
    public let successRatePercent: Double?
}

public struct SchoolsGridView: View {
    @State private var cards: [SchoolCard] = []
    @State private var showingAddSheet = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 16)], spacing: 16) {
                    ForEach(cards) { card in
                        NavigationLink { SchoolDetailView(school: card) } label: {
                            SchoolCardView(card: card)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Schools")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add a new school", systemImage: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) { AddSchoolFormView() }
            .task { await load() }
        }
    }

    private func load() async {
        // TODO: GET /rest/v1/rpc/founder_schools_list (returns aggregates only)
        cards = []
    }
}

public struct SchoolCardView: View {
    public let card: SchoolCard

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.displayName).font(.headline)
            Divider()
            Metric(label: "Students", value: "\(card.enrolledStudentCount)")
            Metric(label: "Balance",  value: formattedUSD(card.billingBalanceUSD))
            Metric(label: "AI tokens (30d)", value: "\(card.aiTokensUsedMonth)")
            Metric(label: "AI cost", value: formattedUSD(card.aiCostUSD))
            if let rate = card.successRatePercent {
                Metric(label: "Success rate", value: String(format: "%.1f%%", rate))
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formattedUSD(_ d: Decimal) -> String {
        let f = NumberFormatter(); f.numberStyle = .currency; f.currencyCode = "USD"
        return f.string(from: d as NSDecimalNumber) ?? "—"
    }

    private struct Metric: View {
        let label: String; let value: String
        var body: some View {
            HStack { Text(label).foregroundStyle(.secondary); Spacer(); Text(value).font(.body.monospacedDigit()) }
        }
    }
}
