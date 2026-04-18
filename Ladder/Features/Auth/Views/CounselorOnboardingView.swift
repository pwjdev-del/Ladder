import SwiftUI

// MARK: - Counselor Onboarding View
// Counselor enters a school code to join, or opts for independent counselor flow

struct CounselorOnboardingView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var schoolCodeManager = SchoolCodeManager()
    @State private var code = ""
    @State private var isIndependent = false
    @State private var joinState: JoinState = .entering

    enum JoinState {
        case entering
        case validating
        case confirmed(schoolName: String)
        case joined
        case error(String)
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.xl) {
                    Spacer().frame(height: LadderSpacing.lg)

                    // MARK: - Header
                    headerSection

                    // MARK: - Content
                    if isIndependent {
                        independentSection
                    } else {
                        switch joinState {
                        case .entering, .error:
                            codeEntrySection
                        case .validating:
                            loadingSection
                        case .confirmed(let schoolName):
                            confirmSection(schoolName: schoolName)
                        case .joined:
                            successSection
                        }
                    }

                    // MARK: - Independent Toggle
                    if case .entering = joinState {
                        independentToggle
                    }
                    if case .error = joinState {
                        independentToggle
                    }
                }
                .padding(LadderSpacing.lg)
            }
        }
        .navigationTitle("Counselor Setup")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "person.badge.shield.checkmark.fill")
                .font(.system(size: 48))
                .foregroundStyle(LadderColors.primary)

            Text(isIndependent ? "Independent Counselor" : "Join Your School")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)
                .multilineTextAlignment(.center)

            Text(isIndependent
                 ? "Set up your independent counseling practice on Ladder."
                 : "Enter the school code provided by your school administrator."
            )
            .font(LadderTypography.bodyLarge)
            .foregroundStyle(LadderColors.onSurfaceVariant)
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - Code Entry

    private var codeEntrySection: some View {
        VStack(spacing: LadderSpacing.xl) {
            LadderCard {
                VStack(spacing: LadderSpacing.lg) {
                    LadderTextField("School code (e.g., PNCV-2026)", text: $code, icon: "building.2")
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    if case .error(let message) = joinState {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                            Text(message)
                                .font(LadderTypography.bodySmall)
                        }
                        .foregroundStyle(LadderColors.error)
                    }
                }
            }

            LadderPrimaryButton("Join", icon: "arrow.right") {
                Task { await validateAndJoin() }
            }
            .opacity(code.count >= 6 ? 1.0 : 0.5)
            .allowsHitTesting(code.count >= 6)
        }
    }

    // MARK: - Loading

    private var loadingSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(LadderColors.primary)

            Text("Looking up your school...")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(.top, LadderSpacing.xxxl)
    }

    // MARK: - Confirm School

    private func confirmSection(schoolName: String) -> some View {
        VStack(spacing: LadderSpacing.xl) {
            LadderCard(elevated: true) {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(LadderColors.primary)

                    Text(schoolName)
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Is this your school?")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: LadderSpacing.md) {
                LadderSecondaryButton("No, Go Back") {
                    joinState = .entering
                    code = ""
                }

                LadderPrimaryButton("Yes, Join", icon: "checkmark") {
                    Task { await confirmJoin() }
                }
            }
        }
    }

    // MARK: - Success

    private var successSection: some View {
        VStack(spacing: LadderSpacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(LadderColors.primary)

            Text("You're In!")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)

            if let name = schoolCodeManager.schoolName {
                Text("You have joined \(name) as a counselor. You can now create and manage student accounts.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

            LadderPrimaryButton("Continue", icon: "arrow.right") {
                authManager.completeOnboarding()
                dismiss()
            }
        }
    }

    // MARK: - Independent Counselor

    private var independentToggle: some View {
        VStack(spacing: LadderSpacing.md) {
            // Tonal separator
            RoundedRectangle(cornerRadius: 1)
                .fill(LadderColors.surfaceContainerHighest)
                .frame(height: 2)
                .padding(.vertical, LadderSpacing.sm)

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isIndependent.toggle()
                }
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: isIndependent ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.primary)

                    Text("I'm an independent counselor")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Spacer()
                }
            }
        }
    }

    private var independentSection: some View {
        VStack(spacing: LadderSpacing.xl) {
            LadderCard {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 36))
                        .foregroundStyle(LadderColors.primary)

                    Text("Independent Practice")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("As an independent counselor, you can invite students directly using invite codes. You won't be affiliated with a specific school.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }

            LadderPrimaryButton("Continue as Independent", icon: "arrow.right") {
                authManager.completeOnboarding()
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func validateAndJoin() async {
        joinState = .validating

        let result = await schoolCodeManager.validateSchoolCode(code)
        if result.valid, let name = result.schoolName {
            schoolCodeManager.schoolName = name
            joinState = .confirmed(schoolName: name)
        } else {
            joinState = .error("School code not found. Please check with your administrator.")
        }
    }

    private func confirmJoin() async {
        joinState = .validating
        do {
            try await schoolCodeManager.joinSchool(code: code, role: "counselor")
            joinState = .joined
        } catch {
            joinState = .error("Failed to join school. Please try again.")
        }
    }
}

#Preview {
    NavigationStack {
        CounselorOnboardingView()
            .environment(AuthManager())
    }
}
