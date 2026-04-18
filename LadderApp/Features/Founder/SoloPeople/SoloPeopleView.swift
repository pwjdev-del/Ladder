import SwiftUI

// §14.4 — B2C families list. One row per FAMILY (not per kid). No names, no
// grades, no quiz answers, no schedules. Family structure + billing only.

public struct FamilyRow: Identifiable, Sendable {
    public let id: UUID
    public let familyHash: String              // e.g. "A7C3" — display-friendly family anonymizer
    public let parentAccountCount: Int
    public let linkedStudentCount: Int
    public let billingStatus: String           // "paid", "trial", "past_due"
}

public struct SoloPeopleView: View {
    @State private var families: [FamilyRow] = []

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                ForEach(families) { row in
                    HStack {
                        Text("Family #\(row.familyHash)").font(.body.monospaced())
                        Spacer()
                        Text("\(row.parentAccountCount)p · \(row.linkedStudentCount)k").foregroundStyle(.secondary)
                        Text(row.billingStatus.capitalized).foregroundStyle(color(for: row.billingStatus))
                    }
                }
            }
            .navigationTitle("Solo people")
            .overlay {
                if families.isEmpty {
                    ContentUnavailableView("No B2C families yet",
                                           systemImage: "person.3",
                                           description: Text("Family names and contents are not shown. Only structure and billing per §14.4."))
                }
            }
            .task { await load() }
        }
    }

    private func load() async {
        // TODO: GET /rest/v1/rpc/founder_families_list (aggregates + hash only)
        families = []
    }

    private func color(for status: String) -> Color {
        switch status {
        case "paid": return .green
        case "trial": return .blue
        case "past_due": return .red
        default: return .secondary
        }
    }
}
