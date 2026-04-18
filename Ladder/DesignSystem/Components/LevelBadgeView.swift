import SwiftUI

// MARK: - Level Badge View
// Compact level + XP progress bar for Profile header and Dashboard greeting

struct LevelBadgeView: View {
    let xp: Int

    private var manager: LevelManager { LevelManager.shared }
    private var level: LevelManager.Level { manager.currentLevel(xp: xp) }
    private var progress: Double { manager.progress(xp: xp) }
    private var remaining: Int { manager.xpToNextLevel(xp: xp) }

    var body: some View {
        HStack(spacing: LadderSpacing.sm) {
            // Level star icon
            ZStack {
                Circle()
                    .fill(LadderColors.secondaryFixed.opacity(0.25))
                    .frame(width: 32, height: 32)
                ZStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.secondaryFixed)
                    Text("\(level.number)")
                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                        .foregroundStyle(LadderColors.onSecondaryFixed)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: LadderSpacing.xs) {
                    Text(level.name)
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(.white)

                    Spacer()

                    if remaining > 0 {
                        Text("\(remaining) XP to next")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Text("MAX LEVEL")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.secondaryFixed)
                            .labelTracking()
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.white.opacity(0.2))
                            .frame(height: 5)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(LadderColors.secondaryFixed)
                            .frame(width: max(geo.size.width * progress, 4), height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

// MARK: - Compact variant for inline usage (e.g., stat cards)

struct LevelBadgeCompactView: View {
    let xp: Int

    private var manager: LevelManager { LevelManager.shared }
    private var level: LevelManager.Level { manager.currentLevel(xp: xp) }

    var body: some View {
        HStack(spacing: LadderSpacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundStyle(LadderColors.primary)
            Text("Lv.\(level.number) \(level.name)")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LevelBadgeView(xp: 0)
            .padding()
            .background(LadderColors.primary)

        LevelBadgeView(xp: 150)
            .padding()
            .background(LadderColors.primary)

        LevelBadgeView(xp: 650)
            .padding()
            .background(LadderColors.primary)

        LevelBadgeView(xp: 1200)
            .padding()
            .background(LadderColors.primary)

        LevelBadgeCompactView(xp: 300)
    }
}
