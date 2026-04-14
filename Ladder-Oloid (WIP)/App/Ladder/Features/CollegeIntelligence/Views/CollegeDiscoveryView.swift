import SwiftUI

// MARK: - College Discovery Tab Root

struct CollegeDiscoveryView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var viewModel = CollegeDiscoveryViewModel()
    @State private var selectedCollegeId: String?

    private let columns = [
        GridItem(.flexible(), spacing: LadderSpacing.md),
        GridItem(.flexible(), spacing: LadderSpacing.md)
    ]

    private let iPadColumns = [
        GridItem(.flexible(), spacing: LadderSpacing.lg),
        GridItem(.flexible(), spacing: LadderSpacing.lg),
        GridItem(.flexible(), spacing: LadderSpacing.lg)
    ]

    var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout (existing)

    private var iPhoneLayout: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    filterSection
                    collegeGrid
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - iPad Layout (three-column master-detail)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(spacing: 0) {
                iPadSidebar
                    .frame(width: 300)

                iPadCenter
                    .frame(maxWidth: .infinity)

                if let id = selectedCollegeId,
                   let college = viewModel.colleges.first(where: { $0.id == id }) {
                    iPadDetail(college)
                        .frame(width: 400)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: selectedCollegeId)
        }
        .navigationTitle("Colleges")
        .navigationBarTitleDisplayMode(.inline)
    }

    // iPad Sidebar (left 300pt) — search + vertical filter chips + count
    private var iPadSidebar: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("COLLEGE INTELLIGENCE")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.secondaryFixed)
                        .labelTracking()

                    Text("Discover")
                        .font(LadderTypography.displaySmall)
                        .foregroundStyle(.white)
                        .editorialTracking()
                }
                .padding(LadderSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [LadderColors.primary, LadderColors.primaryContainer],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

                LadderSearchBar(
                    placeholder: "Search colleges...",
                    text: $viewModel.searchText,
                    onFilter: { coordinator.navigate(to: .collegeFilters) }
                )

                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("FILTERS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    ForEach(CollegeDiscoveryViewModel.CollegeFilter.allCases, id: \.self) { filter in
                        Button {
                            viewModel.selectedFilter = filter
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(viewModel.selectedFilter == filter ? .white : LadderColors.onSurface)
                                Spacer()
                                if viewModel.selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                viewModel.selectedFilter == filter
                                    ? LadderColors.primary
                                    : LadderColors.surfaceContainerLow
                            )
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("\(viewModel.filteredColleges.count)")
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("colleges match")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(LadderSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                Spacer(minLength: 0)
            }
            .padding(LadderSpacing.lg)
        }
        .background(LadderColors.surfaceContainer)
    }

    // iPad Center (3-column CollegeCard grid)
    private var iPadCenter: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                HStack {
                    Text("Results")
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()
                    Spacer()
                    Button {
                        coordinator.navigate(to: .deadlinesCalendar)
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "calendar")
                            Text("Deadlines")
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primaryContainer.opacity(0.2))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.filteredColleges.isEmpty {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 64))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("No colleges found")
                            .font(LadderTypography.titleLarge)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Try adjusting your filters or search")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, LadderSpacing.xxxxl)
                } else {
                    LazyVGrid(columns: iPadColumns, spacing: LadderSpacing.lg) {
                        ForEach(viewModel.filteredColleges) { college in
                            CollegeCard(
                                name: college.name,
                                location: college.location,
                                matchPercent: college.matchPercent,
                                imageURL: college.imageURL,
                                tags: college.tags,
                                isFavorite: viewModel.favoriteIds.contains(college.id),
                                onFavorite: { viewModel.toggleFavorite(college) },
                                onTap: { selectedCollegeId = college.id }
                            )
                        }
                    }
                }
            }
            .padding(LadderSpacing.xl)
            .padding(.bottom, LadderSpacing.xxxxl)
        }
    }

    // iPad Detail pane (right 400pt) — inline profile summary
    private func iPadDetail(_ college: CollegeListItem) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                // Hero
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [LadderColors.primaryContainer, LadderColors.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.white.opacity(0.25))
                        )

                    HStack {
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            if let m = college.matchPercent {
                                Text("\(m)% MATCH")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSecondaryFixed)
                                    .labelTracking()
                                    .padding(.horizontal, LadderSpacing.sm)
                                    .padding(.vertical, LadderSpacing.xxs)
                                    .background(LadderColors.secondaryFixed)
                                    .clipShape(Capsule())
                            }
                            Text(college.name)
                                .font(LadderTypography.titleLarge)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Text(college.location)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Spacer()
                        Button {
                            selectedCollegeId = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(LadderSpacing.sm)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(LadderSpacing.md)
                }
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                // Quick stats grid 2x2
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.sm) {
                    detailStat("Acceptance", college.acceptanceRate.map { "\(Int($0 * 100))%" } ?? "N/A", icon: "chart.pie.fill")
                    detailStat("Tuition", college.tuition.map { "$\(formatNumber($0))" } ?? "N/A", icon: "dollarsign.circle.fill")
                    detailStat("SAT", college.satRange ?? "N/A", icon: "pencil.line")
                    detailStat("Enrollment", college.enrollment.map { formatNumber($0) } ?? "N/A", icon: "person.3.fill")
                }

                // Tags
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Known For")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        HStack(spacing: LadderSpacing.xs) {
                            ForEach(college.tags, id: \.self) { t in
                                LadderTagChip(t)
                            }
                        }
                    }
                }

                // Actions
                VStack(spacing: LadderSpacing.sm) {
                    LadderPrimaryButton("Open Full Profile", icon: "arrow.up.right") {
                        coordinator.navigate(to: .collegeProfile(collegeId: college.id))
                    }

                    HStack(spacing: LadderSpacing.sm) {
                        Button {
                            coordinator.navigate(to: .matchScore(collegeId: college.id))
                        } label: {
                            Text("Match Score")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LadderSpacing.md)
                                .background(LadderColors.surfaceContainerHigh)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Button {
                            coordinator.navigate(to: .collegeComparison(leftId: college.id, rightId: ""))
                        } label: {
                            Text("Compare")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LadderSpacing.md)
                                .background(LadderColors.surfaceContainerHigh)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(LadderSpacing.lg)
        }
        .background(LadderColors.surfaceContainerLow)
    }

    private func detailStat(_ label: String, _ value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)
            Text(value)
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LadderSpacing.md)
        .background(LadderColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
    }

    // MARK: - Header (iPhone)

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Text("COLLEGE INTELLIGENCE")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed)
                    .labelTracking()

                Spacer()

                Button {
                    coordinator.navigate(to: .deadlinesCalendar)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
            }

            Text("Discover Colleges")
                .font(LadderTypography.headlineLarge)
                .foregroundStyle(.white)

            Text("\(viewModel.colleges.count) schools in your list")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(.white.opacity(0.7))

            LadderSearchBar(
                placeholder: "Search by name, location...",
                text: $viewModel.searchText,
                onFilter: {
                    coordinator.navigate(to: .collegeFilters)
                }
            )
        }
        .padding(LadderSpacing.lg)
        .padding(.top, LadderSpacing.xxl)
        .padding(.bottom, LadderSpacing.xxxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xxxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Filters (iPhone)

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(CollegeDiscoveryViewModel.CollegeFilter.allCases, id: \.self) { filter in
                    LadderFilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, LadderSpacing.md)
        }
        .padding(.top, -LadderSpacing.xl)
        .padding(.bottom, LadderSpacing.md)
    }

    // MARK: - College Grid (iPhone)

    private var collegeGrid: some View {
        Group {
            if viewModel.filteredColleges.isEmpty {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 48))
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Text("No colleges found")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Try adjusting your filters or search")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.top, LadderSpacing.xxxxl)
            } else {
                LazyVGrid(columns: columns, spacing: LadderSpacing.md) {
                    ForEach(viewModel.filteredColleges) { college in
                        CollegeCard(
                            name: college.name,
                            location: college.location,
                            matchPercent: college.matchPercent,
                            imageURL: college.imageURL,
                            tags: college.tags,
                            isFavorite: viewModel.favoriteIds.contains(college.id),
                            onFavorite: { viewModel.toggleFavorite(college) },
                            onTap: { coordinator.navigate(to: .collegeProfile(collegeId: college.id)) }
                        )
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
            }
        }
    }

    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

#Preview {
    CollegeDiscoveryView()
        .environment(AppCoordinator())
}
