import SwiftUI

// §3.2 — searchable list of partnered schools. On selection, theme swaps,
// then push to SchoolLoginView.

public struct PartnerSchool: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let slug: String
    public let displayName: String
    public let primaryColorHex: String?
    public let logoURL: URL?
}

public struct SchoolPickerView: View {
    @State private var query: String = ""
    @State private var selected: PartnerSchool?
    @State private var schools: [PartnerSchool] = PartnerSchool.pilotDirectory

    public init() {}

    public var body: some View {
        List {
            ForEach(filtered) { school in
                Button {
                    selected = school
                } label: {
                    HStack {
                        Text(school.displayName)
                        Spacer()
                        Text(school.slug).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Search your school")
        .navigationTitle("Your school")
        .navigationDestination(item: $selected) { school in
            SchoolLoginView(school: school)
        }
    }

    private var filtered: [PartnerSchool] {
        guard !query.isEmpty else { return schools }
        return schools.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    }
}

public extension PartnerSchool {
    /// Seeded list for the pilot. Production-loads from `GET /rest/v1/tenants?type=eq.school`.
    static let pilotDirectory: [PartnerSchool] = [
        PartnerSchool(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            slug: "lwrpa",
            displayName: "Lakewood Ranch Preparatory Academy",
            primaryColorHex: "#0A4B8F",
            logoURL: nil
        ),
    ]
}
