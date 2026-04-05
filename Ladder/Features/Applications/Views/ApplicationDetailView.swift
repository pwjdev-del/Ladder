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
    @State private var postItems: [PostAcceptanceItem] = PostAcceptanceItem.sampleItems
    @State private var activeTab = 0   // 0 = Application, 1 = Post-Acceptance

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    statusCard
                    tabPicker
                    if activeTab == 0 {
                        progressSection
                        checklistSection
                    } else {
                        postAcceptanceSection
                    }
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

                HStack(spacing: 0) {
                    Rectangle().fill(LadderColors.outlineVariant.opacity(0.4)).frame(height: 1)
                }

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

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach([("Application", 0), ("Post-Acceptance", 1)], id: \.1) { label, idx in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { activeTab = idx }
                } label: {
                    VStack(spacing: LadderSpacing.xs) {
                        Text(label)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(activeTab == idx ? LadderColors.primary : LadderColors.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.sm)
                        Rectangle()
                            .fill(activeTab == idx ? LadderColors.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
    }

    // MARK: - Application Tab

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

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("APPLICATION CHECKLIST")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            ForEach(Array(checklistItems.enumerated()), id: \.element.id) { index, item in
                appChecklistRow(item, index: index)
            }
        }
    }

    private func appChecklistRow(_ item: AppChecklistItem, index: Int) -> some View {
        Button {
            withAnimation { checklistItems[index].isCompleted.toggle() }
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

    // MARK: - Post-Acceptance Tab

    private var postAcceptanceSection: some View {
        VStack(spacing: LadderSpacing.md) {
            acceptanceBanner
            postProgressCard
            postChecklistGroups
        }
    }

    private var acceptanceBanner: some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle()
                        .fill(LadderColors.accentLime.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LadderColors.accentLime)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Congratulations!")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("Complete these steps to secure your spot.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Spacer()
            }
        }
    }

    private var postProgressCard: some View {
        let done = postItems.filter(\.isCompleted).count
        let total = postItems.count
        let progress = total > 0 ? Double(done) / Double(total) : 0

        return LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text("Enrollment Progress")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text("\(done)/\(total)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(progress == 1.0 ? LadderColors.accentLime : LadderColors.primary)
                }
                LinearProgressBar(progress: progress)
                if progress == 1.0 {
                    Text("All done! You're officially enrolled.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.accentLime)
                }
            }
        }
    }

    private var postChecklistGroups: some View {
        let categories = PostAcceptanceCategory.allCases
        return VStack(spacing: LadderSpacing.lg) {
            ForEach(categories, id: \.self) { cat in
                let items = postItems.filter { $0.category == cat }
                if !items.isEmpty {
                    postCategorySection(cat, items: items)
                }
            }
        }
    }

    private func postCategorySection(_ cat: PostAcceptanceCategory, items: [PostAcceptanceItem]) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: cat.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(cat.color)
                Text(cat.rawValue.uppercased())
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
            }

            ForEach(items) { item in
                if let idx = postItems.firstIndex(where: { $0.id == item.id }) {
                    postChecklistRow(postItems[idx], index: idx)
                }
            }
        }
    }

    private func postChecklistRow(_ item: PostAcceptanceItem, index: Int) -> some View {
        Button {
            withAnimation { postItems[index].isCompleted.toggle() }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.isCompleted ? LadderColors.accentLime : LadderColors.outline)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: LadderSpacing.xs) {
                        Text(item.title)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(item.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                            .strikethrough(item.isCompleted)
                        if item.isUrgent && !item.isCompleted {
                            Text("URGENT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(LadderColors.error)
                                .clipShape(Capsule())
                        }
                    }
                    if let due = item.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text("Due: \(due)")
                                .font(LadderTypography.bodySmall)
                        }
                        .foregroundStyle(item.isUrgent && !item.isCompleted ? LadderColors.error : LadderColors.onSurfaceVariant)
                    }
                    Text(item.detail)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()
            }
            .padding(LadderSpacing.md)
            .background(
                item.isUrgent && !item.isCompleted
                    ? LadderColors.error.opacity(0.06)
                    : LadderColors.surfaceContainerLow
            )
            .overlay(
                item.isUrgent && !item.isCompleted
                    ? RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                        .stroke(LadderColors.error.opacity(0.3), lineWidth: 1)
                    : nil
            )
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

