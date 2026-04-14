import SwiftUI

// MARK: - Scholarship Search View

struct ScholarshipSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var searchText = ""
    @State private var selectedFilter: ScholarshipFilter = .all
    @State private var savedIds: Set<UUID> = []

    // iPad-only additional filters
    @State private var minAmount: Double = 0
    @State private var selectedDeadline: DeadlineFilter = .any
    @State private var eligibilityOptions: Set<String> = []

    enum ScholarshipFilter: String, CaseIterable {
        case all = "All"
        case merit = "Merit"
        case need = "Need-Based"
        case local = "Local"
        case stem = "STEM"
    }

    enum DeadlineFilter: String, CaseIterable, Identifiable {
        case any = "Any time"
        case soon = "Next 30 days"
        case quarter = "Next 90 days"
        case year = "This year"
        var id: String { rawValue }
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
        if minAmount > 0 {
            result = result.filter { Double($0.amount) >= minAmount }
        }
        return result
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
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
                            .padding(.horizontal, LadderSpacing.md)
                    }
                }
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(alignment: .top, spacing: LadderSpacing.xl) {
                // Filters panel
                iPadFiltersPanel
                    .frame(width: 320)

                // Grid of results
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    LadderSearchBar(placeholder: "Search scholarships...", text: $searchText)

                    HStack {
                        Text("\(filteredScholarships.count) scholarships")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                    }

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 320, maximum: 420), spacing: LadderSpacing.md)
                            ],
                            spacing: LadderSpacing.md
                        ) {
                            ForEach(filteredScholarships) { scholarship in
                                scholarshipCard(scholarship)
                            }
                        }
                        .padding(.bottom, LadderSpacing.xxl)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, LadderSpacing.xxl)
            .padding(.vertical, LadderSpacing.xl)
        }
    }

    private var iPadFiltersPanel: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                HStack {
                    Text("FILTERS")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                    Spacer()
                    Button("Reset") {
                        selectedFilter = .all
                        minAmount = 0
                        selectedDeadline = .any
                        eligibilityOptions = []
                    }
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.primary)
                }

                filterGroup("TYPE") {
                    VStack(spacing: LadderSpacing.sm) {
                        ForEach(ScholarshipFilter.allCases, id: \.self) { filter in
                            LadderFilterChip(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) { selectedFilter = filter }
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                filterGroup("MINIMUM AMOUNT") {
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text("$\(Int(minAmount))+")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.primary)
                        Slider(value: $minAmount, in: 0...50000, step: 500)
                            .tint(LadderColors.primary)
                        HStack {
                            Text("$0").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                            Spacer()
                            Text("$50K+").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                }

                filterGroup("DEADLINE") {
                    VStack(spacing: LadderSpacing.xs) {
                        ForEach(DeadlineFilter.allCases) { d in
                            Button {
                                selectedDeadline = d
                            } label: {
                                HStack {
                                    Image(systemName: selectedDeadline == d ? "largecircle.fill.circle" : "circle")
                                        .foregroundStyle(selectedDeadline == d ? LadderColors.primary : LadderColors.outlineVariant)
                                    Text(d.rawValue)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                }
                                .padding(.vertical, LadderSpacing.xs)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                filterGroup("ELIGIBILITY") {
                    VStack(spacing: LadderSpacing.xs) {
                        ForEach(["First-Gen", "Florida Resident", "Women in STEM", "Low Income", "High GPA"], id: \.self) { opt in
                            Button {
                                if eligibilityOptions.contains(opt) {
                                    eligibilityOptions.remove(opt)
                                } else {
                                    eligibilityOptions.insert(opt)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: eligibilityOptions.contains(opt) ? "checkmark.square.fill" : "square")
                                        .foregroundStyle(eligibilityOptions.contains(opt) ? LadderColors.primary : LadderColors.outlineVariant)
                                    Text(opt)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                }
                                .padding(.vertical, LadderSpacing.xs)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer(minLength: LadderSpacing.xxl)
            }
            .padding(LadderSpacing.lg)
        }
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
    }

    private func filterGroup(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            content()
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

            if let urlString = scholarship.applicationURL, let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack(spacing: LadderSpacing.xs) {
                        Text("Apply")
                            .font(LadderTypography.labelMedium)
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(LadderColors.accentLime)
                }
            }
        }
        .padding(LadderSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
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
    var applicationURL: String?

    static var samples: [ScholarshipItem] {
        [
            ScholarshipItem(name: "Bright Futures Academic Scholars", provider: "Florida DoE", amount: 12000, deadline: "Jun 30, 2027", eligibility: "Florida residents, 3.5+ GPA, 1290+ SAT or 29+ ACT", matchPercent: 85, tags: ["Merit", "Florida"], isMerit: true, isNeedBased: false, isLocal: true, isStem: false, applicationURL: "https://www.fastweb.com/scholarship/12345"),
            ScholarshipItem(name: "National Merit Scholarship", provider: "NMSC", amount: 2500, deadline: "Oct 15, 2026", eligibility: "High PSAT scores, semi-finalist or finalist status", matchPercent: 40, tags: ["Merit", "National"], isMerit: true, isNeedBased: false, isLocal: false, isStem: false, applicationURL: "https://www.fastweb.com/scholarship/22222"),
            ScholarshipItem(name: "QuestBridge National Match", provider: "QuestBridge", amount: 50000, deadline: "Sep 27, 2026", eligibility: "Low-income, high-achieving students. Full scholarship to partner schools.", matchPercent: 70, tags: ["Need-Based", "National"], isMerit: false, isNeedBased: true, isLocal: false, isStem: false, applicationURL: "https://www.fastweb.com/scholarship/33333"),
            ScholarshipItem(name: "STEM Future Leaders Award", provider: "Society of Women Engineers", amount: 5000, deadline: "Mar 1, 2027", eligibility: "Students pursuing STEM majors. Must demonstrate leadership.", matchPercent: 60, tags: ["STEM", "National"], isMerit: true, isNeedBased: false, isLocal: false, isStem: true, applicationURL: "https://www.fastweb.com/scholarship/44444"),
            ScholarshipItem(name: "First Generation College Student Grant", provider: "Sallie Mae", amount: 3000, deadline: "Dec 15, 2026", eligibility: "First-generation college students with financial need.", matchPercent: 90, tags: ["Need-Based", "First-Gen"], isMerit: false, isNeedBased: true, isLocal: false, isStem: false, applicationURL: "https://www.fastweb.com/scholarship/55555"),
            ScholarshipItem(name: "Community Foundation of Tampa Bay", provider: "CF Tampa Bay", amount: 2000, deadline: "Apr 1, 2027", eligibility: "Hillsborough County residents with community service involvement.", matchPercent: 75, tags: ["Local", "Community"], isMerit: false, isNeedBased: true, isLocal: true, isStem: false, applicationURL: "https://www.fastweb.com/scholarship/66666"),
        ]
    }
}

#Preview {
    NavigationStack {
        ScholarshipSearchView()
    }
}
