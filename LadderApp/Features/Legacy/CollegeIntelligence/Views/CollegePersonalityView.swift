import SwiftUI
import SwiftData

// MARK: - College Personality View

struct CollegePersonalityView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let collegeId: String

    @State private var college: CollegeModel?

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Green gradient header
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [LadderColors.primary, LadderColors.primaryContainer],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(height: 200)

                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text(college?.personality?.archetypeName ?? "Loading...")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(.white)
                            Text(college?.name ?? "")
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(LadderSpacing.lg)
                    }

                    VStack(spacing: LadderSpacing.lg) {
                        // Archetype description
                        if let desc = college?.personality?.archetypeDescription {
                            LadderCard {
                                Text(desc)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                        }

                        // CDS C7 Admissions Factors
                        if let personality = college?.personality {
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                    Text("What They Value")
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)

                                    BarChartView(data: buildFactorData(personality))
                                }
                            }
                        }

                        // Culture Keywords
                        if let keywords = college?.personality?.cultureKeywords, !keywords.isEmpty {
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                    Text("Campus Culture")
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)

                                    FlowLayout(spacing: LadderSpacing.xs) {
                                        ForEach(keywords, id: \.self) { keyword in
                                            LadderFilterChip(title: keyword, isSelected: false) {}
                                        }
                                    }
                                }
                            }
                        }

                        // Traits
                        if let traits = college?.personality?.traits, !traits.isEmpty {
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                    Text("Key Traits")
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)

                                    ForEach(traits, id: \.self) { trait in
                                        HStack(spacing: LadderSpacing.sm) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(LadderColors.primary)
                                            Text(trait)
                                                .font(LadderTypography.bodyMedium)
                                                .foregroundStyle(LadderColors.onSurface)
                                        }
                                    }
                                }
                            }
                        }

                        // Quote
                        if let quote = college?.personality?.quote {
                            LadderCard {
                                VStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "quote.opening")
                                        .font(.title2)
                                        .foregroundStyle(LadderColors.primary)
                                    Text(quote)
                                        .font(LadderTypography.bodyLarge)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .italic()
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        // Testing Policy
                        if let policy = college?.testingPolicy {
                            LadderCard {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundStyle(LadderColors.primary)
                                    Text("Testing Policy")
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                    Text(policy)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .task { loadCollege() }
    }

    private func loadCollege() {
        let descriptor = FetchDescriptor<CollegeModel>(
            predicate: #Predicate { $0.scorecardId != nil }
        )
        if let results = try? context.fetch(descriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId || $0.name == collegeId }
        }
    }

    private func buildFactorData(_ p: CollegePersonalityModel) -> [(label: String, value: Double, color: Color)] {
        func importance(_ s: String?) -> Double {
            switch s?.lowercased() {
            case "very important": return 1.0
            case "important": return 0.75
            case "considered": return 0.5
            default: return 0.1
            }
        }
        return [
            ("Academic Rigor", importance(p.rigorImportance), LadderColors.primary),
            ("GPA", importance(p.gpaImportance), LadderColors.primary),
            ("Test Scores", importance(p.testScoreImportance), LadderColors.primaryContainer),
            ("Essays", importance(p.essayImportance), LadderColors.secondaryFixed),
            ("Extracurriculars", importance(p.extracurricularImportance), LadderColors.secondaryFixed),
            ("Interview", importance(p.interviewImportance), LadderColors.primaryContainer),
            ("Interest", importance(p.demonstratedInterestImportance), LadderColors.outlineVariant),
        ]
    }
}

// FlowLayout is defined in OnboardingContainerView.swift and shared across the app
