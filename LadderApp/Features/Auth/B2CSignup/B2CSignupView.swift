import SwiftUI
import OSLog

// §6 — B2C student signup with inline COPPA gate.
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/b2c_signup_with_coppa_gate/

public struct B2CSignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var month: Int = 8
    @State private var day: Int = 14
    @State private var year: Int = 2014
    @State private var acceptedTerms = false
    @State private var acceptedPrivacy = false
    @State private var legalDocumentSheet: LegalDocument?
    @State private var working = false
    // Inline error surfaced when signUp throws (network error, duplicate email, etc.)
    @State private var errorMessage: String?
    // Set to true when Supabase requires email confirmation (session is nil after signUp).
    @State private var needsEmailConfirmation = false
    // Non-nil after successful signUp with a live session — triggers navigation.
    @State private var signedInSession: SignedInSession?
    // Flipped to true on first "Create account" press; drives inline validation hints.
    @State private var showValidationErrors = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.lime500.opacity(0.12).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    wordmark
                    Text("Create your account")
                        .font(.ladderDisplay(40, relativeTo: .largeTitle))
                        .foregroundStyle(LadderBrand.ink900)
                        .tracking(-0.8)
                        .padding(.top, 8)

                    emailField
                    passwordField
                    dobPickers

                    if age < 13 { coppaCard }

                    VStack(spacing: 10) {
                        consentToggle("I have read and accept the Terms", isOn: $acceptedTerms, errorText: showValidationErrors && !acceptedTerms ? "Required — please accept the Terms" : nil, documentToView: .terms)
                        consentToggle("Privacy Notice", isOn: $acceptedPrivacy, errorText: showValidationErrors && !acceptedPrivacy ? "Required — please accept the Privacy Notice" : nil, documentToView: .privacy)
                    }
                    .padding(.top, 16)

                    // Email-confirmation success state: Supabase requires verification.
                    if needsEmailConfirmation {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "envelope.badge.checkmark")
                                .font(.system(size: 20))
                                .foregroundStyle(LadderBrand.forest700)
                            Text("Check your email to confirm your account, then log in.")
                                .font(.ladderBody(14))
                                .foregroundStyle(LadderBrand.ink900)
                        }
                        .padding(14)
                        .background(LadderBrand.lime500.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityIdentifier("signup-email-confirmation-banner")
                    }

                    // Inline error message surfaced when signUp throws.
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.ladderBody(13))
                            .foregroundStyle(LadderBrand.statusRed)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("signup-error-message")
                    }

                    createButton
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .requireNonStaff()
        .sheet(item: $legalDocumentSheet) { doc in
            LegalDocumentSheet(document: doc)
        }
        // Navigate to the role dashboard immediately when signup completes with a live session.
        .navigationDestination(item: $signedInSession) { session in
            SignedInRouter(session: session)
        }
    }

    private var wordmark: some View {
        HStack {
            Text("Ladder")
                .font(.ladderDisplay(28, relativeTo: .title).italic())
                .foregroundStyle(LadderBrand.forest700)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(LadderBrand.ink600)
            }
        }
    }

    // MARK: - Validation helpers

    private var emailValid: Bool {
        // RFC-lite check: must have exactly one @, a non-empty local part, and a dot after @.
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        return parts[1].contains(".")
    }

    private var passwordValid: Bool { password.count >= 8 }

    private var formReady: Bool {
        emailValid && passwordValid && acceptedTerms && acceptedPrivacy
    }

    // MARK: - Fields

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EMAIL").font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
            TextField("student@example.com", text: $email)
                .font(.ladderBody(15))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(showValidationErrors && !emailValid ? LadderBrand.statusRed.opacity(0.08) : LadderBrand.stone200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(showValidationErrors && !emailValid ? LadderBrand.statusRed : Color.clear, lineWidth: 1.5)
                )

            if showValidationErrors && !emailValid {
                Label(
                    email.isEmpty ? "Email is required" : "Please enter a valid email address",
                    systemImage: "exclamationmark.circle.fill"
                )
                .font(.ladderBody(12))
                .foregroundStyle(LadderBrand.statusRed)
                .accessibilityIdentifier("signup-email-error")
            }
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PASSWORD").font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
            SecureField("••••••••", text: $password)
                .font(.ladderBody(15))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(showValidationErrors && !passwordValid ? LadderBrand.statusRed.opacity(0.08) : LadderBrand.stone200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(showValidationErrors && !passwordValid ? LadderBrand.statusRed : Color.clear, lineWidth: 1.5)
                )

            // Strength bars (Fair when >=8 chars; Strong when >=12)
            HStack(spacing: 6) {
                ForEach(0..<4) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < strengthIndex ? LadderBrand.lime500 : LadderBrand.ink400.opacity(0.2))
                        .frame(height: 4)
                }
                Text(strengthLabel)
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.ink600)
                    .frame(width: 48, alignment: .trailing)
            }

            if showValidationErrors && !passwordValid {
                Label(
                    password.isEmpty
                        ? "Password is required"
                        : "Must be at least 8 characters (\(password.count)/8)",
                    systemImage: "exclamationmark.circle.fill"
                )
                .font(.ladderBody(12))
                .foregroundStyle(LadderBrand.statusRed)
                .accessibilityIdentifier("signup-password-error")
            }
        }
    }

    private var strengthIndex: Int {
        switch password.count {
        case 0: return 0
        case 1..<8: return 1
        case 8..<12: return 2
        default: return 4
        }
    }

    private var strengthLabel: String {
        switch strengthIndex {
        case 0: return ""
        case 1: return "Weak"
        case 2: return "Fair"
        default: return "Strong"
        }
    }

    private var dobPickers: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DATE OF BIRTH").font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
            HStack(spacing: 10) {
                dobPicker(selection: $month, range: 1...12, label: Self.monthLabel(month))
                dobPicker(selection: $day, range: 1...31, label: "\(day)")
                dobPicker(selection: $year, range: 2005...2020, label: "\(year)")
            }
        }
    }

    private func dobPicker<S: View>(selection: Binding<Int>, range: ClosedRange<Int>, @ViewBuilder label: () -> S = { EmptyView() }) -> some View where S: View {
        Menu {
            Picker("", selection: selection) {
                ForEach(range, id: \.self) { v in Text("\(v)").tag(v) }
            }
        } label: {
            HStack {
                label()
                Spacer()
                Image(systemName: "chevron.down").foregroundStyle(LadderBrand.ink600)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(LadderBrand.stone200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(LadderBrand.ink900)
        }
    }

    private func dobPicker(selection: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
        Menu {
            Picker("", selection: selection) {
                ForEach(range, id: \.self) { v in Text("\(v)").tag(v) }
            }
        } label: {
            HStack {
                Text(label).font(.ladderBody(15))
                Spacer()
                Image(systemName: "chevron.down").foregroundStyle(LadderBrand.ink600).font(.system(size: 12))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(LadderBrand.stone200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(LadderBrand.ink900)
        }
    }

    private static func monthLabel(_ m: Int) -> String {
        DateFormatter().monthSymbols[max(0, min(11, m - 1))]
    }

    private var age: Int {
        let dob = DateComponents(calendar: Calendar.current, year: year, month: month, day: day).date ?? Date()
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }

    // MARK: - COPPA

    private var coppaCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "figure.2.and.child.holdinghands")
                .font(.system(size: 24))
                .foregroundStyle(LadderBrand.forest700)
            Text("Because you're under 13, a grown-up needs to say it's OK. We'll ask for their email after you sign up.")
                .font(.ladderBody(15))
                .foregroundStyle(LadderBrand.ink900)
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(LadderBrand.paper)
        .overlay(
            HStack(spacing: 0) {
                Rectangle().fill(LadderBrand.lime500).frame(width: 4)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Consent toggles

    /// `errorText` is shown in red below the toggle row when non-nil.
    /// `documentToView` makes the label tappable — opens a sheet with the actual
    /// legal text so users can READ what they're agreeing to before they toggle.
    private func consentToggle(
        _ label: String,
        isOn: Binding<Bool>,
        errorText: String? = nil,
        documentToView: LegalDocument? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let documentToView {
                    // Tappable — opens the legal text sheet.
                    Button {
                        legalDocumentSheet = documentToView
                    } label: {
                        HStack(spacing: 6) {
                            Text(label)
                                .font(.ladderBody(15))
                                .foregroundStyle(LadderBrand.ink900)
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 12))
                                .foregroundStyle(LadderBrand.forest700)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the legal document to read")
                } else {
                    Text(label)
                        .font(.ladderBody(15))
                        .foregroundStyle(LadderBrand.ink900)
                }
                Spacer()
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(LadderBrand.lime500)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(errorText != nil ? LadderBrand.statusRed.opacity(0.06) : LadderBrand.paper)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(errorText != nil ? LadderBrand.statusRed : Color.clear, lineWidth: 1.5)
            )

            if let errorText {
                Label(errorText, systemImage: "exclamationmark.circle.fill")
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.statusRed)
                    .padding(.horizontal, 4)
            }
        }
    }

    /// Identifier for which legal document to show in the sheet.
    enum LegalDocument: String, Identifiable {
        case terms, privacy
        var id: String { rawValue }

        var title: String {
            switch self {
            case .terms: return "Terms of Service"
            case .privacy: return "Privacy Notice"
            }
        }
    }

    // MARK: - Create

    private var createButton: some View {
        Button {
            submit()
        } label: {
            HStack {
                if working { ProgressView().tint(LadderBrand.ink900) }
                else { Text("Create account").font(.ladderLabel(16)) }
            }
            .foregroundStyle(LadderBrand.ink900)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(LadderBrand.lime500)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        // iOS 26 default button style applies a system tint that overrides our
        // custom .background — without .plain the button renders tan/grey.
        .buttonStyle(.plain)
        .disabled(working)
        .accessibilityIdentifier("signup-create-button")
    }

    private func submit() {
        // Always show validation errors after first press so the user can see exactly what's missing.
        showValidationErrors = true

        guard formReady else { return }

        Task { @MainActor in
            working = true
            errorMessage = nil
            needsEmailConfirmation = false
            defer { working = false }
            do {
                let supabaseSession = try await SupabaseAuthService.shared.signUp(
                    email: email.lowercased().trimmingCharacters(in: .whitespaces),
                    password: password
                )
                // signUp returned a live session — bind role and navigate.
                let claim = await TenantContext.shared.claim
                let role: SignedInRole = {
                    switch claim?.role {
                    case .admin:     return .admin
                    case .counselor: return .counselor
                    case .parent:    return .parent
                    case .founder:   return .founder
                    default:         return .student
                    }
                }()
                let grade = TenantContext.shared.studentGradeLevel
                signedInSession = SignedInSession(
                    role: role,
                    displayName: String(supabaseSession.user.email?.split(separator: "@").first ?? ""),
                    tenantName: TenantContext.shared.tenantDisplayName ?? "Ladder",
                    gradeLevel: grade
                )
            } catch LadderAuthError.emailConfirmationRequired {
                // Supabase requires email verification before a session is issued.
                // Surface the confirmation banner; do NOT navigate.
                needsEmailConfirmation = true
            } catch LadderAuthError.missingRoleClaim {
                // Account created but bootstrap-user ran and JWT still lacks role.
                // This is a server-side configuration issue, not a normal state.
                errorMessage = "Account created but not yet activated. Contact support if this persists."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - B2B inquiry (reuses same cream shell)

public struct SchoolPartnerInquiryView: View {
    @State private var schoolName = ""
    @State private var contactName = ""
    @State private var role = "Principal"
    @State private var state = "California"
    @State private var email = ""
    @State private var phone = ""
    @State private var studentCount = 500
    @State private var features: Set<String> = ["Scheduling", "Extracurriculars"]
    /// True once the form is submitted successfully (shows confirmation banner).
    @State private var submitted = false
    /// Non-nil when submission fails so we can surface the error inline.
    @State private var submitError: String?
    @Environment(\.dismiss) private var dismiss

    // Logger for inquiry data — survives even without a backing table.
    // TODO: replace os_log path with a real Supabase insert once the
    // `school_inquiries` table is added (see migration 0010, TBD).
    private static let logger = Logger(subsystem: "com.ladder.app", category: "SchoolPartnerInquiry")

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.lime500.opacity(0.12).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    wordmark
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bring Ladder to\nyour school.")
                            .font(.ladderDisplay(32, relativeTo: .largeTitle))
                            .tracking(-0.8)
                            .foregroundStyle(LadderBrand.forest700)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Tell us a bit about your school. We'll reach out within a week.")
                            .font(.ladderBody(14))
                            .foregroundStyle(LadderBrand.ink600)
                    }

                    detailsCard
                    estimateCard

                    if submitted {
                        // Success confirmation — shown in place of the submit button.
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(LadderBrand.forest700)
                            Text("Thanks — we'll be in touch within 48 hours.")
                                .font(.ladderBody(15))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(LadderBrand.forest700)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(LadderBrand.lime500.opacity(0.20))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, 32)
                    } else {
                        if let err = submitError {
                            Text(err)
                                .font(.ladderBody(13))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                        }

                        Button { submitInquiry() } label: {
                            HStack(spacing: 8) {
                                Text("Submit inquiry").font(.ladderLabel(16))
                                Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(LadderBrand.ink900)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(formValid ? LadderBrand.lime500 : LadderBrand.stone200)
                            .clipShape(Capsule())
                        }
                        .disabled(!formValid)
                        .opacity(formValid ? 1.0 : 0.7)
                        .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
    }

    private var formValid: Bool {
        !schoolName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !contactName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // TODO: Replace body with a real Supabase insert into `school_inquiries` once
    // migration 0010 lands. Until then the data is captured via os_log so no inquiry
    // is silently lost during the pilot period.
    private func submitInquiry() {
        submitError = nil
        guard formValid else {
            submitError = "Please fill in school name, contact name, and email."
            return
        }

        Self.logger.info("""
        SchoolPartnerInquiry submitted (no DB yet — needs migration 0010):
          school=\(schoolName, privacy: .public)
          contact=\(contactName, privacy: .public)
          role=\(role, privacy: .public)
          state=\(state, privacy: .public)
          email=\(email, privacy: .public)
          phone=\(phone.isEmpty ? "(none)" : phone, privacy: .public)
          studentCount=\(studentCount, privacy: .public)
          features=\(features.sorted().joined(separator: ", "), privacy: .public)
        """)

        submitted = true
    }

    private var wordmark: some View {
        HStack {
            Button { /* menu */ } label: {
                Image(systemName: "line.3.horizontal").foregroundStyle(LadderBrand.ink600).font(.system(size: 20))
            }
            Text("Ladder")
                .font(.ladderDisplay(24, relativeTo: .title2).italic())
                .foregroundStyle(LadderBrand.forest700)
            Spacer()
            Circle()
                .fill(LadderBrand.forest700.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: "person.fill").font(.system(size: 14)).foregroundStyle(LadderBrand.forest700))
        }
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            field("SCHOOL NAME", text: $schoolName, placeholder: "e.g. Oakridge Middle")
            field("CONTACT NAME", text: $contactName, placeholder: "Jane Doe")
            dropdown("YOUR ROLE", selection: $role, options: ["Principal", "Counselor", "Administrator", "Other"])
            dropdown("STATE", selection: $state, options: ["California", "Florida", "Texas", "New York"])
            field("EMAIL ADDRESS", text: $email, placeholder: "jane@school.edu", keyboard: .emailAddress)
            field("PHONE NUMBER", text: $phone, placeholder: "(555) 000-0000", keyboard: .phonePad)
        }
        .padding(20)
        .background(LadderBrand.lime500.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var estimateCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ESTIMATED STUDENT COUNT")
                    .font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Button { if studentCount > 50 { studentCount -= 50 } } label: {
                        Image(systemName: "minus").foregroundStyle(LadderBrand.ink900)
                            .frame(width: 44, height: 44)
                            .background(LadderBrand.paper)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("\(studentCount)")
                        .font(.ladderDisplay(32, relativeTo: .title))
                        .foregroundStyle(LadderBrand.ink900)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(LadderBrand.stone200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                    Button { studentCount += 50 } label: {
                        Image(systemName: "plus").foregroundStyle(LadderBrand.ink900)
                            .frame(width: 44, height: 44)
                            .background(LadderBrand.paper)
                            .clipShape(Circle())
                    }
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("DESIRED FEATURES")
                    .font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
                FeatureChipsGrid(selected: $features)
            }
        }
        .padding(20)
        .background(LadderBrand.lime500.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
            TextField(placeholder, text: text)
                .font(.ladderBody(15))
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(LadderBrand.stone200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func dropdown(_ label: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.ink600)
            Menu {
                Picker("", selection: selection) {
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue).font(.ladderBody(15))
                    Spacer()
                    Image(systemName: "chevron.down").font(.system(size: 12))
                }
                .foregroundStyle(LadderBrand.ink900)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(LadderBrand.stone200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

// MARK: - Feature chips

struct FeatureChipsGrid: View {
    @Binding var selected: Set<String>
    private let features = ["Scheduling", "Class Suggester", "Extracurriculars", "Career Quiz", "Parent Comm"]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(features, id: \.self) { f in
                Button {
                    if selected.contains(f) { selected.remove(f) } else { selected.insert(f) }
                } label: {
                    Text(f)
                        .font(.ladderLabel(13))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selected.contains(f) ? LadderBrand.forest700 : LadderBrand.paper)
                        .foregroundStyle(selected.contains(f) ? LadderBrand.cream100 : LadderBrand.ink900)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Minimal flow layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for v in subviews {
            let size = v.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for v in subviews {
            let size = v.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

public struct ConsentSheetView: View {
    public init() {}
    public var body: some View {
        Text("Legal text …")
    }
}
