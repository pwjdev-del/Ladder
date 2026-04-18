import SwiftUI

// §3.2 — per-school login with theme-swap.
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/school_themed_login/

public struct SchoolLoginView: View {
    public let school: PartnerSchool

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var inviteCode: String = ""
    @State private var showingInviteFlow = false
    @Environment(\.dismiss) private var dismiss

    public init(school: PartnerSchool) { self.school = school }

    public var body: some View {
        ZStack {
            LadderBrand.cream100.ignoresSafeArea()

            VStack(spacing: 0) {
                hero
                ScrollView {
                    VStack(spacing: 24) {
                        signInSection
                        orDivider
                        inviteSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                footer
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showingInviteFlow) {
            InviteRedemptionView(code: inviteCode, tenantId: school.id)
        }
    }

    private var accentColor: Color {
        Color(hex: school.primaryColorHex) ?? LadderBrand.forest700
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack {
            accentColor.ignoresSafeArea(edges: .top)

            VStack(spacing: 8) {
                Circle()
                    .fill(LadderBrand.cream100)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(accentColor)
                    )
                Text(school.displayName)
                    .font(.ladderDisplay(20, relativeTo: .title3))
                    .foregroundStyle(LadderBrand.cream100)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .padding(.horizontal, 24)
        }
        .frame(height: 160)
    }

    // MARK: - Sign-in

    private var signInSection: some View {
        VStack(spacing: 16) {
            Text("Sign in")
                .font(.ladderDisplay(28, relativeTo: .title))
                .foregroundStyle(LadderBrand.ink900)

            Text("Welcome back to \(school.displayName).")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.ink600)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                InputField(label: "EMAIL ADDRESS", icon: "envelope", placeholder: "student@\(school.slug).edu", text: $email, keyboard: .emailAddress)
                InputField(label: "PASSWORD", icon: "lock", placeholder: "••••••••", text: $password, secure: true)
            }

            Button {
                // TODO: SupabaseAuthService.shared.signIn(email:password:)
            } label: {
                Text("Sign in")
                    .font(.ladderLabel(16))
                    .foregroundStyle(LadderBrand.ink900)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LadderBrand.lime500)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }

    // MARK: - OR

    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle().fill(LadderBrand.ink400.opacity(0.4)).frame(height: 1)
            Text("OR")
                .font(.ladderCaps(11))
                .tracking(1.1)
                .foregroundStyle(LadderBrand.ink600)
            Rectangle().fill(LadderBrand.ink400.opacity(0.4)).frame(height: 1)
        }
    }

    // MARK: - Invite

    private var inviteSection: some View {
        VStack(spacing: 12) {
            Text("First time?")
                .font(.ladderDisplay(24, relativeTo: .title2))
                .foregroundStyle(LadderBrand.ink900)

            HStack(spacing: 10) {
                Image(systemName: "ticket")
                    .foregroundStyle(LadderBrand.ink600)
                TextField("INVITE-CODE", text: $inviteCode)
                    .font(.ladderBody(15).monospaced())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(LadderBrand.paper)
            .clipShape(Capsule())

            Button {
                showingInviteFlow = true
            } label: {
                Text("Join with invite code")
                    .font(.ladderLabel(15))
                    .foregroundStyle(LadderBrand.ink900)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(Capsule().stroke(LadderBrand.ink900.opacity(0.25), lineWidth: 1))
            }
            .disabled(inviteCode.isEmpty)
            .opacity(inviteCode.isEmpty ? 0.6 : 1.0)
        }
        .padding(20)
        .background(LadderBrand.lime500.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 24) {
            Button("Forgot password?") { /* TODO */ }
            Button("Use a different school") { dismiss() }
        }
        .font(.ladderBody(13))
        .foregroundStyle(LadderBrand.ink600)
        .padding(.bottom, 24)
    }
}

// MARK: - InputField

struct InputField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var secure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ladderCaps(11))
                .tracking(1.1)
                .foregroundStyle(LadderBrand.ink600)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(LadderBrand.ink600)
                if secure {
                    SecureField(placeholder, text: $text)
                        .font(.ladderBody(15))
                } else {
                    TextField(placeholder, text: $text)
                        .font(.ladderBody(15))
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(LadderBrand.stone200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Color hex helper (reused)

extension Color {
    init?(hex: String?) {
        guard let hex else { return nil }
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(
            red: Double((v >> 16) & 0xff) / 255,
            green: Double((v >> 8) & 0xff) / 255,
            blue: Double(v & 0xff) / 255
        )
    }
}
