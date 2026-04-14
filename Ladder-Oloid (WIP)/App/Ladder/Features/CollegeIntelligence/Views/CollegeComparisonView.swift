import SwiftUI

// MARK: - College Comparison View (D3)
// Multi-column comparison table. iPad uses wide side-by-side table, iPhone
// stacks college cards vertically with labeled rows.

struct CollegeComparisonView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    let leftId: String
    let rightId: String

    @State private var activeLeftId: String?
    @State private var activeRightId: String?
    @State private var didInit = false

    private var leftCollege: CollegeListItem? {
        guard let id = activeLeftId else { return nil }
        return CollegeListItem.sampleColleges.first { $0.id == id }
    }

    private var rightCollege: CollegeListItem? {
        guard let id = activeRightId else { return nil }
        if id.isEmpty {
            return CollegeListItem.sampleColleges.first { $0.id != activeLeftId }
        }
        return CollegeListItem.sampleColleges.first { $0.id == id }
    }

    // Comparison rows defined once so both layouts stay in sync
    private struct CompareRow: Identifiable {
        let id = UUID()
        let label: String
        let left: String
        let right: String
        let leftBetter: Bool?
    }

    private func rows(_ a: CollegeListItem?, _ b: CollegeListItem?) -> [CompareRow] {
        guard let a, let b else { return [] }
        func pct(_ v: Double?) -> String { v.map { "\(Int($0 * 100))%" } ?? "N/A" }
        func money(_ v: Int?) -> String { v.map { "$\(formatNumber($0))" } ?? "N/A" }
        func num(_ v: Int?) -> String { v.map { formatNumber($0) } ?? "N/A" }

        return [
            CompareRow(label: "Acceptance Rate", left: pct(a.acceptanceRate), right: pct(b.acceptanceRate),
                       leftBetter: compareDouble(a.acceptanceRate, b.acceptanceRate, higherBetter: true)),
            CompareRow(label: "Tuition", left: money(a.tuition), right: money(b.tuition),
                       leftBetter: compareInt(a.tuition, b.tuition, higherBetter: false)),
            CompareRow(label: "SAT Range", left: a.satRange ?? "N/A", right: b.satRange ?? "N/A",
                       leftBetter: nil),
            CompareRow(label: "ACT Range", left: "28-33", right: "26-31", leftBetter: nil),
            CompareRow(label: "Enrollment", left: num(a.enrollment), right: num(b.enrollment),
                       leftBetter: nil),
            CompareRow(label: "Graduation Rate", left: "86%", right: "78%", leftBetter: true),
            CompareRow(label: "Student-Faculty", left: "12:1", right: "16:1", leftBetter: true),
            CompareRow(label: "Campus Size", left: "1,200 acres", right: "450 acres", leftBetter: nil),
            CompareRow(label: "Setting", left: "Suburban", right: "Urban", leftBetter: nil),
            CompareRow(label: "Match %", left: "\(a.matchPercent ?? 0)%", right: "\(b.matchPercent ?? 0)%",
                       leftBetter: compareInt(a.matchPercent, b.matchPercent, higherBetter: true)),
            CompareRow(label: "Deadline", left: "Nov 1, 2026", right: "Jan 15, 2027", leftBetter: nil),
            CompareRow(label: "Application Fee", left: "$75", right: "$60", leftBetter: false),
        ]
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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
        }
        .onAppear {
            if !didInit {
                activeLeftId = leftId
                activeRightId = rightId.isEmpty ? nil : rightId
                didInit = true
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    header

                    // Stacked college photos + remove
                    VStack(spacing: LadderSpacing.md) {
                        collegeSlot(leftCollege, side: "A")
                        collegeSlot(rightCollege, side: "B")
                    }
                    .padding(.horizontal, LadderSpacing.md)

                    // Comparison rows (stacked)
                    VStack(spacing: LadderSpacing.sm) {
                        ForEach(rows(leftCollege, rightCollege)) { row in
                            iPhoneRow(row)
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)

                    aiCard
                        .padding(.horizontal, LadderSpacing.md)
                }
                .padding(.bottom, 120)
            }
        }
    }

    private func iPhoneRow(_ row: CompareRow) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(row.label.uppercased())
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            HStack(spacing: LadderSpacing.md) {
                valueCell(row.left, highlighted: row.leftBetter == true)
                valueCell(row.right, highlighted: row.leftBetter == false)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    // MARK: - iPad Layout (wide side-by-side table)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                    header

                    // Selector slots row — photos side by side
                    HStack(spacing: LadderSpacing.lg) {
                        collegeSlot(leftCollege, side: "A")
                        collegeSlot(rightCollege, side: "B")

                        // Add third slot placeholder
                        addSlotPlaceholder
                    }

                    // Wide comparison table
                    LadderCard {
                        VStack(spacing: 0) {
                            // Table header
                            HStack {
                                Text("METRIC")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .labelTracking()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(leftCollege?.name ?? "School A")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Text(rightCollege?.name ?? "School B")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.vertical, LadderSpacing.sm)

                            ForEach(rows(leftCollege, rightCollege)) { row in
                                HStack {
                                    Text(row.label)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    tableCell(row.left, highlighted: row.leftBetter == true)
                                        .frame(maxWidth: .infinity)

                                    tableCell(row.right, highlighted: row.leftBetter == false)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.vertical, LadderSpacing.md)
                                .background(
                                    row.id.hashValue % 2 == 0
                                        ? Color.clear
                                        : LadderColors.surface.opacity(0.5)
                                )
                            }
                        }
                    }

                    aiCard
                }
                .padding(LadderSpacing.xl)
                .padding(.bottom, LadderSpacing.xxxxl)
            }
        }
    }

    // MARK: - Shared components

    private var header: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("COLLEGE INTELLIGENCE")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.secondaryFixed)
                .labelTracking()

            Text("Compare Schools")
                .font(sizeClass == .regular ? LadderTypography.displaySmall : LadderTypography.headlineLarge)
                .foregroundStyle(.white)
                .editorialTracking()

            Text("Side-by-side breakdown to help you decide")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(LadderSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func collegeSlot(_ college: CollegeListItem?, side: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [LadderColors.primaryContainer, LadderColors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: sizeClass == .regular ? 160 : 120)
                    .overlay(
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.25))
                    )

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if side == "A" {
                        activeLeftId = nil
                    } else {
                        activeRightId = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(LadderSpacing.sm)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(LadderSpacing.sm)
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

            if let college {
                Text(college.name)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(1)
                Text(college.location)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            } else {
                Text("School \(side)")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private var addSlotPlaceholder: some View {
        VStack(spacing: LadderSpacing.sm) {
            Image(systemName: "plus.circle")
                .font(.system(size: 32))
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("Add College")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                .strokeBorder(LadderColors.outlineVariant, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        )
    }

    private func valueCell(_ value: String, highlighted: Bool) -> some View {
        Text(value)
            .font(LadderTypography.titleSmall)
            .foregroundStyle(highlighted ? LadderColors.onSecondaryFixed : LadderColors.onSurface)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.sm)
            .background(highlighted ? LadderColors.secondaryFixed : LadderColors.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
    }

    private func tableCell(_ value: String, highlighted: Bool) -> some View {
        Text(value)
            .font(LadderTypography.titleSmall)
            .foregroundStyle(highlighted ? LadderColors.onSecondaryFixed : LadderColors.onSurface)
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.xs)
            .background(
                Group {
                    if highlighted {
                        Capsule().fill(LadderColors.secondaryFixed)
                    } else {
                        Color.clear
                    }
                }
            )
    }

    private var aiCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(LadderColors.accentLime)
                    Text("AI INSIGHT")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                }

                Text("Which is right for me?")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .editorialTracking()

                Text("\(leftCollege?.name ?? "School A") offers stronger graduation outcomes and a lower student-faculty ratio, while \(rightCollege?.name ?? "School B") has a more accessible acceptance rate and urban setting. Based on your profile, consider your priorities around campus culture and cost.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }

    // MARK: - Helpers

    private func compareDouble(_ a: Double?, _ b: Double?, higherBetter: Bool) -> Bool? {
        guard let a, let b, a != b else { return nil }
        return higherBetter ? a > b : a < b
    }

    private func compareInt(_ a: Int?, _ b: Int?, higherBetter: Bool) -> Bool? {
        guard let a, let b, a != b else { return nil }
        return higherBetter ? a > b : a < b
    }

    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

#Preview {
    NavigationStack {
        CollegeComparisonView(leftId: "rit", rightId: "mit")
            .environment(AppCoordinator())
    }
}
