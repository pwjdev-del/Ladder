import SwiftUI
import SwiftData

// MARK: - Test Prep Resources View
// Curated SAT/ACT test prep resources with score goal calculator

struct TestPrepResourcesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var studentSATScore: Int = 0
    @State private var savedColleges: [CollegeScoreInfo] = []
    @State private var selectedPlan: StudyPlan? = nil

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    freeResourcesSection
                    studyPlansSection
                    scoreGoalsSection
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
                Text("Test Prep Resources")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task {
            loadData()
        }
    }

    // MARK: - Data Loading

    private func loadData() {
        // Load student SAT score
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        if let profiles = try? context.fetch(profileDescriptor), let profile = profiles.first {
            studentSATScore = profile.satScore ?? 0
        }

        // Load saved colleges with SAT averages
        let profileDesc = FetchDescriptor<StudentProfileModel>()
        if let profiles = try? context.fetch(profileDesc), let profile = profiles.first {
            let savedIds = profile.savedCollegeIds
            if !savedIds.isEmpty {
                let collegeDescriptor = FetchDescriptor<CollegeModel>()
                if let colleges = try? context.fetch(collegeDescriptor) {
                    savedColleges = colleges
                        .filter { college in
                            if let sid = college.supabaseId { return savedIds.contains(sid) }
                            return false
                        }
                        .compactMap { college in
                            guard let avg = college.satAvg else { return nil }
                            return CollegeScoreInfo(name: college.name, satAvg: avg)
                        }
                }
            }
        }
    }

    // MARK: - Section 1: Free Resources

    private var freeResourcesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            sectionHeader("FREE RESOURCES", icon: "book.fill")

            ForEach(TestPrepResource.freeResources) { resource in
                resourceCard(resource)
            }
        }
    }

    // MARK: - Section 2: Study Plans

    private var studyPlansSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            sectionHeader("STUDY PLANS", icon: "calendar")

            ForEach(StudyPlan.plans) { plan in
                studyPlanCard(plan)
            }
        }
    }

    // MARK: - Section 3: Score Goals

    private var scoreGoalsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            sectionHeader("SCORE GOALS", icon: "target")

            if studentSATScore > 0 {
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        HStack {
                            Text("Your SAT Score")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                            Text("\(studentSATScore)")
                                .font(LadderTypography.headlineSmall)
                                .foregroundStyle(LadderColors.accentLime)
                        }
                    }
                }
            } else {
                LadderCard {
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(red: 0.75, green: 0.60, blue: 0.10))
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text("No SAT score recorded")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Add your score in Profile Settings to see personalized score goals")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                    }
                }
            }

            if savedColleges.isEmpty {
                LadderCard {
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text("No saved colleges")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Save colleges to see how your score compares to their averages")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                    }
                }
            } else {
                ForEach(savedColleges) { college in
                    scoreComparisonCard(college)
                }
            }
        }
    }

    // MARK: - Resource Card

    private func resourceCard(_ resource: TestPrepResource) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.md) {
                    Image(systemName: resource.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(LadderColors.primary)
                        .frame(width: 40, height: 40)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(resource.name)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(resource.description)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                HStack(spacing: LadderSpacing.sm) {
                    // Difficulty chip
                    HStack(spacing: LadderSpacing.xxs) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10))
                        Text(resource.difficulty)
                            .font(LadderTypography.labelSmall)
                    }
                    .foregroundStyle(difficultyColor(resource.difficulty))
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xs)
                    .background(difficultyColor(resource.difficulty).opacity(0.1))
                    .clipShape(Capsule())

                    // Time chip
                    HStack(spacing: LadderSpacing.xxs) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(resource.estimatedTime)
                            .font(LadderTypography.labelSmall)
                    }
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xs)
                    .background(LadderColors.surfaceContainerHighest)
                    .clipShape(Capsule())

                    Spacer()
                }

                // URL display
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "link")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.primary)
                    Text(resource.url)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xs)
                .background(LadderColors.primaryContainer.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
            }
        }
    }

    // MARK: - Study Plan Card

    private func studyPlanCard(_ plan: StudyPlan) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlan = selectedPlan?.id == plan.id ? nil : plan
            }
        } label: {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: plan.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(plan.color)
                            .frame(width: 40, height: 40)
                            .background(plan.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text(plan.title)
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(plan.subtitle)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        Spacer()

                        Image(systemName: selectedPlan?.id == plan.id ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    if selectedPlan?.id == plan.id {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            ForEach(plan.milestones, id: \.self) { milestone in
                                HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                    Circle()
                                        .fill(plan.color)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    Text(milestone)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
                        }
                        .padding(.top, LadderSpacing.xs)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Score Comparison Card

    private func scoreComparisonCard(_ college: CollegeScoreInfo) -> some View {
        let gap = college.satAvg - studentSATScore
        let isAbove = gap <= 0

        return LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text(college.name)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(1)
                    Spacer()
                    Text("Avg: \(college.satAvg)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: isAbove ? "checkmark.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(isAbove ? LadderColors.accentLime : LadderColors.error)

                    if isAbove {
                        Text("Your score is at or above this school's average")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.accentLime)
                    } else {
                        Text("You need \(gap) more points to reach this school's average")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.error)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(LadderColors.primary)
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Beginner": return LadderColors.primary
        case "Intermediate": return Color(red: 0.75, green: 0.60, blue: 0.10)
        case "Advanced": return LadderColors.error
        default: return LadderColors.onSurfaceVariant
        }
    }
}

// MARK: - Data Models

struct TestPrepResource: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let url: String
    let icon: String
    let difficulty: String
    let estimatedTime: String

    static var freeResources: [TestPrepResource] {
        [
            TestPrepResource(
                name: "Khan Academy SAT Prep",
                description: "Official College Board partner with personalized practice, full-length tests, and video lessons.",
                url: "khanacademy.org/sat",
                icon: "play.rectangle.fill",
                difficulty: "Beginner",
                estimatedTime: "20 min/day"
            ),
            TestPrepResource(
                name: "College Board Practice Tests",
                description: "Official full-length SAT practice tests with answer explanations and scoring guides.",
                url: "collegeboard.org/sat/practice",
                icon: "doc.text.fill",
                difficulty: "Intermediate",
                estimatedTime: "3 hrs/test"
            ),
            TestPrepResource(
                name: "ACT Academy",
                description: "Free ACT prep with practice questions, full tests, and personalized study paths.",
                url: "act.org/academy",
                icon: "graduationcap.fill",
                difficulty: "Beginner",
                estimatedTime: "15 min/day"
            ),
            TestPrepResource(
                name: "SAT Math Fundamentals",
                description: "Master algebra, geometry, and data analysis with targeted practice problems and walkthroughs.",
                url: "khanacademy.org/math/sat",
                icon: "function",
                difficulty: "Intermediate",
                estimatedTime: "30 min/day"
            ),
            TestPrepResource(
                name: "Reading & Writing Strategies",
                description: "Evidence-based reading comprehension techniques and grammar rule reviews for the SAT.",
                url: "khanacademy.org/ela/sat",
                icon: "text.book.closed.fill",
                difficulty: "Intermediate",
                estimatedTime: "25 min/day"
            ),
            TestPrepResource(
                name: "ACT Science Section Guide",
                description: "Learn to interpret data, evaluate hypotheses, and read scientific passages efficiently.",
                url: "act.org/academy/science",
                icon: "flask.fill",
                difficulty: "Advanced",
                estimatedTime: "20 min/day"
            ),
        ]
    }
}

struct StudyPlan: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let milestones: [String]

    static var plans: [StudyPlan] {
        [
            StudyPlan(
                title: "3-Month Intensive",
                subtitle: "For students with a test date coming up soon",
                icon: "bolt.fill",
                color: LadderColors.error,
                milestones: [
                    "Week 1–2: Take diagnostic test, identify weak areas",
                    "Week 3–6: Focus on 2 weakest sections with daily practice",
                    "Week 7–9: Full-length practice tests every weekend",
                    "Week 10–11: Review all missed questions and concepts",
                    "Week 12: Light review, rest before test day",
                ]
            ),
            StudyPlan(
                title: "6-Month Balanced",
                subtitle: "Steady progress without overwhelming your schedule",
                icon: "chart.line.uptrend.xyaxis",
                color: Color(red: 0.75, green: 0.60, blue: 0.10),
                milestones: [
                    "Month 1: Diagnostic test + learn test format and question types",
                    "Month 2: Focus on math fundamentals and reading strategies",
                    "Month 3: Writing section mastery + first full practice test",
                    "Month 4: Targeted drills on weakest areas",
                    "Month 5: Weekly full-length practice tests",
                    "Month 6: Final review, simulate test-day conditions",
                ]
            ),
            StudyPlan(
                title: "12-Month Marathon",
                subtitle: "Start early for maximum improvement potential",
                icon: "figure.run",
                color: LadderColors.primary,
                milestones: [
                    "Months 1–2: Build vocabulary and math foundations",
                    "Months 3–4: Learn test strategies and question patterns",
                    "Months 5–6: First practice tests, establish baseline score",
                    "Months 7–8: Deep dive into weak areas with targeted practice",
                    "Months 9–10: Full-length tests every 2 weeks",
                    "Months 11–12: Intensive review, test-day simulation, final prep",
                ]
            ),
        ]
    }
}

struct CollegeScoreInfo: Identifiable {
    let id = UUID()
    let name: String
    let satAvg: Int
}

#Preview {
    NavigationStack {
        TestPrepResourcesView()
            .environment(AppCoordinator())
    }
    .modelContainer(for: [StudentProfileModel.self, CollegeModel.self])
}
