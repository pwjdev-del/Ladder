import SwiftUI
import SwiftData

// MARK: - Consent Gate View
// Shown after signup / first login. User MUST agree to all legal terms
// before proceeding to onboarding or dashboard. Cannot be skipped.

struct ConsentView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var termsAccepted = false
    @State private var privacyAccepted = false
    @State private var ageVerified = false
    @State private var waiverAccepted = false
    @State private var aiDisclaimerAccepted = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showAgeGate = false
    @State private var isUnder13 = false
    @State private var parentEmail = ""
    @State private var showParentEmailField = false
    @State private var dateOfBirth = Date()
    @State private var hasSelectedDOB = false
    @State private var scrolledToBottom = false

    private var allAccepted: Bool {
        termsAccepted && privacyAccepted && ageVerified && waiverAccepted && aiDisclaimerAccepted
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .sheet(isPresented: $showTerms) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
    }

    // MARK: - iPhone Layout (unchanged)

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    headerSection
                    ageVerificationSection
                    consentChecklistSection
                    if showParentEmailField {
                        parentConsentSection
                    }
                    acceptButton
                    declineNote
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, LadderSpacing.xxxxl)
            }
        }
    }

    // MARK: - iPad Layout (centered card on soft surface)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surfaceContainerLow.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: LadderSpacing.xxl)

                    VStack(spacing: 0) {
                        // Card header
                        VStack(spacing: LadderSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.3))
                                    .frame(width: 96, height: 96)

                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 44))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            Text("Before We Begin")
                                .font(LadderTypography.displaySmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .editorialTracking()

                            Text("Please review and accept the following to protect you and your data.")
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, LadderSpacing.xxxl)
                        .padding(.top, LadderSpacing.xxxl)
                        .padding(.bottom, LadderSpacing.xl)
                        .frame(maxWidth: .infinity)
                        .background(LadderColors.surfaceContainerLowest)

                        Divider()
                            .overlay(LadderColors.surfaceContainerHigh)

                        // Scrollable body sections
                        VStack(spacing: LadderSpacing.xl) {
                            ageVerificationSection
                            consentChecklistSection
                            if showParentEmailField {
                                parentConsentSection
                            }
                        }
                        .padding(LadderSpacing.xxl)
                        .frame(maxWidth: .infinity)
                        .background(LadderColors.surface)

                        Divider()
                            .overlay(LadderColors.surfaceContainerHigh)

                        // Footer: Decline + Agree
                        VStack(spacing: LadderSpacing.md) {
                            HStack(spacing: LadderSpacing.md) {
                                Button {
                                    Task { await authManager.signOut() }
                                } label: {
                                    Text("Decline & Sign Out")
                                        .font(LadderTypography.labelLarge)
                                        .foregroundStyle(LadderColors.error)
                                        .padding(.horizontal, LadderSpacing.xl)
                                        .padding(.vertical, LadderSpacing.md)
                                        .background(LadderColors.surfaceContainerHigh)
                                        .clipShape(Capsule())
                                }

                                Spacer()

                                Button {
                                    saveConsent()
                                    authManager.acceptConsent()
                                } label: {
                                    HStack(spacing: LadderSpacing.xs) {
                                        Image(systemName: "checkmark.shield.fill")
                                        Text("I Agree — Continue")
                                    }
                                    .font(LadderTypography.labelLarge)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .padding(.horizontal, LadderSpacing.xl)
                                    .padding(.vertical, LadderSpacing.md)
                                    .background(LadderColors.accentLime)
                                    .clipShape(Capsule())
                                }
                                .opacity(allAccepted ? 1 : 0.4)
                                .disabled(!allAccepted)
                            }

                            if !allAccepted {
                                Text("Please check all boxes above to continue")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                        .padding(LadderSpacing.xxl)
                        .frame(maxWidth: .infinity)
                        .background(LadderColors.surfaceContainerLowest)
                    }
                    .frame(maxWidth: 720)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
                    .ladderShadow(LadderElevation.ambient)
                    .padding(.horizontal, LadderSpacing.xxl)

                    Spacer().frame(height: LadderSpacing.xxl)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.md) {
            Spacer().frame(height: LadderSpacing.lg)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 80, height: 80)

                Image(systemName: "shield.checkered")
                    .font(.system(size: 36))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("Before We Begin")
                .font(LadderTypography.headlineLarge)
                .foregroundStyle(LadderColors.onSurface)
                .editorialTracking()

            Text("Please review and accept the following to protect you and your data.")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Age Verification

    private var ageVerificationSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("DATE OF BIRTH")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: LadderSpacing.md) {
                DatePicker(
                    "Date of Birth",
                    selection: $dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .font(LadderTypography.bodyLarge)
                .tint(LadderColors.primary)
                .onChange(of: dateOfBirth) { _, newValue in
                    hasSelectedDOB = true
                    let age = Calendar.current.dateComponents([.year], from: newValue, to: Date()).year ?? 0
                    isUnder13 = age < 13
                    showParentEmailField = isUnder13
                    if !isUnder13 {
                        ageVerified = true
                    } else {
                        ageVerified = false
                    }
                }

                if hasSelectedDOB {
                    let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
                    if isUnder13 {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(LadderColors.error)
                            Text("You are under 13. A parent or guardian must provide consent.")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.error)
                        }
                    } else {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(LadderColors.primary)
                            Text("Age verified (\(age) years old)")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    // MARK: - Parent Consent (COPPA)

    private var parentConsentSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("PARENT/GUARDIAN CONSENT (REQUIRED)")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.error)
                .labelTracking()

            VStack(spacing: LadderSpacing.md) {
                Text("Since you are under 13, the Children's Online Privacy Protection Act (COPPA) requires your parent or guardian to provide consent before you can use Ladder.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                LadderTextField("Parent/Guardian Email", text: $parentEmail, icon: "envelope")

                Text("We will send a verification email to your parent/guardian. You will be able to use the app once they confirm consent.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                if !parentEmail.isEmpty && parentEmail.contains("@") {
                    Button {
                        ageVerified = true
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "paperplane.fill")
                            Text("Send Consent Request")
                        }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.error.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(LadderColors.error.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Consent Checklist

    private var consentChecklistSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("AGREEMENTS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: 0) {
                consentRow(
                    text: LegalTexts.consentCheckboxToS,
                    isOn: $termsAccepted,
                    action: { showTerms = true },
                    linkText: "Read Terms"
                )

                consentRow(
                    text: LegalTexts.consentCheckboxPrivacy,
                    isOn: $privacyAccepted,
                    action: { showPrivacy = true },
                    linkText: "Read Policy"
                )

                consentRow(
                    text: LegalTexts.consentCheckboxWaiver,
                    isOn: $waiverAccepted
                )

                consentRow(
                    text: LegalTexts.consentCheckboxAI,
                    isOn: $aiDisclaimerAccepted
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    private func consentRow(text: String, isOn: Binding<Bool>, action: (() -> Void)? = nil, linkText: String? = nil) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundStyle(isOn.wrappedValue ? LadderColors.primary : LadderColors.onSurfaceVariant.opacity(0.5))
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(text)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .fixedSize(horizontal: false, vertical: true)

                if let linkText, let action {
                    Button(action: action) {
                        Text(linkText)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                            .underline()
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
    }

    // MARK: - Accept Button

    private var acceptButton: some View {
        VStack(spacing: LadderSpacing.md) {
            LadderAccentButton("I Agree — Continue", icon: "checkmark.shield.fill") {
                saveConsent()
                authManager.acceptConsent()
            }
            .opacity(allAccepted ? 1 : 0.4)
            .disabled(!allAccepted)

            if !allAccepted {
                Text("Please check all boxes above to continue")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }

    private var declineNote: some View {
        VStack(spacing: LadderSpacing.sm) {
            Text("If you do not agree, you cannot use Ladder.")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            Button {
                Task { await authManager.signOut() }
            } label: {
                Text("Decline and Sign Out")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.error)
                    .underline()
            }
        }
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Save

    private func saveConsent() {
        let record = ConsentRecord(
            userId: authManager.userId ?? "anonymous",
            termsAccepted: termsAccepted,
            privacyAccepted: privacyAccepted,
            ageVerified: ageVerified,
            waiverAccepted: waiverAccepted,
            ferpaAcknowledged: true,
            aiDisclaimerAccepted: aiDisclaimerAccepted,
            coppaParentalConsent: isUnder13 && ageVerified,
            parentEmail: isUnder13 ? parentEmail : nil
        )
        modelContext.insert(record)

        // Also save lightweight flag for quick consent checks on app launch
        let manager = ConsentManager()
        manager.recordConsent()
    }
}
