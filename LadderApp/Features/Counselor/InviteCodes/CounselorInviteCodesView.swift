import SwiftUI
import os

// §6.1 — counselor-generated invite codes: single, bulk, class-level.
// Codes are generated server-side via counselor_issue_invite RPC.
// Plaintext shown ONCE via InviteCodeDisplay; backend stores only SHA-256 hash.

// MARK: - RPC response model

private struct IssuedInvite: Decodable {
    let code: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case code
        case expiresAt = "expires_at"
    }
}

// MARK: - View model

@MainActor
private final class CounselorInviteViewModel: ObservableObject {
    @Published private(set) var issued: [String] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private static let logger = Logger(subsystem: "app.ladder", category: "counselor-invite")

    func issueInvites(quantity: Int, intendedEmail: String?) async {
        isLoading = true
        errorMessage = nil
        issued = []

        do {
            var codes: [String] = []
            let supabase = await SupabaseAuthService.shared.supabase

            for _ in 0..<quantity {
                // RPC returns a single-row table; Supabase SDK decodes as [IssuedInvite].
                let result: [IssuedInvite] = try await supabase
                    .rpc(
                        "counselor_issue_invite",
                        params: CounselorInviteParams(intendedEmail: intendedEmail)
                    )
                    .execute()
                    .value
                if let first = result.first {
                    codes.append(first.code)
                }
            }
            issued = codes
        } catch {
            Self.logger.error("counselor_issue_invite failed: \(error, privacy: .public)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// Codable parameter bag for the RPC.
private struct CounselorInviteParams: Encodable {
    let intendedEmail: String?

    enum CodingKeys: String, CodingKey {
        case intendedEmail = "p_intended_email"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        // Only include the key when a non-empty email was supplied.
        if let email = intendedEmail, !email.trimmingCharacters(in: .whitespaces).isEmpty {
            try c.encode(email, forKey: .intendedEmail)
        }
    }
}

// MARK: - View

public struct CounselorInviteCodesView: View {
    public enum Mode: String, CaseIterable, Identifiable {
        case single = "Single"
        case bulk = "Bulk"
        public var id: Self { self }
    }

    @StateObject private var vm = CounselorInviteViewModel()
    @State private var mode: Mode = .single
    @State private var quantity: Int = 1
    @State private var intendedEmail: String = ""

    public init() {}

    // T024 iPad parity: MaxWidthContainer(640) keeps the Form at a legible width
    // on iPad Pro landscape without clipping toggle rows or email fields.
    public var body: some View {
        MaxWidthContainer(maxWidth: 640) {
            Form {
                Section("Mode") {
                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("Options") {
                    if mode == .bulk {
                        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...50)
                    }
                    TextField("Intended email (optional)", text: $intendedEmail)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
                Section {
                    Button {
                        let email = intendedEmail.isEmpty ? nil : intendedEmail
                        let count = mode == .bulk ? quantity : 1
                        Task { await vm.issueInvites(quantity: count, intendedEmail: email) }
                    } label: {
                        if vm.isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Generating...")
                            }
                        } else {
                            Text("Generate")
                        }
                    }
                    .disabled(vm.isLoading)
                }
                if let err = vm.errorMessage {
                    Section {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
                if !vm.issued.isEmpty {
                    Section("Shown once — copy now") {
                        ForEach(vm.issued, id: \.self) { InviteCodeDisplay(code: $0) }
                    }
                }
            }
        }
        .navigationTitle("Invite codes")
    }
}
