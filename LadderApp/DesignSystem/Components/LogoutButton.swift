import SwiftUI

// Shared logout button used on every authenticated surface. Keeps the
// brand look (cream pill on dark gradient, forest on light) consistent
// and guarantees we have a way off any dashboard without restarting the
// app. Calls back into the SignedInRouter which pops to Landing.

public struct LogoutButton: View {
    public let action: () -> Void
    public var label: String
    public var onDarkSurface: Bool

    public init(label: String = "Log out",
                onDarkSurface: Bool = true,
                action: @escaping () -> Void) {
        self.label = label
        self.onDarkSurface = onDarkSurface
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.ladderLabel(13))
            }
            .foregroundStyle(onDarkSurface ? LadderBrand.cream100 : LadderBrand.ink900)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(onDarkSurface ? LadderBrand.cream100.opacity(0.12) : LadderBrand.stone200)
            .overlay(
                Capsule().stroke(onDarkSurface ? LadderBrand.cream100.opacity(0.25) : LadderBrand.ink400.opacity(0.3), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .accessibilityLabel("Log out")
    }
}
