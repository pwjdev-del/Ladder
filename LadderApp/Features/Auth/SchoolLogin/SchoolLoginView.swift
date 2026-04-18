import SwiftUI

public struct SchoolLoginView: View {
    public let school: PartnerSchool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var inviteCode: String = ""
    @State private var showingInviteFlow = false

    public init(school: PartnerSchool) {
        self.school = school
    }

    public var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "building.columns").foregroundStyle(accentColor)
                    Text(school.displayName).font(.title3)
                }
            }
            Section("Already have an account") {
                TextField("Email", text: $email).textContentType(.emailAddress).autocapitalization(.none)
                SecureField("Password", text: $password).textContentType(.password)
                Button("Sign in") { /* TODO */ }
            }
            Section("First time? Use your invite code") {
                TextField("INVITE-CODE", text: $inviteCode)
                    .autocapitalization(.allCharacters)
                Button("Join with invite code") { showingInviteFlow = true }
                    .disabled(inviteCode.isEmpty)
            }
        }
        .navigationDestination(isPresented: $showingInviteFlow) {
            InviteRedemptionView(code: inviteCode, tenantId: school.id)
        }
        .tint(accentColor)
    }

    private var accentColor: Color {
        guard let hex = school.primaryColorHex else { return .accentColor }
        return Color(hex: hex) ?? .accentColor
    }
}

extension Color {
    init?(hex: String) {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        let r = Double((v >> 16) & 0xff) / 255
        let g = Double((v >> 8) & 0xff) / 255
        let b = Double(v & 0xff) / 255
        self.init(red: r, green: g, blue: b)
    }
}
