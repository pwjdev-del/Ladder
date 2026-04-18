import SwiftUI
import SwiftData

// MARK: - Admission Checklist View
// Pre-admission and post-admission checklists with persistent checkbox state

struct AdmissionChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let collegeId: String

    @State private var college: CollegeModel?
    @State private var preAdmissionItems: [AdmissionCheckItem] = []
    @State private var postAdmissionItems: [AdmissionCheckItem] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 40))
                            .foregroundStyle(LadderColors.primary)
                        Text(college?.name ?? "Admission Checklist")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .multilineTextAlignment(.center)
                        Text("Track every step from application to enrollment")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LadderSpacing.lg)

                    // Overall progress
                    overallProgressCard

                    // Pre-Admission Section
                    sectionHeader(title: "BEFORE YOU APPLY", icon: "doc.text", count: preAdmissionItems.filter(\.isCompleted).count, total: preAdmissionItems.count)

                    ForEach(Array(preAdmissionItems.enumerated()), id: \.element.id) { index, item in
                        checklistItemCard(item: item) {
                            preAdmissionItems[index].isCompleted.toggle()
                            saveCheckState(key: item.storageKey, value: preAdmissionItems[index].isCompleted)
                        }
                    }

                    // Post-Admission Section
                    sectionHeader(title: "AFTER YOU'RE ACCEPTED", icon: "party.popper", count: postAdmissionItems.filter(\.isCompleted).count, total: postAdmissionItems.count)

                    ForEach(Array(postAdmissionItems.enumerated()), id: \.element.id) { index, item in
                        checklistItemCard(item: item) {
                            postAdmissionItems[index].isCompleted.toggle()
                            saveCheckState(key: item.storageKey, value: postAdmissionItems[index].isCompleted)
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
                Text("Admission Checklist")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task { loadChecklist() }
    }

    // MARK: - Overall Progress Card

    private var overallProgressCard: some View {
        let allItems = preAdmissionItems + postAdmissionItems
        let completed = allItems.filter(\.isCompleted).count
        let total = allItems.count
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    Text("\(completed) of \(total) completed")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: LadderRadius.sm)
                            .fill(LadderColors.surfaceContainerHighest)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: LadderRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [LadderColors.primary, LadderColors.accentLime],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, icon: String, count: Int, total: Int) -> some View {
        HStack {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.primary)
                Text(title)
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
            }
            Spacer()
            Text("\(count)/\(total)")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.primary)
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xxs)
                .background(LadderColors.primaryContainer.opacity(0.3))
                .clipShape(Capsule())
        }
        .padding(.top, LadderSpacing.sm)
    }

    // MARK: - Checklist Item Card

    private func checklistItemCard(item: AdmissionCheckItem, onToggle: @escaping () -> Void) -> some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                Button(action: onToggle) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(item.isCompleted ? LadderColors.primary : LadderColors.outlineVariant)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
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
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(deadline)
                                .font(LadderTypography.labelSmall)
                        }
                        .foregroundStyle(LadderColors.primary)
                    }
                }

                Spacer()

                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(LadderColors.primaryContainer)
            }
        }
    }

    // MARK: - Load Checklist

    private func loadChecklist() {
        let descriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(descriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId || $0.name == collegeId }
        }
        guard let c = college else { return }

        buildPreAdmissionItems(c)
        buildPostAdmissionItems(c)
    }

    private func buildPreAdmissionItems(_ c: CollegeModel) {
        var items: [AdmissionCheckItem] = []

        // Submit application (deadline from CollegeDeadlineModel)
        let deadlineStr: String? = c.deadlines.first.map { deadline in
            if let date = deadline.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "\(deadline.deadlineType): \(formatter.string(from: date))"
            }
            return deadline.deadlineType
        }
        items.append(AdmissionCheckItem(
            title: "Submit Application",
            detail: c.deadlines.first?.applicationPlatforms.joined(separator: ", "),
            deadline: deadlineStr,
            icon: "paperplane",
            storageKey: storageKey(for: "submit_app"),
            isCompleted: loadCheckState(key: storageKey(for: "submit_app"))
        ))

        // Send test scores (if not test-optional)
        let testPolicy = c.personality?.testPolicy ?? c.testingPolicy
        let isTestOptional = testPolicy?.lowercased().contains("optional") == true || testPolicy?.lowercased().contains("blind") == true
        items.append(AdmissionCheckItem(
            title: "Send Test Scores",
            detail: isTestOptional ? "Test-optional — sending scores is not required" : "Send official SAT/ACT scores",
            deadline: nil,
            icon: "doc.badge.arrow.up",
            storageKey: storageKey(for: "test_scores"),
            isCompleted: loadCheckState(key: storageKey(for: "test_scores"))
        ))

        // Submit transcript
        let transcriptDetail = c.transcriptMethod ?? "Send official high school transcript"
        items.append(AdmissionCheckItem(
            title: "Submit Transcript",
            detail: transcriptDetail,
            deadline: nil,
            icon: "doc.text",
            storageKey: storageKey(for: "transcript"),
            isCompleted: loadCheckState(key: storageKey(for: "transcript"))
        ))

        // Supplemental essays
        if let essayCount = c.supplementalEssaysCount {
            items.append(AdmissionCheckItem(
                title: "Write Supplemental Essays",
                detail: "\(essayCount) supplemental essay(s) required",
                deadline: nil,
                icon: "pencil.line",
                storageKey: storageKey(for: "essays"),
                isCompleted: loadCheckState(key: storageKey(for: "essays"))
            ))
        }

        // Recommendation letters
        if let recs = c.recommendationLetters {
            items.append(AdmissionCheckItem(
                title: "Request Recommendation Letters",
                detail: recs,
                deadline: nil,
                icon: "envelope.open",
                storageKey: storageKey(for: "recs"),
                isCompleted: loadCheckState(key: storageKey(for: "recs"))
            ))
        }

        // CSS Profile
        if let css = c.cssProfileRequired, css.lowercased().contains("yes") || css.lowercased().contains("required") {
            items.append(AdmissionCheckItem(
                title: "Complete CSS Profile",
                detail: "Required for financial aid consideration",
                deadline: nil,
                icon: "creditcard",
                storageKey: storageKey(for: "css"),
                isCompleted: loadCheckState(key: storageKey(for: "css"))
            ))
        }

        // FAFSA
        items.append(AdmissionCheckItem(
            title: "Send FAFSA",
            detail: c.faPriorityDeadline.map { "Priority deadline: \($0)" } ?? "Submit the Free Application for Federal Student Aid",
            deadline: c.faPriorityDeadline,
            icon: "banknote",
            storageKey: storageKey(for: "fafsa"),
            isCompleted: loadCheckState(key: storageKey(for: "fafsa"))
        ))

        // Application fee
        if let fee = c.applicationFee {
            let waiver = c.feeWaiverAvailable ?? ""
            items.append(AdmissionCheckItem(
                title: "Pay Application Fee",
                detail: "\(fee)\(waiver.isEmpty ? "" : " — Fee waiver: \(waiver)")",
                deadline: nil,
                icon: "dollarsign.circle",
                storageKey: storageKey(for: "app_fee"),
                isCompleted: loadCheckState(key: storageKey(for: "app_fee"))
            ))
        }

        preAdmissionItems = items
    }

    private func buildPostAdmissionItems(_ c: CollegeModel) {
        var items: [AdmissionCheckItem] = []

        // Enrollment deposit
        items.append(AdmissionCheckItem(
            title: "Pay Enrollment Deposit",
            detail: c.enrollmentDeposit,
            deadline: c.depositDeadline,
            icon: "dollarsign.circle",
            storageKey: storageKey(for: "enroll_deposit"),
            isCompleted: loadCheckState(key: storageKey(for: "enroll_deposit"))
        ))

        // Housing deposit
        if c.housingDeposit != nil || c.housingDeadline != nil {
            items.append(AdmissionCheckItem(
                title: "Pay Housing Deposit",
                detail: c.housingDeposit,
                deadline: c.housingDeadline,
                icon: "house",
                storageKey: storageKey(for: "housing_deposit"),
                isCompleted: loadCheckState(key: storageKey(for: "housing_deposit"))
            ))
        }

        // Orientation
        if let orientation = c.orientationRequired {
            items.append(AdmissionCheckItem(
                title: "Complete Orientation",
                detail: "Required: \(orientation)\(c.orientationCost.map { " — Cost: \($0)" } ?? "")",
                deadline: nil,
                icon: "person.3",
                storageKey: storageKey(for: "orientation"),
                isCompleted: loadCheckState(key: storageKey(for: "orientation"))
            ))
        }

        // Immunization records
        if let immunizations = c.immunizationsRequired, !immunizations.contains("UNVERIFIED") {
            items.append(AdmissionCheckItem(
                title: "Submit Immunization Records",
                detail: immunizations,
                deadline: nil,
                icon: "cross.case",
                storageKey: storageKey(for: "immunizations"),
                isCompleted: loadCheckState(key: storageKey(for: "immunizations"))
            ))
        }

        // Placement tests
        if let placement = c.placementTests, !placement.contains("UNVERIFIED") {
            items.append(AdmissionCheckItem(
                title: "Take Placement Tests",
                detail: placement,
                deadline: "Before orientation",
                icon: "doc.text.magnifyingglass",
                storageKey: storageKey(for: "placement"),
                isCompleted: loadCheckState(key: storageKey(for: "placement"))
            ))
        }

        // Final transcript
        items.append(AdmissionCheckItem(
            title: "Send Final Transcript",
            detail: "Submit after graduation",
            deadline: "July 1 (typical)",
            icon: "doc",
            storageKey: storageKey(for: "final_transcript"),
            isCompleted: loadCheckState(key: storageKey(for: "final_transcript"))
        ))

        // Set up student portal
        items.append(AdmissionCheckItem(
            title: "Set Up Student Portal",
            detail: "Activate email and student ID",
            deadline: nil,
            icon: "laptopcomputer",
            storageKey: storageKey(for: "portal"),
            isCompleted: loadCheckState(key: storageKey(for: "portal"))
        ))

        postAdmissionItems = items
    }

    // MARK: - Persistence Helpers

    private func storageKey(for item: String) -> String {
        "admissionChecklist_\(collegeId)_\(item)"
    }

    private func loadCheckState(key: String) -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    private func saveCheckState(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

// MARK: - Admission Check Item

struct AdmissionCheckItem: Identifiable {
    let id = UUID()
    var title: String
    var detail: String?
    var deadline: String?
    var icon: String
    var storageKey: String
    var isCompleted: Bool
}
