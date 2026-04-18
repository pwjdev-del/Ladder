import SwiftUI
import SwiftData

// MARK: - AP Credits View
// Shows AP exam credit policies per college with search and category filtering.
// Includes all 38 AP exams with Florida SUS policies and UF-specific 4+ requirements.

struct APCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let collegeId: String

    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var college: CollegeModel?

    private let categories = ["All", "STEM", "Humanities", "Social Science", "Arts", "Languages"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if let college {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.md) {
                        headerSection(college)
                        searchBar
                        categoryFilter
                        creditSummary(for: college)
                        creditTable(for: college)
                        policyNote(college)
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.top, LadderSpacing.md)
                    .padding(.bottom, 120)
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(LadderColors.primary)
                    Text("Loading AP credit data...")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .padding(.top, LadderSpacing.md)
                    Spacer()
                }
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
                Text("AP Credit Policy")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task { loadCollege() }
    }

    private func loadCollege() {
        let descriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(descriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId || $0.name == collegeId }
        }
    }

    // MARK: - Header

    private func headerSection(_ c: CollegeModel) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.primary)

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(c.name)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("AP Credit Acceptance Guide")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Text("Scores shown reflect the minimum required for credit. Higher scores may earn additional credit or placement into advanced courses.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LadderColors.onSurfaceVariant)
            TextField("Search AP exams...", text: $searchText)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(categories, id: \.self) { category in
                    LadderFilterChip(title: category, isSelected: selectedCategory == category) {
                        withAnimation { selectedCategory = category }
                    }
                }
            }
        }
    }

    // MARK: - Credit Summary

    private func creditSummary(for college: CollegeModel) -> some View {
        let policies = policiesForCollege(college)
        let totalCredits = policies.reduce(0) { $0 + $1.creditsEarned }
        let score3Count = policies.filter { $0.minScore == 3 }.count
        let score4Count = policies.filter { $0.minScore >= 4 }.count

        return LadderCard {
            HStack(spacing: 0) {
                summaryItem(value: "\(policies.count)", label: "AP Exams", icon: "doc.text")
                summaryItem(value: "\(totalCredits)", label: "Max Credits", icon: "graduationcap")
                summaryItem(value: "\(score3Count)", label: "Need 3+", icon: "checkmark.circle")
                if score4Count > 0 {
                    summaryItem(value: "\(score4Count)", label: "Need 4+", icon: "exclamationmark.circle")
                }
            }
        }
    }

    private func summaryItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Credit Table

    private func creditTable(for college: CollegeModel) -> some View {
        let policies = policiesForCollege(college)
        let filtered = policies.filter { exam in
            let matchesSearch = searchText.isEmpty || exam.examName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || exam.category == selectedCategory
            return matchesSearch && matchesCategory
        }

        return VStack(spacing: LadderSpacing.sm) {
            // Table header
            HStack(spacing: 0) {
                Text("AP EXAM")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .labelTracking()

                Text("SCORE")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(width: 50, alignment: .center)
                    .labelTracking()

                Text("CR")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(width: 32, alignment: .center)
                    .labelTracking()

                Text("EQUIVALENT")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(width: 90, alignment: .trailing)
                    .labelTracking()
            }
            .padding(.horizontal, LadderSpacing.md)

            if filtered.isEmpty {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("No matching AP exams")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.xxl)
            } else {
                ForEach(filtered) { exam in
                    apExamRow(exam)
                }
            }
        }
    }

    private func apExamRow(_ exam: APCreditEntry) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(exam.examName)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(2)

                Text(exam.category)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(exam.minScore)+")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(scoreColor(exam.minScore))
                .frame(width: 50, alignment: .center)

            Text("\(exam.creditsEarned)")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurface)
                .frame(width: 32, alignment: .center)

            Text(exam.equivalentCourse)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .frame(width: 90, alignment: .trailing)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 3: return LadderColors.primary
        case 4: return LadderColors.secondary
        case 5: return LadderColors.tertiary
        default: return LadderColors.onSurfaceVariant
        }
    }

    // MARK: - Policy Note

    private func policyNote(_ c: CollegeModel) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(LadderColors.primary)
                    Text("Important Notes")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                }

                Text("AP credit policies are subject to change. Always verify with the university's registrar office. Some departments may have additional requirements or limits on total AP credits accepted.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                if let url = c.websiteURL {
                    Text("Visit \(url) for the latest policies.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }

    // MARK: - Per-School Policy Logic

    private func policiesForCollege(_ college: CollegeModel) -> [APCreditEntry] {
        let name = college.name.lowercased()

        // UF requires 4+ on some STEM exams
        let isUF = name.contains("university of florida") && !name.contains("central") && !name.contains("south") && !name.contains("international") && !name.contains("atlantic") && !name.contains("gulf")

        if isUF {
            return APCreditDatabase.floridaSUS.map { entry in
                if APCreditDatabase.ufFourPlusExams.contains(entry.examName) {
                    return APCreditEntry(
                        examName: entry.examName,
                        category: entry.category,
                        minScore: 4,
                        creditsEarned: entry.creditsEarned,
                        equivalentCourse: entry.equivalentCourse
                    )
                }
                return entry
            }
        }

        // All other Florida SUS schools: standard 3+ policy
        return APCreditDatabase.floridaSUS
    }
}

// MARK: - AP Credit Data Model

struct APCreditEntry: Identifiable {
    let id = UUID()
    let examName: String
    let category: String
    let minScore: Int
    let creditsEarned: Int
    let equivalentCourse: String
}

// MARK: - AP Credit Database
// Florida SUS statewide AP credit policies plus UF-specific overrides

struct APCreditDatabase {

    /// UF exams that require a 4+ instead of 3+
    static let ufFourPlusExams: Set<String> = [
        "AP Biology",
        "AP Chemistry",
        "AP Physics C: Mechanics",
        "AP Physics C: E&M",
    ]

    /// All 38 AP exams with Florida State University System credit equivalencies
    static let floridaSUS: [APCreditEntry] = [
        // STEM (13 exams)
        APCreditEntry(examName: "AP Calculus AB", category: "STEM", minScore: 3, creditsEarned: 4, equivalentCourse: "MAC 2311"),
        APCreditEntry(examName: "AP Calculus BC", category: "STEM", minScore: 3, creditsEarned: 8, equivalentCourse: "MAC 2311/2312"),
        APCreditEntry(examName: "AP Precalculus", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "MAC 1147"),
        APCreditEntry(examName: "AP Statistics", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "STA 2023"),
        APCreditEntry(examName: "AP Biology", category: "STEM", minScore: 3, creditsEarned: 8, equivalentCourse: "BSC 2010/2011"),
        APCreditEntry(examName: "AP Chemistry", category: "STEM", minScore: 3, creditsEarned: 8, equivalentCourse: "CHM 2045/2046"),
        APCreditEntry(examName: "AP Environmental Science", category: "STEM", minScore: 3, creditsEarned: 4, equivalentCourse: "EVR 1001 + Lab"),
        APCreditEntry(examName: "AP Physics 1", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "PHY 2053"),
        APCreditEntry(examName: "AP Physics 2", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "PHY 2054"),
        APCreditEntry(examName: "AP Physics C: Mechanics", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "PHY 2048"),
        APCreditEntry(examName: "AP Physics C: E&M", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "PHY 2049"),
        APCreditEntry(examName: "AP Computer Science A", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "COP 2210"),
        APCreditEntry(examName: "AP Computer Science Principles", category: "STEM", minScore: 3, creditsEarned: 3, equivalentCourse: "CGS 1060"),

        // Humanities (8 exams)
        APCreditEntry(examName: "AP English Language", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "ENC 1101"),
        APCreditEntry(examName: "AP English Literature", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "ENC 1102"),
        APCreditEntry(examName: "AP World History", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "WOH 2012"),
        APCreditEntry(examName: "AP US History", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "AMH 2010"),
        APCreditEntry(examName: "AP European History", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "EUH 2000"),
        APCreditEntry(examName: "AP Art History", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "ARH 2000"),
        APCreditEntry(examName: "AP African American Studies", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "AFA 2000"),
        APCreditEntry(examName: "AP Seminar", category: "Humanities", minScore: 3, creditsEarned: 3, equivalentCourse: "Elective"),

        // Social Science (6 exams)
        APCreditEntry(examName: "AP Psychology", category: "Social Science", minScore: 3, creditsEarned: 3, equivalentCourse: "PSY 2012"),
        APCreditEntry(examName: "AP Macroeconomics", category: "Social Science", minScore: 3, creditsEarned: 3, equivalentCourse: "ECO 2013"),
        APCreditEntry(examName: "AP Microeconomics", category: "Social Science", minScore: 3, creditsEarned: 3, equivalentCourse: "ECO 2023"),
        APCreditEntry(examName: "AP US Govt & Politics", category: "Social Science", minScore: 3, creditsEarned: 3, equivalentCourse: "POS 2041"),
        APCreditEntry(examName: "AP Comparative Govt", category: "Social Science", minScore: 3, creditsEarned: 3, equivalentCourse: "CPO 2001"),
        APCreditEntry(examName: "AP Human Geography", category: "Social Science", minScore: 3, creditsEarned: 3, equivalentCourse: "GEA 1000"),

        // Arts (5 exams)
        APCreditEntry(examName: "AP Music Theory", category: "Arts", minScore: 3, creditsEarned: 3, equivalentCourse: "MUT 1111"),
        APCreditEntry(examName: "AP 2-D Art and Design", category: "Arts", minScore: 3, creditsEarned: 3, equivalentCourse: "ART 1201C"),
        APCreditEntry(examName: "AP 3-D Art and Design", category: "Arts", minScore: 3, creditsEarned: 3, equivalentCourse: "ART 1300C"),
        APCreditEntry(examName: "AP Drawing", category: "Arts", minScore: 3, creditsEarned: 3, equivalentCourse: "ART 1100C"),
        APCreditEntry(examName: "AP Research", category: "Arts", minScore: 3, creditsEarned: 3, equivalentCourse: "Elective"),

        // Languages (7 exams)
        APCreditEntry(examName: "AP Spanish Language", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "SPN 1120/1121"),
        APCreditEntry(examName: "AP Spanish Literature", category: "Languages", minScore: 3, creditsEarned: 3, equivalentCourse: "SPN 2340"),
        APCreditEntry(examName: "AP French Language", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "FRE 1120/1121"),
        APCreditEntry(examName: "AP German Language", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "GER 1120/1121"),
        APCreditEntry(examName: "AP Chinese Language", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "CHI 1120/1121"),
        APCreditEntry(examName: "AP Japanese Language", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "JPN 1120/1121"),
        APCreditEntry(examName: "AP Italian Language", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "ITA 1120/1121"),
        APCreditEntry(examName: "AP Latin", category: "Languages", minScore: 3, creditsEarned: 8, equivalentCourse: "LAT 1120/1121"),
    ]
}

#Preview {
    NavigationStack {
        APCreditsView(collegeId: "University of Florida")
    }
}
