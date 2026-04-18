import SwiftUI

// MARK: - Reusable Line Chart
// Drawn with SwiftUI Path + GeometryReader. No Charts framework.

struct LineChartView: View {
    let data: [(Date, Double)]
    var targetLine: Double? = nil
    var lineColor: Color = LadderColors.primary
    var fillGradient: Bool = true
    var showPoints: Bool = true

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let inset: CGFloat = 8

            if data.count >= 2 {
                let sortedData = data.sorted { $0.0 < $1.0 }
                let values = sortedData.map { $0.1 }
                let minVal = (values.min() ?? 0) - 20
                let maxVal = max((values.max() ?? 100) + 20, (targetLine ?? 0) + 40)
                let range = max(maxVal - minVal, 1)

                ZStack {
                    // Subtle grid lines
                    ForEach(0..<4, id: \.self) { i in
                        let yFrac = CGFloat(i) / 3.0
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: height * yFrac))
                            path.addLine(to: CGPoint(x: width, y: height * yFrac))
                        }
                        .stroke(LadderColors.outlineVariant.opacity(0.2), lineWidth: 0.5)
                    }

                    // Target line
                    if let target = targetLine {
                        let targetY = height - inset - CGFloat((target - minVal) / range) * (height - inset * 2)
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: targetY))
                            path.addLine(to: CGPoint(x: width, y: targetY))
                        }
                        .stroke(LadderColors.accentLime.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    }

                    // Fill gradient under line
                    if fillGradient {
                        Path { path in
                            for (index, point) in sortedData.enumerated() {
                                let x = inset + CGFloat(index) / CGFloat(sortedData.count - 1) * (width - inset * 2)
                                let y = height - inset - CGFloat((point.1 - minVal) / range) * (height - inset * 2)
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                            let lastX = inset + CGFloat(sortedData.count - 1) / CGFloat(sortedData.count - 1) * (width - inset * 2)
                            path.addLine(to: CGPoint(x: lastX, y: height - inset))
                            path.addLine(to: CGPoint(x: inset, y: height - inset))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [lineColor.opacity(0.2), lineColor.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }

                    // Line path
                    Path { path in
                        for (index, point) in sortedData.enumerated() {
                            let x = inset + CGFloat(index) / CGFloat(sortedData.count - 1) * (width - inset * 2)
                            let y = height - inset - CGFloat((point.1 - minVal) / range) * (height - inset * 2)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    // Data points
                    if showPoints {
                        ForEach(Array(sortedData.enumerated()), id: \.offset) { index, point in
                            let x = inset + CGFloat(index) / CGFloat(sortedData.count - 1) * (width - inset * 2)
                            let y = height - inset - CGFloat((point.1 - minVal) / range) * (height - inset * 2)
                            Circle()
                                .fill(lineColor)
                                .frame(width: 10, height: 10)
                                .position(x: x, y: y)
                        }
                    }
                }
            } else {
                Text("Add scores to see your chart")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    let sampleData: [(Date, Double)] = [
        (Calendar.current.date(byAdding: .month, value: -4, to: Date())!, 1250),
        (Calendar.current.date(byAdding: .month, value: -2, to: Date())!, 1340),
        (Date(), 1380)
    ]
    LineChartView(data: sampleData, targetLine: 1400, lineColor: LadderColors.primary)
        .frame(height: 200)
        .padding(24)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))
        .padding(24)
        .background(LadderColors.surface)
}
