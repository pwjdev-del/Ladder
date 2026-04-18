import SwiftUI

// MARK: - Reusable Horizontal Bar Chart

struct BarChartView: View {
    let data: [(label: String, value: Double, color: Color)]
    var maxValue: Double = 1.0
    var barHeight: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                HStack(spacing: LadderSpacing.sm) {
                    Text(item.label)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(width: 100, alignment: .trailing)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LadderColors.surfaceContainerLow)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(item.color)
                                .frame(width: max(4, geo.size.width * CGFloat(item.value / maxValue)))
                        }
                    }
                    .frame(height: barHeight)
                }
            }
        }
    }
}
