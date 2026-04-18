import SwiftUI
import SwiftData

// MARK: - CSS Profile Guide View
// Step-by-step CSS Profile guide with college requirements and document checklist

struct CSSProfileGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Persist step checklist via AppStorage
    @AppStorage("css_step_0") private var step0Complete = false
    @AppStorage("css_step_1") private var step1Complete = false
    @AppStorage("css_step_2") private var step2Complete = false
    @AppStorage("css_step_3") private var step3Complete = false
    @AppStorage("css_step_4") private var step4Complete = false
    @AppStorage("css_step_5") private var step5Complete = false

    // Persist document checklist via AppStorage
    @AppStorage("css_doc_federal_tax") private var docFederalTax = false
    @AppStorage("css_doc_w2") private var docW2 = false
    @AppStorage("css_doc_bank") private var docBank = false
    @AppStorage("css_doc_investment") private var docInvestment = false
    @AppStorage("css_doc_business") private var docBusiness = false
    @AppStorage("css_doc_untaxed") private var docUntaxed = false
    @AppStorage("css_doc_ssn") private var docSSN = false

    // Query student's saved college IDs
    @Query var studentProfiles: [StudentProfileModel]

    // Query all colleges from SwiftData
    @Query var allColleges: [CollegeModel]

    /// Colleges the student saved that require CSS Profile
    private var cssColleges: [CollegeModel] {
        let savedIds = studentProfiles.first?.savedCollegeIds ?? []
        let cssRequiredColleges = allColleges.filter { college in
            guard let cssField = college.cssProfileRequired?.lowercased() else { return false }
            return cssField.contains("yes") || cssField.contains("required") || cssField == "true"
        }
        if savedIds.isEmpty {
            // No saved colleges — show all CSS-requiring colleges
            return cssRequiredColleges
        }
        // Filter to only the student's saved colleges
        let savedSet = Set(savedIds)
        let filtered = cssRequiredColleges.filter { college in
            if let sid = college.supabaseId { return savedSet.contains(sid) }
            if let scid = college.scorecardId { return savedSet.contains(String(scid)) }
            return false
        }
        return filtered
    }

    private var hasSavedColleges: Bool {
        !(studentProfiles.first?.savedCollegeIds ?? []).isEmpty
    }

    private var completedStepCount: Int {
        [step0Complete, step1Complete, step2Complete, step3Complete, step4Complete, step5Complete]
            .filter { $0 }.count
    }

    private func isStepComplete(_ index: Int) -> Bool {
        switch index {
        case 0: return step0Complete
        case 1: return step1Complete
        case 2: return step2Complete
        case 3: return step3Complete
        case 4: return step4Complete
        case 5: return step5Complete
        default: return false
        }
    }

    private func toggleStep(_ index: Int) {
        switch index {
        case 0: step0Complete.toggle()
        case 1: step1Complete.toggle()
        case 2: step2Complete.toggle()
        case 3: step3Complete.toggle()
        case 4: step4Complete.toggle()
        case 5: step5Complete.toggle()
        default: break
        }
    }

    private let steps: [(title: String, description: String, icon: String)] = [
        ("Create College Board Account", "Sign up at cssprofile.collegeboard.org with your College Board account (same as SAT).", "person.badge.plus"),
        ("Gather Financial Documents", "Collect tax returns, W-2s, bank statements, and investment records for both parents.", "doc.text"),
        ("Complete Parent Section", "A parent/guardian must fill out their income, assets, and household information.", "person.2"),
        ("Add Your Colleges", "Select which colleges should receive your CSS Profile. Check which schools require it below.", "building.columns"),
        ("Review & Submit", "Double-check all figures. One CSS Profile goes to all selected schools. Fee waivers available.", "checkmark.shield"),
        ("Submit Before Deadlines", "Most EA/ED schools need CSS by Nov 1. Regular Decision typically Feb 1. Check each school.", "calendar.badge.clock")
    ]

    private let requiredDocuments: [(name: String, icon: String, key: Int)] = [
        ("Federal tax return (1040)", "doc.text.fill", 0),
        ("W-2 forms (all jobs)", "doc.fill", 1),
        ("Bank statements", "banknote", 2),
        ("Investment account statements", "chart.line.uptrend.xyaxis", 3),
        ("Business/farm income records (if applicable)", "building.2", 4),
        ("Records of untaxed income", "dollarsign.circle", 5),
        ("Social Security numbers (student + parents)", "person.text.rectangle", 6)
    ]

    private func isDocComplete(_ key: Int) -> Bool {
        switch key {
        case 0: return docFederalTax
        case 1: return docW2
        case 2: return docBank
        case 3: return docInvestment
        case 4: return docBusiness
        case 5: return docUntaxed
        case 6: return docSSN
        default: return false
        }
    }

    private func toggleDoc(_ key: Int) {
        switch key {
        case 0: docFederalTax.toggle()
        case 1: docW2.toggle()
        case 2: docBank.toggle()
        case 3: docInvestment.toggle()
        case 4: docBusiness.toggle()
        case 5: docUntaxed.toggle()
        case 6: docSSN.toggle()
        default: break
        }
    }

    private var completedDocCount: Int {
        [docFederalTax, docW2, docBank, docInvestment, docBusiness, docUntaxed, docSSN]
            .filter { $0 }.count
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerSection
                    stepsSection
                    documentsChecklist
                    collegesSection
                    feeWaiverNote
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
                Text("CSS Profile Guide")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 64, height: 64)
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("CSS Profile")
                .font(LadderTypography.headlineLarge)
                .foregroundStyle(LadderColors.onSurface)
            Text("The CSS Profile is required by ~400 colleges for institutional financial aid. It's more detailed than FAFSA and helps schools determine need-based grants.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: LadderSpacing.sm) {
                LadderTagChip("$25 per school", icon: "dollarsign")
                LadderTagChip("Fee waivers available", icon: "checkmark.seal")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Steps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("STEP-BY-STEP GUIDE")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                let isComplete = isStepComplete(index)

                Button {
                    toggleStep(index)
                } label: {
                    HStack(alignment: .top, spacing: LadderSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(isComplete ? LadderColors.accentLime : LadderColors.primaryContainer.opacity(0.3))
                                .frame(width: 36, height: 36)
                            if isComplete {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(LadderColors.onSecondaryFixed)
                            } else {
                                Text("\(index + 1)")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.primary)
                            }
                        }

                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text(step.title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .strikethrough(isComplete, color: LadderColors.onSurfaceVariant)
                            Text(step.description)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(LadderSpacing.md)
                    .background(isComplete ? LadderColors.accentLime.opacity(0.08) : LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Documents Checklist

    private var documentsChecklist: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Document Checklist")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(requiredDocuments, id: \.name) { doc in
                    let isDone = isDocComplete(doc.key)
                    Button {
                        toggleDoc(doc.key)
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(isDone ? LadderColors.accentLime : LadderColors.outlineVariant)
                            Text(doc.name)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(isDone ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                                .strikethrough(isDone, color: LadderColors.onSurfaceVariant)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text("\(completedDocCount) of \(requiredDocuments.count) gathered")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
            }
        }
    }

    // MARK: - Colleges That Require CSS

    private var collegesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(hasSavedColleges ? "YOUR SAVED COLLEGES REQUIRING CSS" : "COLLEGES REQUIRING CSS PROFILE")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            if !hasSavedColleges && !cssColleges.isEmpty {
                Text("Showing all colleges requiring CSS Profile. Save colleges to your list to filter.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            if cssColleges.isEmpty {
                Text(hasSavedColleges
                     ? "None of your saved colleges require the CSS Profile."
                     : "No colleges requiring CSS Profile found. Add colleges to your list first.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(LadderSpacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))
            } else {
                ForEach(cssColleges, id: \.name) { college in
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.primary)
                            .frame(width: 40, height: 40)
                            .background(LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text(college.name)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            if let deadline = college.faPriorityDeadline {
                                Text(deadline)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(LadderColors.accentLime)
                            .font(.system(size: 16))
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
            }
        }
    }

    // MARK: - Fee Waiver Note

    private var feeWaiverNote: some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(LadderColors.primary)
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text("Fee Waiver Available")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text("If you receive a College Board SAT fee waiver, the CSS Profile application fee is automatically waived for up to 8 schools.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.primaryContainer.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        CSSProfileGuideView()
    }
}
