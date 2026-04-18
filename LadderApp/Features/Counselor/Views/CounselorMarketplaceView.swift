import SwiftUI
import SwiftData

// MARK: - Counselor Marketplace View

struct CounselorMarketplaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var counselors: [CounselorProfileModel]
    @State private var searchText = ""
    @State private var selectedSpecialty = "All"
    @State private var showBookingAlert = false
    @State private var selectedCounselorName = ""

    let specialties = ["All", "Essay Review", "Test Prep", "Financial Aid", "Admissions Strategy", "Career Guidance"]

    private var filteredCounselors: [CounselorProfileModel] {
        counselors.filter { c in
            (selectedSpecialty == "All" || c.specialty == selectedSpecialty) &&
            (searchText.isEmpty || c.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        TextField("Search counselors...", text: $searchText)
                            .font(LadderTypography.bodyMedium)
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(Capsule())

                    // Specialty filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: LadderSpacing.xs) {
                            ForEach(specialties, id: \.self) { spec in
                                LadderFilterChip(title: spec, isSelected: selectedSpecialty == spec) {
                                    selectedSpecialty = spec
                                }
                            }
                        }
                    }

                    // Counselor cards or empty state
                    if filteredCounselors.isEmpty {
                        emptyState
                    } else {
                        ForEach(filteredCounselors) { counselor in
                            counselorCard(counselor)
                        }
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Find a Counselor").font(LadderTypography.titleSmall)
            }
        }
        .alert("Booking Coming Soon", isPresented: $showBookingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Online booking is not yet available. For now, reach out to \(selectedCounselorName) directly via their school's contact info.")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(LadderColors.outlineVariant)

            VStack(spacing: LadderSpacing.sm) {
                Text("No Counselors Available Yet")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Counselors will appear here as they join Ladder. Check back soon or ask your school counselor to create a profile.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(LadderSpacing.xl)
        .padding(.vertical, LadderSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Counselor Card

    private func counselorCard(_ counselor: CounselorProfileModel) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Circle()
                        .fill(LadderColors.primaryContainer)
                        .frame(width: 50, height: 50)
                        .overlay {
                            Text(String(counselor.name.split(separator: " ").last?.prefix(1) ?? "?"))
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(counselor.name)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        if let specialty = counselor.specialty {
                            Text(specialty)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        if let rate = counselor.hourlyRate {
                            Text("$\(rate)/hr")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                        if let rating = counselor.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text(String(format: "%.1f", rating))
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("(\(counselor.reviewCount))")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    }
                }

                if let bio = counselor.bio, !bio.isEmpty {
                    Text(bio)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                NavigationLink(value: Route.bookSession(counselorName: counselor.name, counselorSpecialty: counselor.specialty)) {
                    HStack(spacing: LadderSpacing.sm) {
                        Text("BOOK SESSION")
                            .font(LadderTypography.labelLarge)
                            .labelTracking()
                            .foregroundStyle(.white)
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.lg)
                    .background(
                        LinearGradient(
                            colors: [LadderColors.primary, LadderColors.primaryContainer],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .ladderShadow(LadderElevation.primaryGlow)
                }
            }
        }
    }
}
