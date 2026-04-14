import SwiftUI
import SwiftData

// MARK: - Match Score Detail View (D4)
// Two-column on iPad (55/45): left = big match ring + factor breakdown,
// right = how to improve + similar colleges + what-if sim link.

struct MatchScoreView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]

    private var userGPA: String { profiles.first?.gpa.map { String(format: "%.2f", $0) } ?? "3.5" }
    private var userSAT: String { profiles.first?.satScore.map { "\($0)" } ?? "1200" }

    let collegeId: String

    private var college: CollegeListItem? {
        CollegeListItem.sampleColleges.first { $0.id == collegeId }
    }

    // MARK: - Factor model

    private struct Factor: Identifiable {
        let id = UUID()
        let name: String
        let score: Double // 0.0 - 1.0
        let detail: String
    }

    private enum FactorLevel {
        case strong, moderate, weak
    }

    private func level(_ score: Double) -> FactorLevel {
        if score >= 0.75 { return .strong }
        if score >= 0.5 { return .moderate }
        return .weak
    }

    private func color(for level: FactorLevel) -> Color {
        switch level {
        case .strong: return LadderColors.accentLime
        case .moderate: return LadderColors.tertiary
        case .weak: return LadderColors.error
        }
    }

    private var factors: [Factor] {
        [
            Factor(name: "GPA",          score: 0.85, detail: "Your \(userGPA) GPA aligns with their admitted range."),
            Factor(name: "Test Scores",  score: 0.72, detail: "Your \(userSAT) SAT falls in the middle 50%."),
            Factor(name: "Major Fit",    score: 0.92, detail: "Computer Science is a top-ranked program here."),
            Factor(name: "Location",     score: 0.60, detail: "Preferred region partial match."),
            Factor(name: "Financial Fit",score: 0.45, detail: "Net cost above your preferred range."),
            Factor(name: "Culture Fit",  score: 0.80, detail: "Strong alignment with your personality type."),
            Factor(name: "Size",         score: 0.70, detail: "Medium campus matches your preference.")
        ]
    }

    private var overallMatch: Int {
        college?.matchPercent ?? 75
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
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    overallCard
                        .padding(.horizontal, LadderSpacing.md)

                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("How We Calculate")
                            .font(LadderTypography.titleLarge)
                            .foregroundStyle(LadderColors.onSurface)
                            .editorialTracking()

                        ForEach(factors) { factor in
                            factorRow(factor)
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)

                    improveCard
                        .padding(.horizontal, LadderSpacing.md)

                    similarColleges
                        .padding(.horizontal, LadderSpacing.md)

                    whatIfCard
                        .padding(.horizontal, LadderSpacing.md)
                }
                .padding(.top, LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout (two-column 55/45)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(alignment: .top, spacing: LadderSpacing.xl) {
                // Left column 55%
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                        overallCard

                        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                            Text("How We Calculate")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .editorialTracking()

                            Text("Each factor is weighted based on fit with your profile. Tap any factor to see the full rationale.")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            VStack(spacing: LadderSpacing.md) {
                                ForEach(factors) { factor in
                                    factorRow(factor)
                                }
                            }
                        }
                    }
                    .padding(.leading, LadderSpacing.xl)
                    .padding(.vertical, LadderSpacing.xl)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // Right column 45%
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        improveCard
                        similarColleges
                        whatIfCard
                    }
                    .padding(.trailing, LadderSpacing.xl)
                    .padding(.vertical, LadderSpacing.xl)
                }
                .frame(width: 440)
            }
        }
    }

    // MARK: - Shared pieces

    private var overallCard: some View {
        LadderCard(elevated: true) {
            HStack(spacing: LadderSpacing.lg) {
                CircularProgressView(
                    progress: Double(overallMatch) / 100.0,
                    label: "\(overallMatch)%",
                    sublabel: "Match",
                    size: sizeClass == .regular ? 180 : 140
                )
                .ladderShadow(LadderElevation.glow)

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("OVERALL MATCH")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    Text(college?.name ?? "College")
                        .font(sizeClass == .regular ? LadderTypography.headlineMedium : LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text(college?.location ?? "")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Text(overallMatch >= 75 ? "Strong Match" : overallMatch >= 40 ? "Good Match" : "Reach School")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSecondaryFixed)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(LadderColors.secondaryFixed)
                        .clipShape(Capsule())
                        .padding(.top, LadderSpacing.xs)
                }

                Spacer()
            }
        }
    }

    private func factorRow(_ factor: Factor) -> some View {
        let lvl = level(factor.score)
        let barColor = color(for: lvl)
        return VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                Text(factor.name)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                Text("\(Int(factor.score * 100))%")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LadderColors.surfaceContainerHighest)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * factor.score, height: 8)
                }
            }
            .frame(height: 8)

            Text(factor.detail)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    private var improveCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(LadderColors.accentLime)
                    Text("HOW TO IMPROVE")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                }

                Text("Three ways to raise your score")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .editorialTracking()

                improveRow("Retake the SAT to reach 1400+", delta: "+8%")
                improveRow("Add a major-relevant EC", delta: "+5%")
                improveRow("Write a strong 'Why Us' essay", delta: "+3%")
            }
        }
    }

    private func improveRow(_ text: String, delta: String) -> some View {
        HStack {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundStyle(LadderColors.accentLime)
            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
            Text(delta)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSecondaryFixed)
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xxs)
                .background(LadderColors.secondaryFixed)
                .clipShape(Capsule())
        }
        .padding(.vertical, LadderSpacing.xs)
    }

    private var similarColleges: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Similar Colleges")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Schools with matching profiles")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                VStack(spacing: LadderSpacing.sm) {
                    ForEach(CollegeListItem.sampleColleges.prefix(3).filter { $0.id != collegeId }) { c in
                        Button {
                            coordinator.navigate(to: .collegeProfile(collegeId: c.id))
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                    Text(c.name)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .lineLimit(1)
                                    Text(c.location)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                                Spacer()
                                if let m = c.matchPercent {
                                    Text("\(m)%")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.onSecondaryFixed)
                                        .padding(.horizontal, LadderSpacing.sm)
                                        .padding(.vertical, LadderSpacing.xxs)
                                        .background(LadderColors.secondaryFixed)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(LadderSpacing.sm)
                            .background(LadderColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var whatIfCard: some View {
        Button {
            // Placeholder — could navigate to a what-if simulator route when available.
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text("What-If Simulator")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("See how score changes boost your match")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(LadderColors.primary)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.primaryContainer.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MatchScoreView(collegeId: "rit")
            .environment(AppCoordinator())
    }
}
