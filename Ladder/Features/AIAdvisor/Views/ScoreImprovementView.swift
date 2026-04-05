import SwiftUI

// MARK: - Score Improvement View

struct ScoreImprovementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentScore = 1250
    @State private var targetScore = 1400

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Current vs Target
                    LadderCard(elevated: true) {
                        VStack(spacing: LadderSpacing.md) {
                            Text("Your SAT Journey")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            HStack(spacing: LadderSpacing.xl) {
                                scoreCircle(value: currentScore, label: "Current", color: LadderColors.onSurfaceVariant)

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 24))
                                    .foregroundStyle(LadderColors.accentLime)

                                scoreCircle(value: targetScore, label: "Target", color: LadderColors.accentLime)
                            }

                            Text("You need \(targetScore - currentScore) more points")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    // Study Plan
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("RECOMMENDED PLAN")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        planWeek("Weeks 1-2", title: "Diagnostic Phase", tasks: [
                            "Take a full-length practice test",
                            "Identify your weakest sections",
                            "Set up Khan Academy SAT Prep"
                        ], icon: "magnifyingglass")

                        planWeek("Weeks 3-6", title: "Targeted Practice", tasks: [
                            "30-45 min daily focused practice",
                            "Review every wrong answer",
                            "Focus on Reading: evidence-based questions",
                            "Focus on Math: algebra and data analysis"
                        ], icon: "target")

                        planWeek("Weeks 7-8", title: "Full Practice Tests", tasks: [
                            "Take 2-3 practice tests under real conditions",
                            "Review timing strategies",
                            "Identify remaining weak spots"
                        ], icon: "timer")

                        planWeek("Test Day", title: "Final Preparation", tasks: [
                            "Light review only the night before",
                            "Get 8+ hours of sleep",
                            "Bring calculator, #2 pencils, ID, admission ticket"
                        ], icon: "star")
                    }

                    // Resources
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("FREE RESOURCES")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        resourceRow("Khan Academy SAT Prep", description: "Free, official practice from College Board", icon: "graduationcap")
                        resourceRow("College Board Practice Tests", description: "8 free official practice tests", icon: "doc.text")
                        resourceRow("Fee Waivers", description: "If eligible, take the SAT for free (2 attempts)", icon: "dollarsign.circle")
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
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
                Text("Score Strategy")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private func scoreCircle(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)

                Text("\(value)")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(color)
            }
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private func planWeek(_ week: String, title: String, tasks: [String], icon: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 36, height: 36)
                .background(LadderColors.primaryContainer.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(week)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                ForEach(tasks, id: \.self) { task in
                    HStack(alignment: .top, spacing: LadderSpacing.xs) {
                        Image(systemName: "circle")
                            .font(.system(size: 6))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .padding(.top, 6)
                        Text(task)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func resourceRow(_ title: String, description: String, icon: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 36, height: 36)
                .background(LadderColors.primaryContainer.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(description)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ScoreImprovementView()
    }
}
