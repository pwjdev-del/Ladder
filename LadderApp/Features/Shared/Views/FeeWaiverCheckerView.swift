import SwiftUI

// MARK: - Fee Waiver Checker View
// Questionnaire to determine fee waiver eligibility

struct FeeWaiverCheckerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var freeReducedLunch = false
    @State private var familyIncome: String = ""
    @State private var householdSize: String = ""
    @State private var isFirstGen = false
    @State private var isFosterYouth = false
    @State private var isHomeless = false
    @State private var receivesPublicAssistance = false
    @State private var showResults = false

    private var eligibleWaivers: [WaiverResult] {
        var results: [WaiverResult] = []

        // College Board fee waiver (SAT, AP, CSS Profile)
        if freeReducedLunch || receivesPublicAssistance || isFosterYouth || isHomeless || incomeEligible {
            results.append(WaiverResult(
                name: "College Board Fee Waiver",
                description: "Covers 2 SAT attempts, unlimited SAT score sends, up to 4 college application fees, and CSS Profile fee",
                action: "Ask your school counselor to issue via College Board portal",
                icon: "doc.text.fill"
            ))
        }

        // NACAC fee waiver
        if freeReducedLunch || isFirstGen || isFosterYouth || incomeEligible {
            results.append(WaiverResult(
                name: "NACAC Application Fee Waiver",
                description: "Accepted by 1,000+ colleges for application fee waivers",
                action: "Download from NACAC website or request from counselor",
                icon: "building.columns.fill"
            ))
        }

        // Common App fee waiver
        if freeReducedLunch || receivesPublicAssistance || isFirstGen || incomeEligible {
            results.append(WaiverResult(
                name: "Common App Fee Waiver",
                description: "Automatically applied when you indicate eligibility in Common App profile",
                action: "Select fee waiver indicator in Common App settings",
                icon: "app.fill"
            ))
        }

        // AP exam fee reduction
        if freeReducedLunch || incomeEligible {
            results.append(WaiverResult(
                name: "AP Exam Fee Reduction",
                description: "Reduces AP exam cost from $98 to $53 per exam (College Board) plus possible state subsidies",
                action: "Notify counselor before AP exam registration deadline",
                icon: "graduationcap.fill"
            ))
        }

        // FAFSA (everyone)
        results.append(WaiverResult(
            name: "FAFSA (Free Application)",
            description: "Always free to submit. Opens October 1. Required for federal grants, loans, and most institutional aid.",
            action: "Complete at studentaid.gov starting October 1",
            icon: "dollarsign.circle.fill"
        ))

        return results
    }

    private var incomeEligible: Bool {
        guard let income = Int(familyIncome), let size = Int(householdSize), size > 0 else { return false }
        // Simplified federal poverty guideline check (150% FPL for 2025)
        let thresholds: [Int: Int] = [1: 22_590, 2: 30_660, 3: 38_730, 4: 46_800, 5: 54_870, 6: 62_940, 7: 71_010, 8: 79_080]
        let threshold = thresholds[min(size, 8)] ?? 79_080
        return income <= threshold
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    if showResults {
                        resultsView
                    } else {
                        questionnaireView
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
                Text("Fee Waiver Checker")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Questionnaire

    private var questionnaireView: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Check Your Eligibility")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Answer a few questions to find fee waivers you may qualify for.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    toggleRow("Do you receive free or reduced-price lunch?", isOn: $freeReducedLunch)
                    toggleRow("Are you a first-generation college student?", isOn: $isFirstGen)
                    toggleRow("Are you a foster youth or ward of the court?", isOn: $isFosterYouth)
                    toggleRow("Are you experiencing homelessness?", isOn: $isHomeless)
                    toggleRow("Does your family receive public assistance (TANF, SNAP, SSI)?", isOn: $receivesPublicAssistance)
                }
            }

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    Text("Household Information")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    LadderTextField("Annual family income ($)", text: $familyIncome, icon: "dollarsign")
                    LadderTextField("Household size", text: $householdSize, icon: "person.2")
                }
            }

            LadderPrimaryButton("Check Eligibility", icon: "checkmark.shield") {
                withAnimation(.spring(response: 0.4)) { showResults = true }
            }
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .tint(LadderColors.primary)
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(LadderColors.accentLime)
                        .font(.system(size: 24))
                    Text("Your Results")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                }
                Text("You may be eligible for \(eligibleWaivers.count) fee waiver\(eligibleWaivers.count == 1 ? "" : "s")")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            ForEach(eligibleWaivers) { waiver in
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: waiver.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(LadderColors.primary)
                                .frame(width: 40, height: 40)
                                .background(LadderColors.primaryContainer.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                            Text(waiver.name)
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                        Text(waiver.description)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(LadderColors.accentLime)
                            Text(waiver.action)
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }
                }
            }

            LadderCard {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.primary)
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("Talk to Your Counselor")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Your school counselor can verify eligibility and issue official fee waiver forms.")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }

            LadderSecondaryButton("Check Again") {
                withAnimation(.spring(response: 0.4)) { showResults = false }
            }
        }
    }
}

// MARK: - Waiver Result

private struct WaiverResult: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let action: String
    let icon: String
}

#Preview {
    NavigationStack {
        FeeWaiverCheckerView()
    }
}
