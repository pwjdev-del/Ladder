import SwiftUI
import SwiftData

// MARK: - Score Improvement View

struct ScoreImprovementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]
    @State private var currentScoreOverride: Int?
    @State private var targetScoreOverride: Int?

    private var currentScore: Int {
        currentScoreOverride ?? profiles.first?.satScore ?? 1250
    }
    private var targetScore: Int {
        targetScoreOverride ?? max((profiles.first?.satScore ?? 1200) + 100, 1500)
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
                Text("Score Strategy")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private var iPhoneLayout: some View {
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
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                HStack(alignment: .top, spacing: LadderSpacing.xl) {
                    iPadScoresColumn
                        .frame(maxWidth: .infinity)
                    iPadTimelineColumn
                        .frame(maxWidth: .infinity)
                }
                .padding(LadderSpacing.xl)
                .frame(maxWidth: 1400)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var iPadScoresColumn: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            // Hero card
            VStack(spacing: LadderSpacing.lg) {
                Text("YOUR SAT JOURNEY")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                HStack(spacing: LadderSpacing.xl) {
                    iPadScoreCircle(value: currentScore, label: "Current", color: LadderColors.onSurfaceVariant, size: 140)

                    VStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(LadderColors.accentLime)
                        Text("+\(targetScore - currentScore)")
                            .font(LadderTypography.titleLarge)
                            .foregroundStyle(LadderColors.primary)
                        Text("points to go")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                    }

                    iPadScoreCircle(value: targetScore, label: "Target", color: LadderColors.accentLime, size: 140)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(LadderSpacing.xl)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
            .ladderShadow(LadderElevation.ambient)

            // Gap analysis cards
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("GAP ANALYSIS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                HStack(spacing: LadderSpacing.md) {
                    gapCard(label: "Reading & Writing", current: 620, target: 700)
                    gapCard(label: "Math", current: 630, target: 700)
                }
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
    }

    private var iPadTimelineColumn: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Text("8-WEEK STUDY PLAN")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                Spacer()
                Text("~6 hrs/week")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.primary)
                    .labelTracking()
            }

            timelinePhase(
                weekRange: "Weeks 1-2",
                title: "Diagnostic Phase",
                hours: "4 hrs/week",
                icon: "magnifyingglass",
                color: LadderColors.primary,
                tasks: [
                    "Take a full-length practice test",
                    "Identify your weakest sections",
                    "Set up Khan Academy SAT Prep"
                ]
            )

            timelinePhase(
                weekRange: "Weeks 3-6",
                title: "Targeted Practice",
                hours: "6 hrs/week",
                icon: "target",
                color: LadderColors.accentLime,
                tasks: [
                    "30-45 min daily focused practice",
                    "Review every wrong answer",
                    "Focus on Reading: evidence-based questions",
                    "Focus on Math: algebra and data analysis"
                ]
            )

            timelinePhase(
                weekRange: "Weeks 7-8",
                title: "Full Practice Tests",
                hours: "8 hrs/week",
                icon: "timer",
                color: LadderColors.tertiary,
                tasks: [
                    "Take 2-3 practice tests under real conditions",
                    "Review timing strategies",
                    "Identify remaining weak spots"
                ]
            )

            timelinePhase(
                weekRange: "Test Day",
                title: "Final Preparation",
                hours: "Rest",
                icon: "star.fill",
                color: LadderColors.secondaryFixed,
                tasks: [
                    "Light review only the night before",
                    "Get 8+ hours of sleep",
                    "Bring calculator, #2 pencils, ID, admission ticket"
                ],
                isLast: true
            )
        }
    }

    private func iPadScoreCircle(value: Int, label: String, color: Color, size: CGFloat) -> some View {
        VStack(spacing: LadderSpacing.sm) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: size, height: size)
                Text("\(value)")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(color)
                    .editorialTracking()
            }
            Text(label)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
        }
    }

    private func gapCard(label: String, current: Int, target: Int) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text(label)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
            HStack(alignment: .firstTextBaseline, spacing: LadderSpacing.xs) {
                Text("\(current)")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text("→ \(target)")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            LinearProgressBar(progress: Double(current) / Double(target))
            Text("+\(target - current) to target")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.primary)
        }
        .padding(LadderSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    private func timelinePhase(weekRange: String, title: String, hours: String, icon: String, color: Color, tasks: [String], isLast: Bool = false) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(color)
                }
                if !isLast {
                    Rectangle()
                        .fill(LadderColors.outlineVariant)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, LadderSpacing.xs)
                }
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                HStack {
                    Text(weekRange)
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(color)
                        .labelTracking()
                    Spacer()
                    Text(hours)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Text(title)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(tasks, id: \.self) { task in
                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(task)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }
            .padding(LadderSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
            .padding(.bottom, isLast ? 0 : LadderSpacing.sm)
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
