import SwiftUI

// MARK: - Impact Report
// Batch_10_Reports_Parent M5 — student impact dashboard.
// Mock data: hours, dollars raised, people impacted, awards, timeline, achievements.

struct ImpactReportView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    // MARK: - Mock Data

    struct MonthPoint: Identifiable {
        let id = UUID()
        let label: String
        let cumulative: Double
    }

    struct Achievement: Identifiable {
        let id = UUID()
        let title: String
        let detail: String
        let icon: String
    }

    private let timeline: [MonthPoint] = [
        .init(label: "Sep", cumulative: 12),
        .init(label: "Oct", cumulative: 28),
        .init(label: "Nov", cumulative: 46),
        .init(label: "Dec", cumulative: 61),
        .init(label: "Jan", cumulative: 84),
        .init(label: "Feb", cumulative: 108),
        .init(label: "Mar", cumulative: 142),
        .init(label: "Apr", cumulative: 178),
    ]

    private let achievements: [Achievement] = [
        .init(title: "Congressional App Challenge", detail: "District winner · iOS accessibility app", icon: "trophy.fill"),
        .init(title: "Organized Coding Bootcamp", detail: "42 middle schoolers across 6 weeks", icon: "person.3.fill"),
        .init(title: "Climate Fundraiser Lead", detail: "Raised $4,200 for local reforestation", icon: "leaf.fill"),
        .init(title: "AP Scholar with Distinction", detail: "5 exams, avg score 4.8", icon: "graduationcap.fill"),
    ]

    // MARK: - Body

    var body: some View {
        Group {
            if sizeClass == .regular { iPadLayout } else { iPhoneLayout }
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("Impact Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                header
                statsGrid(columns: 2)
                timelineCard
                achievementsCard
                shareButton
            }
            .padding(LadderSpacing.lg)
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                header
                statsGrid(columns: 4)
                HStack(alignment: .top, spacing: LadderSpacing.lg) {
                    timelineCard.frame(maxWidth: .infinity)
                    achievementsCard.frame(maxWidth: .infinity)
                }
                shareButton
            }
            .padding(LadderSpacing.xxl)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text("2025-26 · SENIOR YEAR")
                .font(LadderTypography.labelMedium)
                .labelTracking()
                .foregroundStyle(LadderColors.primary)
            Text("Your Impact, So Far")
                .font(LadderTypography.headlineLarge)
                .editorialTracking()
                .foregroundStyle(LadderColors.onSurface)
            Text("A shareable snapshot of everything you've done this year.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private func statsGrid(columns: Int) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LadderSpacing.md), count: columns),
                  spacing: LadderSpacing.md) {
            statCard(icon: "clock.fill", value: "178", label: "Service hours", tint: LadderColors.primary)
            statCard(icon: "dollarsign.circle.fill", value: "$4,200", label: "Dollars raised", tint: LadderColors.accentLime)
            statCard(icon: "person.3.fill", value: "312", label: "People impacted", tint: LadderColors.secondaryFixed)
            statCard(icon: "rosette", value: "11", label: "Awards earned", tint: LadderColors.tertiary)
        }
    }

    private func statCard(icon: String, value: String, label: String, tint: Color) -> some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                ZStack {
                    Circle().fill(tint.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                }
                Text(value)
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text(label.uppercased())
                    .font(LadderTypography.labelSmall)
                    .labelTracking()
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var timelineCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text("Cumulative Impact")
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("Service hours over the school year")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                TimelineChart(points: timeline)
                    .frame(height: 200)

                HStack {
                    ForEach(timeline) { p in
                        Text(p.label)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private var achievementsCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Top Achievements")
                    .font(LadderTypography.titleLarge)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(achievements) { a in
                    HStack(alignment: .top, spacing: LadderSpacing.md) {
                        ZStack {
                            Circle().fill(LadderColors.primaryContainer)
                                .frame(width: 40, height: 40)
                            Image(systemName: a.icon)
                                .foregroundStyle(LadderColors.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(a.detail)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                    }
                    if a.id != achievements.last?.id {
                        Divider().background(LadderColors.outlineVariant)
                    }
                }
            }
        }
    }

    private var shareButton: some View {
        LadderPrimaryButton("Share Impact Report", icon: "square.and.arrow.up") {}
    }
}

// MARK: - Lightweight line chart

private struct TimelineChart: View {
    let points: [ImpactReportView.MonthPoint]

    var body: some View {
        GeometryReader { geo in
            let maxVal = points.map(\.cumulative).max() ?? 1
            let step = points.count > 1 ? geo.size.width / CGFloat(points.count - 1) : 0

            ZStack {
                // Gridlines
                VStack(spacing: 0) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(LadderColors.outlineVariant.opacity(0.4))
                            .frame(height: 1)
                        Spacer()
                    }
                    Rectangle()
                        .fill(LadderColors.outlineVariant.opacity(0.4))
                        .frame(height: 1)
                }

                // Area under line
                Path { p in
                    guard !points.isEmpty else { return }
                    p.move(to: CGPoint(x: 0, y: geo.size.height))
                    for (i, point) in points.enumerated() {
                        let x = CGFloat(i) * step
                        let y = geo.size.height - (CGFloat(point.cumulative / maxVal) * geo.size.height)
                        p.addLine(to: CGPoint(x: x, y: y))
                    }
                    p.addLine(to: CGPoint(x: CGFloat(points.count - 1) * step, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [LadderColors.primary.opacity(0.35), LadderColors.primary.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom
                ))

                // Line
                Path { p in
                    guard !points.isEmpty else { return }
                    for (i, point) in points.enumerated() {
                        let x = CGFloat(i) * step
                        let y = geo.size.height - (CGFloat(point.cumulative / maxVal) * geo.size.height)
                        if i == 0 {
                            p.move(to: CGPoint(x: x, y: y))
                        } else {
                            p.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(LadderColors.primary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(Array(points.enumerated()), id: \.offset) { i, point in
                    let x = CGFloat(i) * step
                    let y = geo.size.height - (CGFloat(point.cumulative / maxVal) * geo.size.height)
                    Circle()
                        .fill(LadderColors.primary)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}
