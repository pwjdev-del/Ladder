import SwiftUI
import SwiftData

// MARK: - Major Picker View
// Searchable list of majors filtered by career cluster.
// Saves selection to profile.selectedMajor and dismisses.

struct MajorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]
    @State private var searchText = ""

    let careerCluster: String

    private var student: StudentProfileModel? { profiles.first }

    private var filteredMajors: [String] {
        let majors = MajorPickerView.majors(for: careerCluster)
        guard !searchText.isEmpty else { return majors }
        return majors.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        TextField("Search majors", text: $searchText)
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurface)
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.sm + 2)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.top, LadderSpacing.sm)
                    .padding(.bottom, LadderSpacing.sm)

                    // Cluster label
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: clusterIcon(for: careerCluster))
                            .font(.system(size: 13))
                            .foregroundStyle(LadderColors.primary)
                        Text("Majors in \(careerCluster)")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Spacer()
                        Text("\(filteredMajors.count) options")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.bottom, LadderSpacing.sm)

                    if filteredMajors.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 1) {
                                ForEach(filteredMajors, id: \.self) { major in
                                    majorRow(major)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.bottom, LadderSpacing.xxxxl)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") { dismiss() }
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                ToolbarItem(placement: .principal) {
                    Text("Pick a Major")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }

    // MARK: - Major Row

    private func majorRow(_ major: String) -> some View {
        let isSelected = student?.selectedMajor == major
        return Button {
            selectMajor(major)
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Text(major)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(LadderColors.primary)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 18))
                        .foregroundStyle(LadderColors.outlineVariant)
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .background(isSelected
                        ? LadderColors.primaryContainer.opacity(0.15)
                        : LadderColors.surfaceContainerLow)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.md) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("No majors match \"\(searchText)\"")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
        }
    }

    // MARK: - Select Major

    private func selectMajor(_ major: String) {
        guard let profile = student else { return }
        profile.selectedMajor = major
        try? context.save()
        dismiss()
    }

    // MARK: - Cluster Icon Helper

    private func clusterIcon(for cluster: String) -> String {
        switch cluster {
        case "STEM": return "gearshape.2.fill"
        case "Medical": return "cross.case.fill"
        case "Business": return "briefcase.fill"
        case "Humanities": return "book.fill"
        case "Sports": return "figure.run"
        case "Law": return "building.columns.fill"
        default: return "sparkles"
        }
    }

    // MARK: - Major Lists by Cluster

    static func majors(for cluster: String) -> [String] {
        switch cluster {
        case "STEM":
            return [
                "Computer Science",
                "Software Engineering",
                "Mechanical Engineering",
                "Electrical Engineering",
                "Civil Engineering",
                "Data Science",
                "Physics",
                "Chemistry",
                "Mathematics",
                "Environmental Science",
                "Aerospace Engineering"
            ]
        case "Medical":
            return [
                "Pre-Med",
                "Nursing",
                "Pharmacy",
                "Dentistry",
                "Physical Therapy",
                "Biomedical Science",
                "Public Health"
            ]
        case "Business":
            return [
                "Finance",
                "Accounting",
                "Marketing",
                "Entrepreneurship",
                "Economics",
                "Management",
                "Supply Chain"
            ]
        case "Humanities":
            return [
                "Psychology",
                "English",
                "History",
                "Political Science",
                "Sociology",
                "Philosophy",
                "Communications"
            ]
        case "Sports":
            return [
                "Exercise Science",
                "Sports Management",
                "Athletic Training",
                "Kinesiology"
            ]
        case "Law":
            return [
                "Pre-Law",
                "Criminal Justice",
                "Political Science",
                "International Relations"
            ]
        default:
            return []
        }
    }
}

#Preview {
    MajorPickerView(careerCluster: "STEM")
        .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
