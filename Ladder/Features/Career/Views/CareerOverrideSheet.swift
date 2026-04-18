import SwiftUI
import SwiftData

// MARK: - Career Override Sheet
// Lets students manually pick a career cluster, overriding quiz results.
// 6 tappable cards: STEM, Medical, Business, Humanities, Sports, Law.

struct CareerOverrideSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]
    @State private var selectedCluster: CareerClusterOption? = nil
    @State private var showMajorPicker = false

    private var student: StudentProfileModel? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        // Header
                        VStack(spacing: LadderSpacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.3))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 28))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            Text("Choose Your Path")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            Text("Select the career cluster that fits you best. You can always change this later.")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, LadderSpacing.md)
                        }
                        .padding(.top, LadderSpacing.md)

                        // Cluster cards grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: LadderSpacing.md),
                            GridItem(.flexible(), spacing: LadderSpacing.md)
                        ], spacing: LadderSpacing.md) {
                            ForEach(CareerClusterOption.allCases, id: \.self) { cluster in
                                clusterCard(cluster)
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)

                        // Current path indicator
                        if let current = student?.careerPath {
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 13))
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Text("Current path: \(current)")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            .padding(.horizontal, LadderSpacing.md)
                        }
                    }
                    .padding(.bottom, LadderSpacing.xxxxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                ToolbarItem(placement: .principal) {
                    Text("Career Path")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            .sheet(isPresented: $showMajorPicker) {
                if let cluster = selectedCluster {
                    MajorPickerView(careerCluster: cluster.name)
                }
            }
        }
    }

    // MARK: - Cluster Card

    private func clusterCard(_ cluster: CareerClusterOption) -> some View {
        let isCurrentPath = student?.careerPath == cluster.name
        return Button {
            applyOverride(cluster)
        } label: {
            VStack(spacing: LadderSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(isCurrentPath
                              ? LadderColors.primary.opacity(0.2)
                              : LadderColors.primaryContainer.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: cluster.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isCurrentPath ? LadderColors.primary : LadderColors.onSurfaceVariant)
                }

                Text(cluster.name)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text(cluster.shortDescription)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(LadderSpacing.md)
            .frame(maxWidth: .infinity)
            .background(isCurrentPath
                        ? LadderColors.primaryContainer.opacity(0.15)
                        : LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(
                        isCurrentPath ? LadderColors.primary.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Apply Override

    private func applyOverride(_ cluster: CareerClusterOption) {
        guard let profile = student else { return }
        profile.careerPath = cluster.name
        profile.selectedMajor = nil // Reset major when cluster changes
        try? context.save()
        ConnectionEngine.shared.onCareerPathChanged(newPath: cluster.name, context: context)
        selectedCluster = cluster
        showMajorPicker = true
    }
}

// MARK: - Career Cluster Option

enum CareerClusterOption: String, CaseIterable, Hashable {
    case stem = "STEM"
    case medical = "Medical"
    case business = "Business"
    case humanities = "Humanities"
    case sports = "Sports"
    case law = "Law"

    var name: String { rawValue }

    var icon: String {
        switch self {
        case .stem: return "gearshape.2.fill"
        case .medical: return "cross.case.fill"
        case .business: return "briefcase.fill"
        case .humanities: return "book.fill"
        case .sports: return "figure.run"
        case .law: return "building.columns.fill"
        }
    }

    var shortDescription: String {
        switch self {
        case .stem: return "Engineering, Computer Science, Data Science"
        case .medical: return "Pre-Med, Nursing, Public Health"
        case .business: return "Finance, Marketing, Entrepreneurship"
        case .humanities: return "Psychology, English, Communications"
        case .sports: return "Kinesiology, Sports Management"
        case .law: return "Pre-Law, Criminal Justice, Policy"
        }
    }
}

#Preview {
    CareerOverrideSheet()
        .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
