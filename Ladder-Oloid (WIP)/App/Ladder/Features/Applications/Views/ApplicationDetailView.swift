import SwiftUI

// MARK: - Application Detail View

struct ApplicationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    let applicationId: String

    private var college: CollegeListItem? {
        CollegeListItem.sampleColleges.first { $0.id == applicationId }
    }

    @State private var checklistItems: [AppChecklistItem] = AppChecklistItem.sampleItems

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    statusCard
                    progressSection
                    checklistSection
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(college?.name ?? "Application")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text(college?.name ?? "College")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(college?.location ?? "")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    if let match = college?.matchPercent {
                        CircularProgressView(
                            progress: Double(match) / 100.0,
                            label: "\(match)%",
                            sublabel: "Match",
                            size: 56
                        )
                    }
                }

                Divider()

                HStack(spacing: LadderSpacing.lg) {
                    statusItem("Status", value: "Planning", color: LadderColors.primary)
                    statusItem("Deadline", value: "Nov 1", color: LadderColors.error)
                    statusItem("Type", value: "Early Action", color: LadderColors.onSurfaceVariant)
                }
            }
        }
    }

    private func statusItem(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: LadderSpacing.xxs) {
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Progress

    private var progressSection: some View {
        let completed = checklistItems.filter(\.isCompleted).count
        let total = checklistItems.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text("Application Progress")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Spacer()

                    Text("\(completed)/\(total)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                LinearProgressBar(progress: progress)
            }
        }
    }

    // MARK: - Checklist

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("APPLICATION CHECKLIST")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            ForEach(Array(checklistItems.enumerated()), id: \.element.id) { index, item in
                checklistRow(item, index: index)
            }
        }
    }

    private func checklistRow(_ item: AppChecklistItem, index: Int) -> some View {
        Button {
            withAnimation {
                checklistItems[index].isCompleted.toggle()
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.isCompleted ? LadderColors.accentLime : LadderColors.outline)

                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 32, height: 32)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(item.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(item.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                        .strikethrough(item.isCompleted)

                    Text(item.category)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .opacity(item.isCompleted ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Checklist Item

struct AppChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let icon: String
    var isCompleted: Bool

    static var sampleItems: [AppChecklistItem] {
        [
            AppChecklistItem(title: "Create Common App Account", category: "Setup", icon: "person.badge.plus", isCompleted: true),
            AppChecklistItem(title: "Request Official Transcript", category: "Transcript", icon: "doc.text", isCompleted: true),
            AppChecklistItem(title: "Submit SAT Scores", category: "Testing", icon: "pencil.line", isCompleted: false),
            AppChecklistItem(title: "Write Personal Statement", category: "Essay", icon: "text.alignleft", isCompleted: false),
            AppChecklistItem(title: "Write Supplemental Essays", category: "Essay", icon: "doc.append", isCompleted: false),
            AppChecklistItem(title: "Request 2 Recommendation Letters", category: "Recommendations", icon: "envelope", isCompleted: false),
            AppChecklistItem(title: "Complete Activities Section", category: "Activities", icon: "list.bullet", isCompleted: false),
            AppChecklistItem(title: "Review and Submit Application", category: "Submission", icon: "paperplane", isCompleted: false),
            AppChecklistItem(title: "Pay Application Fee", category: "Financial", icon: "creditcard", isCompleted: false),
        ]
    }
}

#Preview {
    NavigationStack {
        ApplicationDetailView(applicationId: "uf")
            .environment(AppCoordinator())
    }
}
