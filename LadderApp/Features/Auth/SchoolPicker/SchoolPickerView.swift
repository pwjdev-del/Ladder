import SwiftUI

// §3.2 — searchable list of partnered schools. Theme swaps on row tap.
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/partner_school_picker/

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
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.paper.ignoresSafeArea()

            VStack(spacing: 24) {
                header
                searchBar
                if filtered.isEmpty {
                    emptyState
                } else {
                    schoolList
                }
                Spacer()
                partnerCTA
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selected) { school in
            SchoolLoginView(school: school)
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Your school")
                .font(.ladderDisplay(20, relativeTo: .title3))
                .foregroundStyle(LadderBrand.ink900)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(LadderBrand.ink900)
                }
                Spacer()
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LadderBrand.ink600)
            TextField("Search your school", text: $query)
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.ink900)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(LadderBrand.stone200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - List

    private var schoolList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(filtered) { school in
                    Button { selected = school } label: {
                        SchoolRow(school: school)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(LadderBrand.forest700.opacity(0.1))
                .frame(width: 88, height: 88)
                .overlay(
                    Image(systemName: "stairs")
                        .font(.system(size: 34))
                        .foregroundStyle(LadderBrand.forest700)
                )
            Text("We can't find that school.")
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.ink600)
        }
        .padding(.top, 40)
    }

    // MARK: - Partner CTA

    private var partnerCTA: some View {
        NavigationLink {
            SchoolPartnerInquiryView()
        } label: {
            HStack {
                Text("Don't see your school? Partner as a school")
                    .font(.ladderLabel(14))
                    .foregroundStyle(LadderBrand.ink900)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LadderBrand.ink900)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(LadderBrand.lime500.opacity(0.18))
            .clipShape(Capsule())
        }
        .padding(.bottom, 24)
    }

    private var filtered: [PartnerSchool] {
        guard !query.isEmpty else { return schools }
        return schools.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - Row

private struct SchoolRow: View {
    let school: PartnerSchool

    var body: some View {
        HStack(spacing: 16) {
            tintChip
            VStack(alignment: .leading, spacing: 4) {
                Text(school.displayName)
                    .font(.ladderDisplay(18, relativeTo: .title3))
                    .foregroundStyle(LadderBrand.ink900)
                Text(school.slug.uppercased())
                    .font(.ladderCaps(11))
                    .tracking(1.1)
                    .foregroundStyle(LadderBrand.ink600)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(LadderBrand.ink400)
        }
        .padding(.vertical, 6)
    }

    private var tintChip: some View {
        let color = Color(hex: school.primaryColorHex) ?? LadderBrand.forest700
        return RoundedRectangle(cornerRadius: 12)
            .fill(color.opacity(0.15))
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(color)
            )
    }
}

// MARK: - Directory (pilot seed; production loads from /rest/v1/tenants?type=eq.school)

public extension PartnerSchool {
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
