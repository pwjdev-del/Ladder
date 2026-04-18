import SwiftUI
import SwiftData

// MARK: - Enrollment Checklist View (FL schools get deep data)

struct EnrollmentChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let collegeId: String

    @State private var college: CollegeModel?
    @State private var checklist: [EnrollmentItem] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text(college?.name ?? "Enrollment Checklist")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Complete these steps to secure your spot")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            // Progress
                            let completed = checklist.filter(\.isCompleted).count
                            let total = checklist.count
                            HStack {
                                Text("\(completed)/\(total) completed")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.primary)
                                Spacer()
                                if total > 0 {
                                    Text("\(Int(Double(completed) / Double(total) * 100))%")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
                        }
                    }

                    // Checklist items
                    ForEach($checklist) { $item in
                        LadderCard {
                            HStack(spacing: LadderSpacing.md) {
                                Button {
                                    item.isCompleted.toggle()
                                } label: {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(item.isCompleted ? LadderColors.primary : LadderColors.outlineVariant)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .strikethrough(item.isCompleted)
                                    if let detail = item.detail {
                                        Text(detail)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                    }
                                    if let deadline = item.deadline {
                                        Text(deadline)
                                            .font(LadderTypography.labelSmall)
                                            .foregroundStyle(LadderColors.primary)
                                    }
                                }

                                Spacer()

                                Image(systemName: item.icon)
                                    .foregroundStyle(LadderColors.primaryContainer)
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
            ToolbarItem(placement: .principal) {
                Text("Enrollment Checklist").font(LadderTypography.titleSmall)
            }
        }
        .task { loadChecklist() }
    }

    private func loadChecklist() {
        let descriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(descriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId || $0.name == collegeId }
        }
        guard let c = college else { return }

        var items: [EnrollmentItem] = []

        // Always include
        items.append(EnrollmentItem(title: "Submit Enrollment Deposit",
                                     detail: c.enrollmentDeposit,
                                     deadline: c.depositDeadline,
                                     icon: "dollarsign.circle"))

        // Florida-deep fields
        if c.housingDeposit != nil || c.housingDeadline != nil {
            items.append(EnrollmentItem(title: "Submit Housing Deposit",
                                         detail: c.housingDeposit,
                                         deadline: c.housingDeadline,
                                         icon: "house"))
        }

        if c.orientationRequired != nil {
            items.append(EnrollmentItem(title: "Register for Orientation",
                                         detail: c.orientationRequired.map { "Required: \($0)" },
                                         deadline: c.orientationCost.map { "Cost: \($0)" },
                                         icon: "person.3"))
        }

        if let immunizations = c.immunizationsRequired, !immunizations.contains("UNVERIFIED") {
            items.append(EnrollmentItem(title: "Submit Immunization Records",
                                         detail: immunizations,
                                         deadline: nil,
                                         icon: "cross.case"))
        }

        if let placement = c.placementTests, !placement.contains("UNVERIFIED") {
            items.append(EnrollmentItem(title: "Complete Placement Tests",
                                         detail: placement,
                                         deadline: "Before orientation",
                                         icon: "doc.text"))
        }

        // Generic items
        items.append(EnrollmentItem(title: "Submit Final Transcript", detail: "Send after graduation", deadline: "July 1", icon: "doc"))
        items.append(EnrollmentItem(title: "Complete FAFSA", detail: "Financial aid application", deadline: nil, icon: "banknote"))
        items.append(EnrollmentItem(title: "Set Up Student Portal", detail: "Email and student ID", deadline: nil, icon: "laptopcomputer"))
        items.append(EnrollmentItem(title: "Register for Classes", detail: "During or after orientation", deadline: nil, icon: "book"))

        checklist = items
    }
}

struct EnrollmentItem: Identifiable {
    let id = UUID()
    var title: String
    var detail: String?
    var deadline: String?
    var icon: String
    var isCompleted: Bool = false
}
