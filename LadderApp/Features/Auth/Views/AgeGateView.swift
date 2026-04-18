import SwiftUI

// MARK: - Age Gate View
// COPPA compliance — verifies user is 13+ before onboarding
// If under 13, requires parental consent via email

struct AgeGateView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedYear: Int = 2008
    @State private var hasSubmitted = false
    @State private var parentEmail = ""
    @State private var permissionSent = false

    var onAgeVerified: (() -> Void)?

    private let yearRange = Array(2000...2014)

    private var calculatedAge: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - selectedYear
    }

    private var isOldEnough: Bool {
        calculatedAge >= 13
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: LadderSpacing.xl) {
                Spacer().frame(height: LadderSpacing.lg)

                // Header
                VStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 44))
                        .foregroundStyle(LadderColors.primary)

                    Text("Age Verification")
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("We need to verify your age to comply with federal privacy laws.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, LadderSpacing.lg)

                if !hasSubmitted {
                    yearPickerSection
                } else if isOldEnough {
                    verifiedSection
                } else if permissionSent {
                    permissionSentSection
                } else {
                    parentConsentSection
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Year Picker

    private var yearPickerSection: some View {
        VStack(spacing: LadderSpacing.xl) {
            VStack(spacing: LadderSpacing.sm) {
                Text("What year were you born?")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Picker("Birth Year", selection: $selectedYear) {
                    ForEach(yearRange, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
            .padding(LadderSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: LadderRadius.lg)
                    .fill(LadderColors.surfaceContainerLow)
            )
            .padding(.horizontal, LadderSpacing.lg)

            LadderPrimaryButton("Continue", icon: "arrow.right") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    hasSubmitted = true
                    if isOldEnough {
                        UserDefaults.standard.set(true, forKey: "age_verified")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onAgeVerified?()
                        }
                    }
                }
            }
            .padding(.horizontal, LadderSpacing.lg)
        }
    }

    // MARK: - Verified Section

    private var verifiedSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(LadderColors.primary)

            Text("You're all set!")
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)

            Text("Age verified. Taking you to onboarding...")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.lg)
                .fill(LadderColors.surfaceContainerLow)
        )
        .padding(.horizontal, LadderSpacing.lg)
    }

    // MARK: - Parent Consent Section

    private var parentConsentSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            Image(systemName: "figure.and.child.holdinghands")
                .font(.system(size: 44))
                .foregroundStyle(LadderColors.primary)

            Text("You need a parent's permission to use Ladder")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
                .multilineTextAlignment(.center)

            Text("Enter your parent or guardian's email address and we'll send them a permission request.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            LadderTextField("Parent's Email", text: $parentEmail, icon: "envelope")

            LadderPrimaryButton("Send Permission Request", icon: "paperplane") {
                // TODO: Send actual parental consent email
                withAnimation(.easeInOut(duration: 0.3)) {
                    permissionSent = true
                }
            }
            .disabled(parentEmail.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(parentEmail.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
        }
        .padding(LadderSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.lg)
                .fill(LadderColors.surfaceContainerLow)
        )
        .padding(.horizontal, LadderSpacing.lg)
    }

    // MARK: - Permission Sent Section

    private var permissionSentSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 44))
                .foregroundStyle(LadderColors.primary)

            Text("Permission Request Sent")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("We'll email your parent at \(parentEmail) to verify your account. You'll be able to use Ladder once they approve.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            LadderPrimaryButton("Done", icon: "checkmark") {
                dismiss()
            }
        }
        .padding(LadderSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.lg)
                .fill(LadderColors.surfaceContainerLow)
        )
        .padding(.horizontal, LadderSpacing.lg)
    }
}

#Preview {
    AgeGateView()
}
