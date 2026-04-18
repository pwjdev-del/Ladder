import SwiftUI

// MARK: - Milestone Celebration View

struct MilestoneCelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    let milestoneId: String

    @State private var showConfetti = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: LadderSpacing.xl) {
                Spacer()

                // Celebration icon
                ZStack {
                    Circle()
                        .fill(LadderColors.secondaryFixed.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(showConfetti ? 1.1 : 0.8)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showConfetti)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LadderColors.primary, LadderColors.primaryContainer],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 100)
                        .ladderShadow(LadderElevation.glow)

                    Image(systemName: "star.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(showConfetti ? 10 : -10))
                        .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: showConfetti)
                }

                VStack(spacing: LadderSpacing.sm) {
                    Text("Milestone Achieved!")
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("You're making incredible progress on your college journey. Keep going!")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LadderSpacing.xl)
                }

                // Stats
                HStack(spacing: LadderSpacing.xl) {
                    VStack {
                        Text("12")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.primary)
                        Text("Day Streak")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    VStack {
                        Text("85%")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.primary)
                        Text("Complete")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    VStack {
                        Text("5")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.primary)
                        Text("Schools")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()

                LadderPrimaryButton("Keep Going!", icon: "arrow.right") {
                    dismiss()
                }
                .padding(.horizontal, LadderSpacing.xl)

                Spacer()
            }
        }
        .onAppear { showConfetti = true }
    }
}
