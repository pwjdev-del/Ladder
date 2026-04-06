import SwiftUI

// MARK: - Scholarship Search View

struct ScholarshipSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: ScholarshipFilter = .all
    @State private var savedIds: Set<UUID> = []

    enum ScholarshipFilter: String, CaseIterable {
        case all = "All"
        case merit = "Merit"
        case need = "Need-Based"
        case local = "Local"
        case stem = "STEM"
    }

    private var filteredScholarships: [ScholarshipItem] {
        var result = ScholarshipItem.samples
        if selectedFilter != .all {
            switch selectedFilter {
            case .merit: result = result.filter(\.isMerit)
            case .need: result = result.filter(\.isNeedBased)
            case .local: result = result.filter(\.isLocal)
            case .stem: result = result.filter(\.isStem)
            case .all: break
            }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    // Search
                    LadderSearchBar(placeholder: "Search scholarships...", text: $searchText)
                        .padding(.horizontal, LadderSpacing.md)

                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: LadderSpacing.sm) {
                            ForEach(ScholarshipFilter.allCases, id: \.self) { filter in
                                LadderFilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) { selectedFilter = filter }
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)
                    }

                    // Results
                    ForEach(filteredScholarships) { scholarship in
                        scholarshipCard(scholarship)
                    }
                }
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Scholarships")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private func scholarshipCard(_ scholarship: ScholarshipItem) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(scholarship.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(scholarship.provider)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                Button {
                    if savedIds.contains(scholarship.id) {
                        savedIds.remove(scholarship.id)
                    } else {
                        savedIds.insert(scholarship.id)
                    }
                } label: {
                    Image(systemName: savedIds.contains(scholarship.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(LadderColors.primary)
                }
            }

            HStack(spacing: LadderSpacing.md) {
                Label("$\(scholarship.amount)", systemImage: "dollarsign.circle.fill")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.accentLime)

                if let deadline = scholarship.deadline {
                    Label(deadline, systemImage: "calendar")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                if let match = scholarship.matchPercent {
                    Text("\(match)% match")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(Capsule())
                }
            }

            Text(scholarship.eligibility)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .lineLimit(2)

            HStack(spacing: LadderSpacing.sm) {
                ForEach(scholarship.tags, id: \.self) { tag in
                    LadderTagChip(tag)
                }
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .padding(.horizontal, LadderSpacing.md)
    }
}

// MARK: - Scholarship Item

struct ScholarshipItem: Identifiable {
    let id = UUID()
    let name: String
    let provider: String
    let amount: Int
    let deadline: String?
    let eligibility: String
    let matchPercent: Int?
    let tags: [String]
    let isMerit: Bool
    let isNeedBased: Bool
    let isLocal: Bool
    let isStem: Bool

    static var samples: [ScholarshipItem] {
        [
            ScholarshipItem(name: "Bright Futures Academic Scholars", provider: "Florida DoE", amount: 12000, deadline: "Jun 30, 2027", eligibility: "Florida residents, 3.5+ GPA, 1290+ SAT or 29+ ACT", matchPercent: 85, tags: ["Merit", "Florida"], isMerit: true, isNeedBased: false, isLocal: true, isStem: false),
            ScholarshipItem(name: "National Merit Scholarship", provider: "NMSC", amount: 2500, deadline: "Oct 15, 2026", eligibility: "High PSAT scores, semi-finalist or finalist status", matchPercent: 40, tags: ["Merit", "National"], isMerit: true, isNeedBased: false, isLocal: false, isStem: false),
            ScholarshipItem(name: "QuestBridge National Match", provider: "QuestBridge", amount: 50000, deadline: "Sep 27, 2026", eligibility: "Low-income, high-achieving students. Full scholarship to partner schools.", matchPercent: 70, tags: ["Need-Based", "National"], isMerit: false, isNeedBased: true, isLocal: false, isStem: false),
            ScholarshipItem(name: "STEM Future Leaders Award", provider: "Society of Women Engineers", amount: 5000, deadline: "Mar 1, 2027", eligibility: "Students pursuing STEM majors. Must demonstrate leadership.", matchPercent: 60, tags: ["STEM", "National"], isMerit: true, isNeedBased: false, isLocal: false, isStem: true),
            ScholarshipItem(name: "First Generation College Student Grant", provider: "Sallie Mae", amount: 3000, deadline: "Dec 15, 2026", eligibility: "First-generation college students with financial need.", matchPercent: 90, tags: ["Need-Based", "First-Gen"], isMerit: false, isNeedBased: true, isLocal: false, isStem: false),
            ScholarshipItem(name: "Community Foundation of Tampa Bay", provider: "CF Tampa Bay", amount: 2000, deadline: "Apr 1, 2027", eligibility: "Hillsborough County residents with community service involvement.", matchPercent: 75, tags: ["Local", "Community"], isMerit: false, isNeedBased: true, isLocal: true, isStem: false),
        ]
    }
}

#Preview {
    NavigationStack {
        ScholarshipSearchView()
    }
}
