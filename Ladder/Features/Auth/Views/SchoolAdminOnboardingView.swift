import SwiftUI

// MARK: - School Admin Onboarding View
// School admin creates their school profile and generates a school code

struct SchoolAdminOnboardingView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var schoolCodeManager = SchoolCodeManager()
    @State private var currentStep = 1

    // Step 1 fields
    @State private var schoolName = ""
    @State private var districtName = ""
    @State private var ncesId = ""
    @State private var address = ""

    // Step 2
    @State private var copiedToClipboard = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.xl) {
                    // Step indicator
                    stepIndicator

                    switch currentStep {
                    case 1:
                        schoolInfoStep
                    case 2:
                        schoolCodeStep
                    case 3:
                        shareInstructionsStep
                    default:
                        EmptyView()
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.top, LadderSpacing.md)
            }
        }
        .navigationTitle("School Setup")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: LadderSpacing.sm) {
            ForEach(1...3, id: \.self) { step in
                HStack(spacing: LadderSpacing.xs) {
                    Circle()
                        .fill(step <= currentStep ? LadderColors.primary : LadderColors.surfaceContainerHighest)
                        .frame(width: 32, height: 32)
                        .overlay {
                            if step < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(step)")
                                    .font(LadderTypography.labelLarge)
                                    .foregroundStyle(step == currentStep ? .white : LadderColors.onSurfaceVariant)
                            }
                        }

                    if step < 3 {
                        Rectangle()
                            .fill(step < currentStep ? LadderColors.primary : LadderColors.surfaceContainerHighest)
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.lg)
    }

    // MARK: - Step 1: School Info

    private var schoolInfoStep: some View {
        VStack(spacing: LadderSpacing.xl) {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.primary)

                Text("School Information")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Tell us about your school to get started.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

            LadderCard {
                VStack(spacing: LadderSpacing.lg) {
                    LadderTextField("School name", text: $schoolName, icon: "building.2")
                    LadderTextField("District name", text: $districtName, icon: "map")
                    LadderTextField("NCES ID (optional)", text: $ncesId, icon: "number")
                    LadderTextField("Address", text: $address, icon: "mappin.and.ellipse")
                }
            }

            LadderPrimaryButton("Continue", icon: "arrow.right") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    _ = schoolCodeManager.generateSchoolCode(schoolName: schoolName)
                    currentStep = 2
                }
            }
            .opacity(schoolName.isEmpty || districtName.isEmpty ? 0.5 : 1.0)
            .allowsHitTesting(!schoolName.isEmpty && !districtName.isEmpty)
        }
    }

    // MARK: - Step 2: School Code

    private var schoolCodeStep: some View {
        VStack(spacing: LadderSpacing.xl) {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "qrcode")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.primary)

                Text("Your School Code")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text("This is your unique school code. Counselors and students will use it to join your school on Ladder.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

            if let code = schoolCodeManager.schoolCode {
                LadderCard(elevated: true) {
                    VStack(spacing: LadderSpacing.md) {
                        Text(code)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(LadderColors.primary)
                            .tracking(4)

                        Text(schoolName)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        Button {
                            UIPasteboard.general.string = code
                            copiedToClipboard = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copiedToClipboard = false
                            }
                        } label: {
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(copiedToClipboard ? "Copied" : "Copy Code")
                                    .font(LadderTypography.labelLarge)
                            }
                            .foregroundStyle(LadderColors.primary)
                            .padding(.horizontal, LadderSpacing.lg)
                            .padding(.vertical, LadderSpacing.md)
                            .background(LadderColors.surfaceContainerHigh)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            LadderPrimaryButton("Continue", icon: "arrow.right") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = 3
                }
            }
        }
    }

    // MARK: - Step 3: Share Instructions

    private var shareInstructionsStep: some View {
        VStack(spacing: LadderSpacing.xl) {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.primary)

                Text("Share with Your Counselors")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }

            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                shareStep(
                    icon: "1.circle.fill",
                    title: "Share the school code",
                    description: "Send the code \(schoolCodeManager.schoolCode ?? "") to your guidance counselors via email or in person."
                )

                shareStep(
                    icon: "2.circle.fill",
                    title: "Counselors download Ladder",
                    description: "Each counselor downloads the Ladder app and selects \"I am a Counselor\" during setup."
                )

                shareStep(
                    icon: "3.circle.fill",
                    title: "Counselors enter the code",
                    description: "They enter the school code to join your school and can start creating student accounts."
                )
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

            LadderPrimaryButton("Complete Setup", icon: "checkmark") {
                authManager.completeOnboarding()
                dismiss()
            }
        }
    }

    private func shareStep(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(LadderColors.primary)

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(title)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text(description)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SchoolAdminOnboardingView()
            .environment(AuthManager())
    }
}
