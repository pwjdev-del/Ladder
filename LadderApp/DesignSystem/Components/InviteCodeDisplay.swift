import SwiftUI
import UIKit

// Phase 4 design review — missing component. Plaintext codes are shown ONCE
// (§6.1). Offers one-tap copy + visually blurs if the user returns to the
// screen later.

public struct InviteCodeDisplay: View {
    public let code: String
    @State private var copied = false
    @State private var blurredAfterTimer = false

    public init(code: String) { self.code = code }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(code)
                    .font(.title2.monospaced().bold())
                    .blur(radius: blurredAfterTimer ? 8 : 0)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    copied = true
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption.bold())
                }
                .buttonStyle(.bordered)
            }
            Text("Shown once. Write it down or paste it now.")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.yellow.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange.opacity(0.4), lineWidth: 1))
        .task {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            blurredAfterTimer = true
        }
    }
}
