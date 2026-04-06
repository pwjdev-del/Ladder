import SwiftUI

// MARK: - Primary CTA Button
// Gradient fill from primary → primaryContainer, pill shape, scale on press

struct LadderPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.sm) {
                Text(title.uppercased())
                    .font(LadderTypography.labelLarge)
                    .labelTracking()
                    .foregroundStyle(.white)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.lg)
            .background(
                LinearGradient(
                    colors: [LadderColors.primary, LadderColors.primaryContainer],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .ladderShadow(LadderElevation.primaryGlow)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Lime Accent Button (for splash, onboarding CTAs)

struct LadderAccentButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.sm) {
                Text(title.uppercased())
                    .font(LadderTypography.labelLarge)
                    .labelTracking()
                    .foregroundStyle(LadderColors.onSecondaryFixed)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LadderColors.onSecondaryFixed)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.lg)
            .background(LadderColors.accentLime)
            .clipShape(Capsule())
            .ladderShadow(LadderElevation.glow)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Secondary Button

struct LadderSecondaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.surfaceContainerHighest)
                .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Tertiary Button (underlined text)

struct LadderTertiaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.primary)
                .underline(true, color: LadderColors.secondaryFixed)
        }
    }
}

// MARK: - Scale Button Style (press = 0.95 scale)

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        LadderPrimaryButton("Get Started", icon: "arrow.right") {}
        LadderAccentButton("Continue", icon: "arrow.right") {}
        LadderSecondaryButton("I Already Have an Account") {}
        LadderTertiaryButton("Skip for now") {}
    }
    .padding(24)
    .background(LadderColors.surface)
}
