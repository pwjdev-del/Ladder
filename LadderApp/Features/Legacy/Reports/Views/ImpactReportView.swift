import SwiftUI
import SwiftData

// MARK: - Impact Report View

struct ImpactReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var appCount = 0
    @State private var acceptedCount = 0
    @State private var totalAid = 0

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [LadderColors.primary, LadderColors.primaryContainer],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(height: 180)

                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("Your Impact Report")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(.white)
                            Text("2025-2026 Application Cycle")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(LadderSpacing.lg)
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                        statCard("Applications", "\(appCount)", "paperplane.fill")
                        statCard("Accepted", "\(acceptedCount)", "checkmark.circle.fill")
                        statCard("Total Aid", "$\(totalAid.formatted())", "banknote.fill")
                        statCard("Completion", "85%", "chart.line.uptrend.xyaxis")
                    }
                    .padding(.horizontal, LadderSpacing.lg)

                    // Milestones
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Key Milestones")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            milestoneRow("First college saved", "September 2025", true)
                            milestoneRow("SAT score improved", "+120 points", true)
                            milestoneRow("Applications submitted", "\(appCount) schools", appCount > 0)
                            milestoneRow("Acceptances received", "\(acceptedCount) schools", acceptedCount > 0)
                            milestoneRow("Decision made", "Committed", false)
                        }
                    }
                    .padding(.horizontal, LadderSpacing.lg)

                    // Share button
                    ShareLink(item: "I used Ladder to apply to \(appCount) colleges and got accepted to \(acceptedCount)! 🎓") {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share My Report")
                        }
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primary)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, LadderSpacing.lg)
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(.white)
                }
            }
        }
        .task { loadStats() }
    }

    @ViewBuilder
    private func statCard(_ title: String, _ value: String, _ icon: String) -> some View {
        LadderCard {
            VStack(spacing: LadderSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(LadderColors.primary)
                Text(value)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(title)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func milestoneRow(_ title: String, _ detail: String, _ completed: Bool) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(completed ? LadderColors.primary : LadderColors.outlineVariant)
            Text(title)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
            Text(detail)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private func loadStats() {
        let appDescriptor = FetchDescriptor<ApplicationModel>()
        if let apps = try? context.fetch(appDescriptor) {
            appCount = apps.count
            acceptedCount = apps.filter { $0.status == "accepted" || $0.status == "committed" }.count
        }
        let aidDescriptor = FetchDescriptor<FinancialAidPackageModel>()
        if let aids = try? context.fetch(aidDescriptor) {
            totalAid = aids.reduce(0) { $0 + $1.totalAid }
        }
    }
}
