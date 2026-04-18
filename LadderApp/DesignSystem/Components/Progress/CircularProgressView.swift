import SwiftUI

// MARK: - Circular Progress View
// Donut chart with lime progress stroke and center label

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let label: String
    let sublabel: String?
    let size: CGFloat

    init(progress: Double, label: String, sublabel: String? = nil, size: CGFloat = 100) {
        self.progress = progress
        self.label = label
        self.sublabel = sublabel
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(LadderColors.surfaceContainerHighest, lineWidth: size * 0.08)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LadderColors.secondaryFixed,
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            // Center label
            VStack(spacing: 2) {
                Text(label)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                if let sublabel {
                    Text(sublabel)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Linear Progress Bar

struct LinearProgressBar: View {
    let progress: Double
    let height: CGFloat

    init(progress: Double, height: CGFloat = 8) {
        self.progress = progress
        self.height = height
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(LadderColors.surfaceContainerHighest)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [LadderColors.accentLime, LadderColors.secondaryFixed],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Ladder Tracker (Signature vertical glowing line)

struct LadderTracker: View {
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(LadderColors.secondaryFixed)
            .frame(width: 4, height: height)
            .ladderShadow(LadderElevation.glow)
    }
}

#Preview {
    VStack(spacing: 32) {
        CircularProgressView(progress: 0.6, label: "60%", sublabel: "Complete")
        LinearProgressBar(progress: 0.75)
        LadderTracker(height: 200)
    }
    .padding(32)
    .background(LadderColors.surface)
}
