import SwiftUI

// §3.1 — "Log in with your ID". B2C login (email + password).
// MFA optional for student/parent, required for admin/counselor/founder per §16.1.

public struct B2CLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var working = false
    @State private var error: String?

    public init() {}

    public var body: some View {
        Form {
            Section("Sign in") {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textContentType(.password)
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            Section {
                Button {
                    submit()
                } label: {
                    if working { ProgressView() } else { Text("Sign in") }
                }
                .disabled(working || email.isEmpty || password.isEmpty)
            }
        }
        .navigationTitle("Log in")
    }

    private func submit() {
        Task { @MainActor in
            working = true
            defer { working = false }
            do {
                try await Task.sleep(nanoseconds: 400_000_000)
                // TODO: wire to AuthService.shared.signIn(email:password:)
                // On success: AuthService binds TenantContext claim.
                error = "Auth service not yet wired (ADR-001)"
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
