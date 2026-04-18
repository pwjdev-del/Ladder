import SwiftUI
import SwiftData

// MARK: - Housing Timeline View

struct HousingTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var colleges: [CollegeModel] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    Text("Housing Timeline")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if colleges.isEmpty {
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "house")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("Save colleges to see housing deadlines")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }

                    ForEach(colleges, id: \.name) { college in
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text(college.name)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)

                                if let deposit = college.housingDeposit {
                                    infoRow("Housing Deposit", deposit, "dollarsign.circle")
                                }
                                if let deadline = college.housingDeadline {
                                    infoRow("Deadline", deadline, "calendar")
                                }
                                if let enrollment = college.enrollmentDeposit {
                                    infoRow("Enrollment Deposit", enrollment, "banknote")
                                }
                                if let depDeadline = college.depositDeadline {
                                    infoRow("Deposit Deadline", depDeadline, "clock")
                                }
                                if let orientation = college.orientationRequired {
                                    infoRow("Orientation", orientation, "person.3")
                                }

                                if college.housingDeposit == nil && college.housingDeadline == nil {
                                    Text("Housing details not available — check the school's housing office website")
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
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
        }
        .task { loadColleges() }
    }

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(LadderColors.primary)
                .frame(width: 24)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(value)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurface)
                .multilineTextAlignment(.trailing)
        }
    }

    private func loadColleges() {
        // Load FL colleges that have housing data
        let descriptor = FetchDescriptor<CollegeModel>(
            predicate: #Predicate { $0.state == "FL" },
            sortBy: [SortDescriptor(\.name)]
        )
        if let results = try? context.fetch(descriptor) {
            colleges = results.filter { $0.housingDeposit != nil || $0.enrollmentDeposit != nil }
        }
    }
}
