import SwiftUI

// MARK: - FAFSA Guide View

struct FAFSAGuideView: View {
    @Environment(\.dismiss) private var dismiss

    // Persist checklist state across navigation using AppStorage
    @AppStorage("fafsa_step_0") private var step0Complete = false
    @AppStorage("fafsa_step_1") private var step1Complete = false
    @AppStorage("fafsa_step_2") private var step2Complete = false
    @AppStorage("fafsa_step_3") private var step3Complete = false
    @AppStorage("fafsa_step_4") private var step4Complete = false
    @AppStorage("fafsa_step_5") private var step5Complete = false

    private var completedSteps: Set<Int> {
        var set = Set<Int>()
        if step0Complete { set.insert(0) }
        if step1Complete { set.insert(1) }
        if step2Complete { set.insert(2) }
        if step3Complete { set.insert(3) }
        if step4Complete { set.insert(4) }
        if step5Complete { set.insert(5) }
        return set
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

    private let steps: [(title: String, detail: String, icon: String)] = [
        ("Create an FSA ID", "Both student and one parent need an FSA ID at studentaid.gov. This takes 1-3 days to process.", "person.badge.key"),
        ("Gather Documents", "You'll need: SSN, federal tax returns, W-2s, bank statements, investment records, and records of untaxed income.", "doc.text"),
        ("Start the Application", "Go to studentaid.gov/h/apply-for-aid/fafsa. Use the IRS Data Retrieval Tool to auto-fill tax info.", "globe"),
        ("Add School Codes", "Enter the Federal School Code for each college you're applying to. You can add up to 20 schools.", "building.columns"),
        ("Review & Submit", "Double-check all information. Both student and parent must sign electronically using FSA IDs.", "checkmark.shield"),
        ("Check Your SAR", "Your Student Aid Report will be available 3-5 days after submission. Review for errors.", "doc.richtext"),
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(LadderColors.primary)
                        Text("FAFSA Guide")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Free Application for Federal Student Aid")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(.top, LadderSpacing.lg)

                    // Key info card
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Label("Opens October 1 each year", systemImage: "calendar")
                            Label("~36 questions (simplified from 100+)", systemImage: "list.bullet")
                            Label("EFC replaced by SAI (Student Aid Index)", systemImage: "dollarsign.circle")
                            Label("Free to file — never pay for FAFSA", systemImage: "checkmark.circle")
                        }
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurface)
                    }

                    // Steps
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        LadderCard {
                            HStack(alignment: .top, spacing: LadderSpacing.md) {
                                Button {
                                    toggleStep(index)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(isStepComplete(index) ? LadderColors.primary : LadderColors.surfaceContainerLow)
                                            .frame(width: 36, height: 36)
                                        if isStepComplete(index) {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        } else {
                                            Text("\(index + 1)")
                                                .font(LadderTypography.labelMedium)
                                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                        }
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .strikethrough(isStepComplete(index))
                                    Text(step.detail)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
                        }
                    }

                    // Progress
                    let progress = Double(completedSteps.count) / Double(steps.count)
                    LadderCard {
                        VStack(spacing: LadderSpacing.sm) {
                            Text("\(completedSteps.count)/\(steps.count) steps complete")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.primary)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(LadderColors.surfaceContainerLow)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(LadderColors.primary)
                                        .frame(width: geo.size.width * progress)
                                        .animation(.easeInOut, value: progress)
                                }
                            }
                            .frame(height: 8)
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
    }
}
