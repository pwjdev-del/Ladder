import SwiftUI
import SwiftData

// MARK: - Scholarship Match View
// Shows scholarships ranked by match percentage against the student's profile

struct ScholarshipMatchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]
    @Query(sort: \ScholarshipModel.name) var existingScholarships: [ScholarshipModel]
    @State private var viewModel = ScholarshipMatchViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if viewModel.isLoading {
                loadingState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        headerSection
                        filterChips
                        scholarshipList
                        Spacer().frame(height: LadderSpacing.xl)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .onAppear {
            viewModel.loadAndMatch(
                profiles: profiles,
                existingScholarships: existingScholarships,
                context: context
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.md) {
            // Match summary card
            VStack(spacing: LadderSpacing.sm) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(LadderColors.secondary)

                Text("Scholarship Matches")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("You match \(viewModel.totalMatchCount) scholarships worth up to \(formattedAmount(viewModel.totalPotentialAmount))")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            .padding(LadderSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [LadderColors.primaryContainer.opacity(0.2), LadderColors.surfaceContainerLow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))
            .padding(.horizontal, LadderSpacing.md)
            .padding(.top, LadderSpacing.md)
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(ScholarshipMatchViewModel.ScholarshipMatchFilter.allCases, id: \.self) { filter in
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
    }

    // MARK: - Scholarship List

    private var scholarshipList: some View {
        LazyVStack(spacing: LadderSpacing.sm) {
            ForEach(viewModel.filteredScholarships) { matched in
                scholarshipCard(matched)
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Scholarship Card

    private func scholarshipCard(_ matched: ScholarshipMatchViewModel.MatchedScholarship) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            // Name and amount
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(matched.scholarship.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(2)

                    if let provider = matched.scholarship.provider {
                        Text(provider)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()

                if let amount = matched.scholarship.amount {
                    Text(formattedAmount(amount))
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.primary)
                }
            }

            // Match percentage bar
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                HStack {
                    Text("Match")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                    Text("\(matched.matchPercent)%")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(matchColor(for: matched.matchPercent))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LadderColors.surfaceContainerHigh)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(matchColor(for: matched.matchPercent))
                            .frame(width: geo.size.width * CGFloat(matched.matchPercent) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }

            // Deadline
            if let deadline = matched.scholarship.deadline {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("Deadline: \(deadline, format: .dateTime.month(.wide).day().year())")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            // Why You Match chips
            if !matched.matchReasons.isEmpty {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Why You Match")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    FlowLayout(spacing: LadderSpacing.xs) {
                        ForEach(matched.matchReasons, id: \.self) { reason in
                            reasonChip(reason)
                        }
                    }
                }
            }

            // Add to Tracker button
            Button {
                if matched.scholarship.isSaved {
                    viewModel.removeFromTracker(matched)
                } else {
                    viewModel.addToTracker(matched)
                }
            } label: {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: matched.scholarship.isSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.system(size: 14))
                    Text(matched.scholarship.isSaved ? "Added to Tracker" : "Add to Tracker")
                        .font(LadderTypography.labelMedium)
                }
                .foregroundStyle(matched.scholarship.isSaved ? LadderColors.primary : LadderColors.onSurfaceVariant)
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(matched.scholarship.isSaved ? LadderColors.primaryContainer.opacity(0.3) : LadderColors.surfaceContainerHigh)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
        .ladderShadow(LadderElevation.ambient)
    }

    // MARK: - Reason Chip

    private func reasonChip(_ reason: String) -> some View {
        HStack(spacing: LadderSpacing.xxs) {
            Image(systemName: reasonIcon(reason))
                .font(.system(size: 10))
            Text(reason)
                .font(LadderTypography.labelSmall)
        }
        .foregroundStyle(reasonChipTextColor(reason))
        .padding(.horizontal, LadderSpacing.sm)
        .padding(.vertical, LadderSpacing.xs)
        .background(reasonChipBackground(reason))
        .clipShape(Capsule())
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: LadderSpacing.lg) {
            ProgressView()
                .tint(LadderColors.primary)
                .scaleEffect(1.2)
            Text("Matching scholarships to your profile...")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Helpers

    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    private func matchColor(for percent: Int) -> Color {
        switch percent {
        case 80...100: return LadderColors.primary
        case 60..<80: return LadderColors.secondary
        case 40..<60: return LadderColors.tertiary
        default: return LadderColors.onSurfaceVariant
        }
    }

    private func reasonIcon(_ reason: String) -> String {
        switch reason {
        case "FL Resident": return "mappin"
        case "First-Gen": return "star"
        case "Need-Based": return "dollarsign.circle"
        case "Merit": return "medal"
        case "STEM": return "atom"
        case "Humanities": return "book"
        default: return "checkmark"
        }
    }

    private func reasonChipTextColor(_ reason: String) -> Color {
        switch reason {
        case "FL Resident": return LadderColors.primary
        case "Merit": return LadderColors.secondary
        case "Need-Based": return LadderColors.tertiary
        default: return LadderColors.onSurfaceVariant
        }
    }

    private func reasonChipBackground(_ reason: String) -> Color {
        switch reason {
        case "FL Resident": return LadderColors.primaryContainer.opacity(0.3)
        case "Merit": return LadderColors.secondaryFixed.opacity(0.2)
        case "Need-Based": return LadderColors.tertiaryContainer.opacity(0.3)
        default: return LadderColors.surfaceContainerHighest
        }
    }
}

// FlowLayout is defined in OnboardingContainerView.swift

#Preview {
    NavigationStack {
        ScholarshipMatchView()
    }
    .modelContainer(for: [StudentProfileModel.self, ScholarshipModel.self], inMemory: true)
}
