import SwiftUI

// §3.2 — searchable partnered schools. Now on brand gradient (no white).
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/partner_school_picker/
// adapted to the forest→lime gradient surface.

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
    @FocusState private var searchFocused: Bool

    public init() {}

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

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
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selected) { school in
            SchoolLoginView(school: school)
        }
    }

    private var header: some View {
        ZStack {
            Text("Your school")
                .font(.ladderDisplay(22, relativeTo: .title2))
                .foregroundStyle(LadderBrand.cream100)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(LadderBrand.cream100)
                        .frame(width: 40, height: 40)
                        .background(LadderBrand.cream100.opacity(0.12))
                        .clipShape(Circle())
                }
                Spacer()
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))
            TextField("", text: $query, prompt: Text("Search your school").foregroundColor(LadderBrand.cream100.opacity(0.5)))
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.cream100)
                .tint(LadderBrand.lime500)
                .focused($searchFocused)
                .autocorrectionDisabled()
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(LadderBrand.cream100.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(LadderBrand.cream100.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(searchFocused ? LadderBrand.lime500 : Color.clear, lineWidth: 1.5)
        )
    }

    private var schoolList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
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
                .fill(LadderBrand.cream100.opacity(0.12))
                .frame(width: 96, height: 96)
                .overlay(
                    Image(systemName: "stairs")
                        .font(.system(size: 36))
                        .foregroundStyle(LadderBrand.lime500)
                )
            Text("We can't find that school.")
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.cream100.opacity(0.8))
        }
        .padding(.top, 40)
    }

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
            .background(LadderBrand.lime500)
            .clipShape(Capsule())
            .shadow(color: LadderBrand.lime500.opacity(0.4), radius: 12, y: 4)
        }
        .padding(.bottom, 24)
    }

    private var filtered: [PartnerSchool] {
        guard !query.isEmpty else { return schools }
        return schools.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    }
}

private struct SchoolRow: View {
    let school: PartnerSchool

    var body: some View {
        HStack(spacing: 16) {
            tintChip
            VStack(alignment: .leading, spacing: 4) {
                Text(school.displayName)
                    .font(.ladderDisplay(18, relativeTo: .title3))
                    .foregroundStyle(LadderBrand.cream100)
                    .multilineTextAlignment(.leading)
                Text(school.slug.uppercased())
                    .font(.ladderCaps(11))
                    .tracking(1.1)
                    .foregroundStyle(LadderBrand.cream100.opacity(0.6))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(LadderBrand.cream100.opacity(0.5))
        }
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var tintChip: some View {
        let color = Color(hex: school.primaryColorHex) ?? LadderBrand.lime500
        return RoundedRectangle(cornerRadius: 12)
            .fill(color.opacity(0.25))
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(color)
            )
    }
}

public extension PartnerSchool {
    static let pilotDirectory: [PartnerSchool] = [
        PartnerSchool(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            slug: "lwrpa",
            displayName: "Lakewood Ranch Preparatory Academy",
            primaryColorHex: "#A8D234",
            logoURL: nil
        ),
    ]
}
