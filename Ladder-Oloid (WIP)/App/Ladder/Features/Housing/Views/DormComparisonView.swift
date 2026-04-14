import SwiftUI

// MARK: - Dorm Comparison View
// Batch_09_Housing_Profile K2 — side-by-side dorm cards with amenities,
// capacity, distance, cost. Mock data only.

struct DormComparisonView: View {
    let collegeId: String

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    // MARK: - Mock Data

    struct Dorm: Identifiable, Hashable {
        let id: String
        let name: String
        let tagline: String
        let imageSymbol: String
        let capacity: Int
        let distanceMinutes: Int
        let monthlyCost: Int
        let roomTypes: [String]
        let amenities: [Amenity]
        let vibe: String
    }

    struct Amenity: Hashable {
        let label: String
        let included: Bool
        let icon: String
    }

    @State private var selectedDorms: Set<String> = ["north", "west", "heritage"]

    private let allDorms: [Dorm] = [
        Dorm(
            id: "north",
            name: "North Commons",
            tagline: "Modern, social, near dining",
            imageSymbol: "building.2.fill",
            capacity: 420,
            distanceMinutes: 4,
            monthlyCost: 1180,
            roomTypes: ["Double", "Suite"],
            amenities: [
                Amenity(label: "Air conditioning", included: true, icon: "wind"),
                Amenity(label: "In-unit laundry", included: true, icon: "washer.fill"),
                Amenity(label: "Private bathroom", included: false, icon: "shower.fill"),
                Amenity(label: "Kitchen", included: true, icon: "fork.knife"),
                Amenity(label: "Gym access", included: true, icon: "dumbbell.fill"),
                Amenity(label: "Pet friendly", included: false, icon: "pawprint.fill"),
            ],
            vibe: "Social"
        ),
        Dorm(
            id: "west",
            name: "West Hall",
            tagline: "Quiet, studious, older charm",
            imageSymbol: "building.columns.fill",
            capacity: 260,
            distanceMinutes: 7,
            monthlyCost: 980,
            roomTypes: ["Single", "Double"],
            amenities: [
                Amenity(label: "Air conditioning", included: false, icon: "wind"),
                Amenity(label: "In-unit laundry", included: false, icon: "washer.fill"),
                Amenity(label: "Private bathroom", included: false, icon: "shower.fill"),
                Amenity(label: "Kitchen", included: true, icon: "fork.knife"),
                Amenity(label: "Gym access", included: false, icon: "dumbbell.fill"),
                Amenity(label: "Pet friendly", included: false, icon: "pawprint.fill"),
            ],
            vibe: "Quiet"
        ),
        Dorm(
            id: "heritage",
            name: "Heritage Suites",
            tagline: "Premium suite-style living",
            imageSymbol: "house.fill",
            capacity: 180,
            distanceMinutes: 10,
            monthlyCost: 1420,
            roomTypes: ["Suite", "Apartment"],
            amenities: [
                Amenity(label: "Air conditioning", included: true, icon: "wind"),
                Amenity(label: "In-unit laundry", included: true, icon: "washer.fill"),
                Amenity(label: "Private bathroom", included: true, icon: "shower.fill"),
                Amenity(label: "Kitchen", included: true, icon: "fork.knife"),
                Amenity(label: "Gym access", included: true, icon: "dumbbell.fill"),
                Amenity(label: "Pet friendly", included: true, icon: "pawprint.fill"),
            ],
            vibe: "Premium"
        ),
    ]

    private var activeDorms: [Dorm] {
        allDorms.filter { selectedDorms.contains($0.id) }
    }

    // MARK: - Body

    var body: some View {
        Group {
            if sizeClass == .regular { iPadLayout } else { iPhoneLayout }
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("Compare Dorms")
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
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                header
                dormPicker
                VStack(spacing: LadderSpacing.md) {
                    ForEach(activeDorms) { dorm in
                        dormCard(dorm)
                    }
                }
            }
            .padding(LadderSpacing.lg)
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                header
                dormPicker
                HStack(alignment: .top, spacing: LadderSpacing.lg) {
                    ForEach(activeDorms) { dorm in
                        dormCard(dorm)
                            .frame(maxWidth: .infinity)
                    }
                }
                comparisonMatrix
            }
            .padding(LadderSpacing.xxl)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text("COLLEGE \(collegeId.uppercased())")
                .font(LadderTypography.labelMedium)
                .labelTracking()
                .foregroundStyle(LadderColors.primary)
            Text("Compare Dorms")
                .font(LadderTypography.headlineLarge)
                .editorialTracking()
                .foregroundStyle(LadderColors.onSurface)
            Text("Tap to toggle which dorms you're comparing.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private var dormPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(allDorms) { dorm in
                    LadderFilterChip(
                        title: dorm.name,
                        isSelected: selectedDorms.contains(dorm.id)
                    ) {
                        if selectedDorms.contains(dorm.id) {
                            if selectedDorms.count > 1 { selectedDorms.remove(dorm.id) }
                        } else {
                            selectedDorms.insert(dorm.id)
                        }
                    }
                }
            }
        }
    }

    private func dormCard(_ dorm: Dorm) -> some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [LadderColors.primaryContainer, LadderColors.surfaceContainerHigh],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    Image(systemName: dorm.imageSymbol)
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(LadderColors.onSurface.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(height: 140)

                    LadderTagChip(dorm.vibe, icon: "sparkles")
                        .padding(LadderSpacing.sm)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(dorm.name)
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(dorm.tagline)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                HStack(spacing: LadderSpacing.md) {
                    statBlock("Capacity", "\(dorm.capacity)")
                    statBlock("Distance", "\(dorm.distanceMinutes) min")
                    statBlock("Cost/mo", "$\(dorm.monthlyCost)")
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Amenities")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    ForEach(dorm.amenities, id: \.self) { amenity in
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: amenity.included ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(amenity.included ? LadderColors.primary : LadderColors.error)
                            Image(systemName: amenity.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .frame(width: 16)
                            Text(amenity.label)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                    }
                }

                HStack(spacing: LadderSpacing.xs) {
                    ForEach(dorm.roomTypes, id: \.self) { type in
                        LadderTagChip(type)
                    }
                }
            }
        }
    }

    private var comparisonMatrix: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Quick Comparison")
                    .font(LadderTypography.titleLarge)
                    .foregroundStyle(LadderColors.onSurface)

                let allAmenities = Array(Set(activeDorms.flatMap { $0.amenities.map(\.label) })).sorted()

                ForEach(allAmenities, id: \.self) { label in
                    HStack {
                        Text(label)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        ForEach(activeDorms) { dorm in
                            let included = dorm.amenities.first(where: { $0.label == label })?.included ?? false
                            VStack(spacing: 2) {
                                Image(systemName: included ? "checkmark" : "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(included ? LadderColors.primary : LadderColors.error)
                                Text(dorm.name.split(separator: " ").first.map(String.init) ?? dorm.name)
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            .frame(width: 80)
                        }
                    }
                    Divider().background(LadderColors.outlineVariant)
                }
            }
        }
    }

    private func statBlock(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
            Text(label.uppercased())
                .font(LadderTypography.labelSmall)
                .labelTracking()
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text(value)
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LadderSpacing.sm)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
    }
}
