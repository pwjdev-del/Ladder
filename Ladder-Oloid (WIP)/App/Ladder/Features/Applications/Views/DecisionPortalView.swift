import SwiftUI

// MARK: - Decision Portal View

struct DecisionPortalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let mockDecisions: [(String, String, String, Color)] = [
        ("Stanford University", "Accepted", "March 28", LadderColors.accentLime),
        ("MIT", "Waitlisted", "March 14", LadderColors.tertiary),
        ("Harvard", "Pending", "Decision Apr 1", LadderColors.outlineVariant),
        ("Yale", "Denied", "March 30", LadderColors.error),
        ("Princeton", "Accepted", "March 25", LadderColors.accentLime),
        ("Columbia", "Pending", "Decision Apr 2", LadderColors.outlineVariant),
        ("Brown", "Waitlisted", "March 20", LadderColors.tertiary),
        ("Cornell", "Accepted", "March 18", LadderColors.accentLime),
    ]

    private let statuses = ["Accepted", "Waitlisted", "Pending", "Denied"]

    private func decisions(for status: String) -> [(String, String, String, Color)] {
        mockDecisions.filter { $0.1 == status }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Accepted": return LadderColors.accentLime
        case "Waitlisted": return LadderColors.tertiary
        case "Denied": return LadderColors.error
        default: return LadderColors.outlineVariant
        }
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
            ToolbarItem(placement: .principal) {
                Text("Decision Portal")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: LadderSpacing.md) {
            ForEach(statuses, id: \.self) { status in
                statCard(status: status)
            }
        }
    }

    private func statCard(status: String) -> some View {
        let count = decisions(for: status).count
        return LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(status.uppercased())
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                Text("\(count)")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(statusColor(status))
                    .editorialTracking()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Decision Card

    private func decisionCard(_ decision: (String, String, String, Color)) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Circle()
                        .fill(LadderColors.primaryContainer)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(decision.0.prefix(1)))
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.primary)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(decision.0)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineLimit(1)
                        Text(decision.2)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                }

                Text(decision.1.uppercased())
                    .font(LadderTypography.labelSmall)
                    .labelTracking()
                    .foregroundStyle(decision.3)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, 4)
                    .background(decision.3.opacity(0.15))
                    .clipShape(Capsule())

                HStack(spacing: LadderSpacing.xs) {
                    Button {
                        let collegeId = decision.0
                            .lowercased()
                            .replacingOccurrences(of: " university", with: "")
                            .replacingOccurrences(of: " ", with: "-")
                        coordinator.navigate(to: .collegeProfile(collegeId: collegeId))
                    } label: {
                        Text("View")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                    }
                    .buttonStyle(.plain)

                    Button {
                        let collegeId = decision.0
                            .lowercased()
                            .replacingOccurrences(of: " university", with: "")
                            .replacingOccurrences(of: " ", with: "-")
                        coordinator.navigate(to: .lociGenerator(collegeId: collegeId))
                    } label: {
                        Text("Reply")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    statsRow

                    ForEach(statuses, id: \.self) { status in
                        let items = decisions(for: status)
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                HStack {
                                    Circle()
                                        .fill(statusColor(status))
                                        .frame(width: 10, height: 10)
                                    Text(status.uppercased())
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                        .labelTracking()
                                    Spacer()
                                    Text("\(items.count)")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }

                                ForEach(items, id: \.0) { item in
                                    decisionCard(item)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: LadderSpacing.lg) {
                statsRow
                    .padding(.horizontal, LadderSpacing.xl)
                    .padding(.top, LadderSpacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: LadderSpacing.lg) {
                        ForEach(statuses, id: \.self) { status in
                            kanbanColumn(status: status)
                        }
                    }
                    .padding(.horizontal, LadderSpacing.xl)
                    .padding(.bottom, LadderSpacing.xxl)
                }
            }
        }
    }

    private func kanbanColumn(status: String) -> some View {
        let items = decisions(for: status)
        return VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Circle()
                    .fill(statusColor(status))
                    .frame(width: 10, height: 10)
                Text(status.uppercased())
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .labelTracking()
                Spacer()
                Text("\(items.count)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.horizontal, LadderSpacing.xs)
                    .padding(.vertical, 2)
                    .background(LadderColors.surfaceContainerHigh)
                    .clipShape(Capsule())
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    ForEach(items, id: \.0) { item in
                        decisionCard(item)
                    }

                    if items.isEmpty {
                        Text("No colleges")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(LadderSpacing.lg)
                    }
                }
            }
        }
        .padding(LadderSpacing.md)
        .frame(width: 320)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        DecisionPortalView()
            .environment(AppCoordinator())
    }
}
