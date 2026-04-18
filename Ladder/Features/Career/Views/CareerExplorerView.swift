import SwiftUI
import SwiftData

// MARK: - Career Explorer View
// Degree-to-job pathway explorer organized by RIASEC career clusters.
// Shows career paths with salary, growth, and education info. Tap for detail.

struct CareerExplorerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var profiles: [StudentProfileModel]
    @State private var viewModel = CareerExplorerViewModel()
    @State private var showingDetail: CareerEntry?

    private var profile: StudentProfileModel? { profiles.first }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    studentClusterBanner
                    clusterSelector
                    searchBar

                    if viewModel.filteredCareers.isEmpty {
                        emptyState
                    } else {
                        careerList
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
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
                Text("Career Explorer")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(item: $showingDetail) { career in
            NavigationStack {
                CareerDetailView(career: career, viewModel: viewModel)
            }
        }
        .task {
            viewModel.initializeFromProfile(profile)
        }
    }

    // MARK: - Student Cluster Banner

    private var studentClusterBanner: some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer)
                        .frame(width: 48, height: 48)
                    Image(systemName: viewModel.selectedCluster?.icon ?? "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.onPrimaryContainer)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    if let careerPath = profile?.careerPath {
                        Text("Your Career Cluster")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Text(careerPath)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    } else {
                        Text("Explore Career Paths")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Take the career quiz to find your cluster")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Cluster Selector

    private var clusterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(CareerExplorerViewModel.allClusters) { cluster in
                    LadderFilterChip(
                        title: cluster.name,
                        isSelected: viewModel.selectedCluster?.id == cluster.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedCluster = cluster
                        }
                    }
                }
            }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LadderColors.onSurfaceVariant)
            TextField("Search careers...", text: $viewModel.searchText)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Career List

    private var careerList: some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach(viewModel.filteredCareers) { career in
                careerRow(career)
            }
        }
    }

    private func careerRow(_ career: CareerEntry) -> some View {
        Button {
            showingDetail = career
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(career.title)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(career.educationNeeded)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                HStack(spacing: LadderSpacing.md) {
                    statBadge(icon: "dollarsign", value: career.medianSalary, label: "Median")
                    statBadge(icon: "arrow.up.right", value: career.growthRate, label: "Growth")
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func statBadge(icon: String, value: String, label: String) -> some View {
        HStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(LadderColors.primary)
            Text(value)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("No careers match your search")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xxl)
    }
}

// MARK: - Career Detail View

struct CareerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let career: CareerEntry
    let viewModel: CareerExplorerViewModel

    @State private var topColleges: [CollegeModel] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    heroSection
                    aboutSection
                    degreesSection
                    majorsSection
                    skillsSection
                    dayInTheLifeSection

                    if !topColleges.isEmpty {
                        topCollegesSection
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Career Detail")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task {
            topColleges = viewModel.topColleges(for: career, context: context)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text(career.title)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                HStack(spacing: LadderSpacing.lg) {
                    detailStat(icon: "dollarsign.circle", value: career.medianSalary, label: "Median Salary")
                    detailStat(icon: "chart.line.uptrend.xyaxis", value: career.growthRate, label: "Job Growth")
                }

                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "graduationcap")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.primary)
                    Text(career.educationNeeded)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }

    private func detailStat(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.primary)
                Text(value)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "info.circle", title: "What This Job Involves")
                Text(career.description)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Required Degrees

    private var degreesSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "scroll", title: "Required Degree(s)")
                ForEach(career.requiredDegrees, id: \.self) { degree in
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)
                        Text(degree)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                }
            }
        }
    }

    // MARK: - Recommended Majors

    private var majorsSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "book.closed", title: "Recommended College Majors")
                FlowLayout(spacing: LadderSpacing.sm) {
                    ForEach(career.recommendedMajors, id: \.self) { major in
                        LadderTagChip(major, icon: "graduationcap")
                    }
                }
            }
        }
    }

    // MARK: - Skills

    private var skillsSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "star", title: "Skills Needed")
                FlowLayout(spacing: LadderSpacing.sm) {
                    ForEach(career.skills, id: \.self) { skill in
                        LadderTagChip(skill)
                    }
                }
            }
        }
    }

    // MARK: - Day in the Life

    private var dayInTheLifeSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "sun.max", title: "A Day in the Life")
                Text(career.dayInTheLife)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Top Colleges

    private var topCollegesSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "building.columns", title: "Top 10 Colleges for This Major")

                ForEach(topColleges.prefix(10), id: \.name) { college in
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)

                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text(college.name)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            if let city = college.city, let state = college.state {
                                Text("\(city), \(state)")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }

                        Spacer()

                        if let earnings = college.medianEarnings {
                            Text("$\(earnings / 1000)K avg")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                    .padding(.vertical, LadderSpacing.xs)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)
            Text(title)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }
}

// FlowLayout is defined in OnboardingContainerView.swift

#Preview {
    NavigationStack {
        CareerExplorerView()
    }
    .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
