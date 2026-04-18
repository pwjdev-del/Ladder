import SwiftUI

// MARK: - Parent Onboarding View
// Parent enters an invite code to link to their child's account

struct ParentOnboardingView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var inviteManager = InviteCodeManager()
    @State private var code = ""
    @State private var linkState: LinkState = .entering

    enum LinkState {
        case entering
        case validating
        case success
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

                    // MARK: - Content based on state
                    switch linkState {
                    case .entering, .error:
                        codeEntrySection
                    case .validating:
                        loadingSection
                    case .success:
                        successSection
                    }
                }
                .padding(LadderSpacing.lg)
            }
        }
        .navigationTitle("Parent Setup")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "figure.and.child.holdinghands")
                .font(.system(size: 52))
                .foregroundStyle(LadderColors.primary)

            Text("Enter Your Child's Code")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)
                .multilineTextAlignment(.center)

            Text("Ask your child to generate an invite code from their Ladder app, then enter it below.")
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
                    LadderTextField("6-digit invite code", text: $code, icon: "key")
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: code) { _, newValue in
                            // Limit to 6 characters and uppercase
                            if newValue.count > 6 {
                                code = String(newValue.prefix(6))
                            }
                            code = code.uppercased()
                        }

                    // Error message
                    if case .error(let message) = linkState {
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

            LadderPrimaryButton("Connect", icon: "link") {
                Task { await connectToChild() }
            }
            .opacity(code.count == 6 ? 1.0 : 0.5)
            .allowsHitTesting(code.count == 6)

            // Help text
            VStack(spacing: LadderSpacing.sm) {
                Text("Don't have a code?")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                Text("Your child can generate one from Settings > Parent Access in their Ladder app.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, LadderSpacing.md)
        }
    }

    // MARK: - Loading

    private var loadingSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(LadderColors.primary)

            Text("Connecting to your child's account...")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(.top, LadderSpacing.xxxl)
    }

    // MARK: - Success

    private var successSection: some View {
        VStack(spacing: LadderSpacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(LadderColors.primary)

            Text("Connected!")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)

            Text("You are now linked to your child's account. You can view their college progress and activity.")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            LadderPrimaryButton("Continue", icon: "arrow.right") {
                authManager.completeOnboarding()
                dismiss()
            }
            .padding(.top, LadderSpacing.md)
        }
    }

    // MARK: - Actions

    private func connectToChild() async {
        linkState = .validating

        let isValid = await inviteManager.validateCode(code)
        guard isValid else {
            linkState = .error("Invalid or expired code. Please check and try again.")
            return
        }

        do {
            try await inviteManager.linkParentToStudent(code: code)
            linkState = .success
        } catch {
            linkState = .error("Something went wrong. Please try again.")
        }
    }
}

#Preview {
    NavigationStack {
        ParentOnboardingView()
            .environment(AuthManager())
    }
}
