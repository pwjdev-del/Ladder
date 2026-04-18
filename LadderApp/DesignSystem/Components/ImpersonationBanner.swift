import SwiftUI

// §14.5 — full-width red banner shown while an admin-initiated impersonation
// grant is active. Countdown timer to expiry, audit-link on tap.

public struct ImpersonationBanner: View {
    public let expiresAt: Date
    public let grantReason: String
    public let onTapAudit: () -> Void

    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(expiresAt: Date, grantReason: String, onTapAudit: @escaping () -> Void) {
        self.expiresAt = expiresAt
        self.grantReason = grantReason
        self.onTapAudit = onTapAudit
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            VStack(alignment: .leading, spacing: 2) {
                Text("Impersonation active").font(.caption.bold())
                Text(grantReason).font(.caption)
            }
            Spacer()
            Text(timeLeft).font(.caption.monospacedDigit())
            Button("Audit") { onTapAudit() }.font(.caption.bold())
        }
        .foregroundStyle(.white)
        .padding(10)
        .background(Color.red)
        .onReceive(timer) { now = $0 }
    }

    private var timeLeft: String {
        let remaining = max(0, Int(expiresAt.timeIntervalSince(now)))
        return String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }
}