// MARK: - Post-Acceptance Models

enum PostAcceptanceCategory: String, CaseIterable {
    case enrollment = "Enrollment"
    case financial = "Financial Aid"
    case housing = "Housing"
    case health = "Health"
    case orientation = "Orientation"

    var icon: String {
        switch self {
        case .enrollment: return "building.columns.fill"
        case .financial:  return "banknote.fill"
        case .housing:    return "house.fill"
        case .health:     return "cross.fill"
        case .orientation: return "person.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .enrollment:  return LadderColors.primary
        case .financial:   return Color(red: 0.15, green: 0.50, blue: 0.35)
        case .housing:     return Color(red: 0.55, green: 0.30, blue: 0.10)
        case .health:      return Color(red: 0.15, green: 0.35, blue: 0.55)
        case .orientation: return Color(red: 0.50, green: 0.20, blue: 0.45)
        }
    }
}

struct PostAcceptanceItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let dueDate: String?
    let category: PostAcceptanceCategory
    let isUrgent: Bool
    var isCompleted: Bool

    static var sampleItems: [PostAcceptanceItem] {
        [
            // Enrollment
            PostAcceptanceItem(title: "Pay Enrollment Deposit", detail: "Non-refundable deposit secures your spot. Usually $200–$500.", dueDate: "May 1", category: .enrollment, isUrgent: true, isCompleted: false),
            PostAcceptanceItem(title: "Submit Enrollment Intent Form", detail: "Complete the online enrollment form on the student portal.", dueDate: "May 1", category: .enrollment, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Send Official Final Transcript", detail: "Request your high school to send your final transcript after graduation.", dueDate: "July 15", category: .enrollment, isUrgent: false, isCompleted: false),

            // Financial
            PostAcceptanceItem(title: "Accept or Decline Financial Aid", detail: "Log into the student portal and review your award letter. Accept loans selectively.", dueDate: "April 15", category: .financial, isUrgent: true, isCompleted: false),
            PostAcceptanceItem(title: "Complete FAFSA Verification", detail: "If selected, submit all requested documents within 2 weeks.", dueDate: "May 15", category: .financial, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Apply for Outside Scholarships", detail: "Keep applying — external scholarships can reduce loan burden.", dueDate: "Ongoing", category: .financial, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Health Insurance Waiver or Enrollment", detail: "Waive if covered by parent's plan, or enroll in student plan.", dueDate: "August 1", category: .financial, isUrgent: false, isCompleted: false),

            // Housing
            PostAcceptanceItem(title: "Apply for On-Campus Housing", detail: "Housing spots fill up fast — apply as soon as the portal opens!", dueDate: "May 1", category: .housing, isUrgent: true, isCompleted: false),
            PostAcceptanceItem(title: "Complete Roommate Questionnaire", detail: "Fill out housing preferences for roommate matching if required.", dueDate: "May 15", category: .housing, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Pay Housing Deposit", detail: "Separate from enrollment deposit. Check if combined.", dueDate: "May 15", category: .housing, isUrgent: false, isCompleted: false),

            // Health
            PostAcceptanceItem(title: "Submit Immunization Records", detail: "Most schools require MMR, meningococcal, and COVID vaccination records.", dueDate: "July 1", category: .health, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Complete Student Health Form", detail: "Medical history and emergency contact form on the student health portal.", dueDate: "July 15", category: .health, isUrgent: false, isCompleted: false),

            // Orientation
            PostAcceptanceItem(title: "Register for Orientation", detail: "Orientation slots are limited — register as soon as dates open.", dueDate: "June 1", category: .orientation, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Take Placement Tests", detail: "Math and foreign language placement tests are often required before orientation.", dueDate: "Before orientation", category: .orientation, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Set Up Student Email & Portal", detail: "Activate your student email and access the learning management system.", dueDate: "After enrollment", category: .orientation, isUrgent: false, isCompleted: false),
            PostAcceptanceItem(title: "Register for Fall Classes", detail: "Meet with your academic advisor and register for your first semester.", dueDate: "At orientation", category: .orientation, isUrgent: false, isCompleted: false),
        ]
    }
}

#Preview {
    NavigationStack {
        ApplicationDetailView(applicationId: "uf")
            .environment(AppCoordinator())
    }
}
