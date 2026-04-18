import SwiftUI

// §6 — B2C student signup. COPPA gate: if DOB < 13, signup creates only a
// minimal record and blocks full data collection until parent consent
// (§6.2 step 3).

public struct B2CSignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var dob: Date = Calendar.current.date(from: DateComponents(year: 2015, month: 1, day: 1)) ?? Date()
    @State private var acceptedTerms = false
    @State private var acceptedPrivacy = false
    @State private var working = false
    @State private var showingConsent = false

    private var age: Int {
        Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }

    public init() {}

    public var body: some View {
        Form {
            Section("Create your account") {
                TextField("Email", text: $email).autocapitalization(.none)
                SecureField("Password (12+ chars)", text: $password)
                DatePicker("Date of birth", selection: $dob, displayedComponents: .date)
            }

            if age < 13 {
                Section {
                    Text("Because you're under 13, a parent needs to approve your account before you can use Ladder. We'll ask for their email next.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Agreements") {
                Toggle("I have read and accept the Terms", isOn: $acceptedTerms)
                Toggle("I have read the Privacy Notice", isOn: $acceptedPrivacy)
                Button("View agreements") { showingConsent = true }
            }

            Section {
                Button {
                    submit()
                } label: {
                    if working { ProgressView() } else { Text("Create account") }
                }
                .disabled(!formReady)
            }
        }
        .navigationTitle("Sign up")
        .sheet(isPresented: $showingConsent) { ConsentSheetView() }
    }

    private var formReady: Bool {
        !email.isEmpty && password.count >= 12 && acceptedTerms && acceptedPrivacy
    }

    private func submit() {
        Task { @MainActor in
            working = true
            defer { working = false }
            try? await Task.sleep(nanoseconds: 400_000_000)
            // TODO: wire to AuthService.signUp(email:password:dob:)
        }
    }
}

public struct ConsentSheetView: View {
    public init() {}
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Summary").font(.title2.bold())
                    Text("What we collect, what we don't, who sees what, how to delete your data. Plain language first; full legal text below.")
                    Text("Terms").font(.headline).padding(.top)
                    Text("…").foregroundStyle(.secondary)
                    Text("Privacy").font(.headline).padding(.top)
                    Text("…").foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Agreements")
        }
    }
}

public struct SchoolPartnerInquiryView: View {
    public init() {}
    public var body: some View {
        Form {
            Section("Partner with Ladder") {
                TextField("School name", text: .constant(""))
                TextField("Contact email", text: .constant(""))
                TextField("Approx student count", text: .constant(""))
                TextField("State", text: .constant(""))
                Button("Submit inquiry") { /* TODO */ }
            }
            Section {
                Text("Not self-service. Founders review inquiries and reach out to schedule onboarding (§7).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Partner as a school")
    }
}
