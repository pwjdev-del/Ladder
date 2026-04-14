import SwiftUI

// MARK: - Roommate Finder
// Batch_09_Housing_Profile K4 — grid of potential roommate cards with
// compatibility scoring and interest chips. Mock data only.

struct RoommateFinderView: View {
    let collegeId: String

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    // MARK: - Mock Model

    struct Roommate: Identifiable, Hashable {
        let id: String
        let name: String
        let year: String
        let major: String
        let compatibility: Int
        let vibe: String
        let sleep: String
        let interests: [String]
        let initials: String
        let accent: Color
    }

    private let roommates: [Roommate] = [
        .init(id: "1", name: "Amara Chen", year: "Freshman", major: "Computer Science", compatibility: 94,
              vibe: "Balanced", sleep: "Night Owl",
              interests: ["Hackathons", "K-Pop", "Anime", "Boba"], initials: "AC", accent: LadderColors.primary),
        .init(id: "2", name: "Jordan Pierce", year: "Freshman", major: "Biology (Pre-Med)", compatibility: 88,
              vibe: "Quiet", sleep: "Early Bird",
              interests: ["Running", "Cooking", "Podcasts"], initials: "JP", accent: LadderColors.secondaryFixed),
        .init(id: "3", name: "Maya Rodriguez", year: "Freshman", major: "Environmental Studies", compatibility: 86,
              vibe: "Social", sleep: "Flexible",
              interests: ["Hiking", "Climate", "Vegetarian", "Yoga"], initials: "MR", accent: LadderColors.accentLime),
        .init(id: "4", name: "Liam Okafor", year: "Freshman", major: "Mechanical Engineering", compatibility: 82,
              vibe: "Balanced", sleep: "Night Owl",
              interests: ["Soccer", "Gaming", "F1"], initials: "LO", accent: LadderColors.tertiary),
        .init(id: "5", name: "Priya Natarajan", year: "Freshman", major: "Economics", compatibility: 79,
              vibe: "Quiet", sleep: "Early Bird",
              interests: ["Classical music", "Chess", "Reading"], initials: "PN", accent: LadderColors.primaryContainer),
        .init(id: "6", name: "Sofia Martín", year: "Freshman", major: "Design", compatibility: 75,
              vibe: "Social", sleep: "Night Owl",
              interests: ["Film", "Thrifting", "Dance"], initials: "SM", accent: LadderColors.primary),
    ]

    @State private var filters: Set<String> = ["All"]
    @State private var search: String = ""
    @State private var selectedRoommate: Roommate?

    private let filterOptions = ["All", "Quiet", "Balanced", "Social", "Early Bird", "Night Owl", "STEM", "Humanities"]

    private var filtered: [Roommate] {
        roommates.filter { r in
            (search.isEmpty || r.name.localizedCaseInsensitiveContains(search) || r.major.localizedCaseInsensitiveContains(search))
            && (filters.contains("All") || !filters.isDisjoint(with: [r.vibe, r.sleep]))
        }
    }

    // MARK: - Body

    var body: some View {
        Group {
            if sizeClass == .regular { iPadLayout } else { iPhoneLayout }
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("Roommate Finder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .sheet(item: $selectedRoommate) { roommate in
            roommateDetail(roommate)
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                header
                searchField
                filterChipsRow
                LazyVGrid(columns: [GridItem(.flexible(), spacing: LadderSpacing.md),
                                    GridItem(.flexible(), spacing: LadderSpacing.md)],
                          spacing: LadderSpacing.md) {
                    ForEach(filtered) { r in
                        roommateCard(r).onTapGesture { selectedRoommate = r }
                    }
                }
            }
            .padding(LadderSpacing.lg)
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            // Filter rail
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Filters")
                    .font(LadderTypography.titleLarge)
                    .foregroundStyle(LadderColors.onSurface)

                Text("VIBE & SCHEDULE")
                    .font(LadderTypography.labelSmall)
                    .labelTracking()
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    ForEach(filterOptions, id: \.self) { opt in
                        LadderFilterChip(title: opt, isSelected: filters.contains(opt)) {
                            toggleFilter(opt)
                        }
                    }
                }

                Spacer()
            }
            .padding(LadderSpacing.xl)
            .frame(width: 260, alignment: .topLeading)
            .frame(maxHeight: .infinity)
            .background(LadderColors.surfaceContainerLow)

            // Grid
            ScrollView {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    header
                    searchField
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 260), spacing: LadderSpacing.lg)
                    ], spacing: LadderSpacing.lg) {
                        ForEach(filtered) { r in
                            roommateCard(r).onTapGesture { selectedRoommate = r }
                        }
                    }
                }
                .padding(LadderSpacing.xxl)
            }
        }
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text("COLLEGE \(collegeId.uppercased())")
                .font(LadderTypography.labelMedium)
                .labelTracking()
                .foregroundStyle(LadderColors.primary)
            Text("Find Your Roommate")
                .font(LadderTypography.headlineLarge)
                .editorialTracking()
                .foregroundStyle(LadderColors.onSurface)
            Text("Browse matches ranked by compatibility with your preferences.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private var searchField: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LadderColors.onSurfaceVariant)
            TextField("Search by name or major", text: $search)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerHigh)
        .clipShape(Capsule())
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(filterOptions, id: \.self) { opt in
                    LadderFilterChip(title: opt, isSelected: filters.contains(opt)) {
                        toggleFilter(opt)
                    }
                }
            }
        }
    }

    private func roommateCard(_ r: Roommate) -> some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(alignment: .center, spacing: LadderSpacing.md) {
                    ZStack {
                        Circle().fill(r.accent.opacity(0.25))
                        Text(r.initials)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(r.name)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineLimit(1)
                        Text(r.year)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                }

                Text(r.major)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    HStack {
                        Text("Compatibility")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Spacer()
                        Text("\(r.compatibility)%")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.primary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(LadderColors.surfaceContainerHighest)
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [LadderColors.primary, LadderColors.accentLime],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .frame(width: geo.size.width * CGFloat(r.compatibility) / 100)
                        }
                    }
                    .frame(height: 6)
                }

                HStack(spacing: LadderSpacing.xs) {
                    LadderTagChip(r.vibe, icon: "person.2.fill")
                    LadderTagChip(r.sleep, icon: "moon.fill")
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LadderSpacing.xs) {
                        ForEach(r.interests, id: \.self) { interest in
                            LadderTagChip(interest)
                        }
                    }
                }
            }
        }
    }

    private func roommateDetail(_ r: Roommate) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    HStack(spacing: LadderSpacing.md) {
                        ZStack {
                            Circle().fill(r.accent.opacity(0.25))
                            Text(r.initials)
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                        .frame(width: 88, height: 88)
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text(r.name).font(LadderTypography.headlineSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("\(r.year) · \(r.major)")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            Text("\(r.compatibility)% compatible")
                                .font(LadderTypography.labelLarge)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }

                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Interests")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            HStack(spacing: LadderSpacing.xs) {
                                ForEach(r.interests, id: \.self) { LadderTagChip($0) }
                            }
                        }
                    }

                    LadderPrimaryButton("Send Connect Request", icon: "paperplane.fill") {}
                }
                .padding(LadderSpacing.lg)
            }
            .background(LadderColors.surface)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { selectedRoommate = nil } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleFilter(_ opt: String) {
        if opt == "All" {
            filters = ["All"]
            return
        }
        filters.remove("All")
        if filters.contains(opt) { filters.remove(opt) } else { filters.insert(opt) }
        if filters.isEmpty { filters = ["All"] }
    }
}
