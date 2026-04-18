import SwiftUI

// MARK: - Force Password Change View
// First-login password change for auto-generated student accounts

struct ForcePasswordChangeView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.xl) {
                    Spacer().frame(height: LadderSpacing.xl)

                    // MARK: - Logo
                    Image("LadderLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .ladderShadow(LadderElevation.ambient)

                    // MARK: - Welcome Text
                    VStack(spacing: LadderSpacing.sm) {
                        Text("Welcome to Ladder!")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .editorialTracking()

                        Text("Your counselor created your account. Please set a new password to continue.")
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }

                    // MARK: - Password Fields
                    LadderCard {
                        VStack(spacing: LadderSpacing.lg) {
                            LadderSecureField("Current password", text: $currentPassword, icon: "lock")

                            LadderSecureField("New password", text: $newPassword, icon: "lock.rotation")

                            // Password strength meter
                            passwordStrengthMeter

                            // Requirements
                            passwordRequirements

                            LadderSecureField("Confirm new password", text: $confirmPassword, icon: "lock.fill")
                        }
                    }

                    // MARK: - Error
                    if let error = errorMessage {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                            Text(error)
                                .font(LadderTypography.bodySmall)
                        }
                        .foregroundStyle(LadderColors.error)
                    }

                    // MARK: - Submit
                    LadderPrimaryButton("Set Password & Continue", icon: "arrow.right") {
                        Task { await changePassword() }
                    }
                    .opacity(canSubmit ? 1.0 : 0.5)
                    .allowsHitTesting(canSubmit)

                    if isSubmitting {
                        ProgressView()
                            .tint(LadderColors.primary)
                    }

                    Spacer().frame(height: LadderSpacing.xl)
                }
                .padding(LadderSpacing.lg)
            }
        }
    }

    // MARK: - Password Strength

    private var passwordStrength: PasswordStrength {
        PasswordStrength.evaluate(newPassword)
    }

    private var passwordStrengthMeter: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            HStack {
                Text("Password strength")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                Spacer()

                Text(passwordStrength.label)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(passwordStrength.color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: LadderRadius.sm)
                        .fill(LadderColors.surfaceContainerHighest)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: LadderRadius.sm)
                        .fill(passwordStrength.color)
                        .frame(width: geometry.size.width * passwordStrength.progress, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: passwordStrength)
                }
            }
            .frame(height: 6)
        }
    }

    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            requirementRow("At least 8 characters", met: newPassword.count >= 8)
            requirementRow("One uppercase letter", met: newPassword.range(of: "[A-Z]", options: .regularExpression) != nil)
            requirementRow("One number", met: newPassword.range(of: "[0-9]", options: .regularExpression) != nil)
        }
    }

    private func requirementRow(_ text: String, met: Bool) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundStyle(met ? LadderColors.primary : LadderColors.onSurfaceVariant)

            Text(text)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(met ? LadderColors.onSurface : LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Validation

    private var canSubmit: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword.range(of: "[A-Z]", options: .regularExpression) != nil &&
        newPassword.range(of: "[0-9]", options: .regularExpression) != nil &&
        newPassword == confirmPassword &&
        !isSubmitting
    }

    // MARK: - Actions

    private func changePassword() async {
        errorMessage = nil

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        // TODO: Call AWS Cognito / backend to change password
        try? await Task.sleep(for: .seconds(1))

        // On success, proceed to normal student onboarding
        authManager.completeOnboarding()
    }
}

// MARK: - Password Strength Model

private enum PasswordStrength: Equatable {
    case empty
    case weak
    case medium
    case strong

    var label: String {
        switch self {
        case .empty: return ""
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .empty: return LadderColors.surfaceContainerHighest
        case .weak: return LadderColors.error
        case .medium: return LadderColors.tertiary
        case .strong: return LadderColors.primary
        }
    }

    var progress: CGFloat {
        switch self {
        case .empty: return 0
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }

    static func evaluate(_ password: String) -> PasswordStrength {
        guard !password.isEmpty else { return .empty }

        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }

        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
}

//#Preview {
//    ForcePasswordChangeView()
//        .environment(AuthManager())
//}
