import SwiftUI

struct LockedFeatureView: View {
    let featureName: String
    let unlockGrade: Int
    let description: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: LadderSpacing.xl) {
                Spacer()

                // Lock icon with glow
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.4))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(LadderColors.primary)
                }

                Text(featureName)
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Unlocks in \(unlockGrade)th Grade")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.primary)

                Text(description)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.xxl)

                // What they CAN do now
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    Text("WHAT YOU CAN DO NOW")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    tipRow("Take the Career Quiz to discover your path", icon: "sparkles")
                    tipRow("Start building activities and volunteering", icon: "star.fill")
                    tipRow("Explore colleges and save your favorites", icon: "building.columns.fill")
                }
                .padding(LadderSpacing.lg)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))
                .padding(.horizontal, LadderSpacing.lg)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(featureName)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private func tipRow(_ text: String, icon: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 24)
            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
    }
}
