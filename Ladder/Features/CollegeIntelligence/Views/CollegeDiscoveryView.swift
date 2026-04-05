import SwiftUI

// MARK: - College Discovery Tab Root

struct CollegeDiscoveryView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = CollegeDiscoveryViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: LadderSpacing.md),
        GridItem(.flexible(), spacing: LadderSpacing.md)
    ]

    var body: some View {
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

    // MARK: - Header

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

    // MARK: - Filters

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

    // MARK: - College Grid

    @ViewBuilder
    private var collegeGrid: some View {
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

#Preview {
    CollegeDiscoveryView()
        .environment(AppCoordinator())
}
