import SwiftUI
import SwiftData

// MARK: - AP Course Suggestion View
// AI-powered AP course suggestions with difficulty ratings, pass rates,
// and career alignment explanations. Grouped by priority tier.

struct APSuggestionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var profiles: [StudentProfileModel]

    @State private var selectedTier: String = "All"
    @State private var expandedCourseId: UUID?

    private var profile: StudentProfileModel? { profiles.first }

    private let tiers = ["All", "Strongly Recommended", "Good Fit", "Consider"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    profileSummaryCard
                    tierFilter
                    recommendedSection
                    completedSection
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
                Text("AP Course Suggestions")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Profile Summary

    private var profileSummaryCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.primary)
                    Text("Personalized for You")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }

                HStack(spacing: LadderSpacing.lg) {
                    profileStat(label: "Grade", value: "\(profile?.grade ?? 10)th")
                    profileStat(label: "GPA", value: String(format: "%.1f", profile?.gpa ?? 3.5))
                    profileStat(label: "Path", value: profile?.careerPath ?? "General")
                    profileStat(label: "APs Taken", value: "\(profile?.apCourses.count ?? 0)")
                }
            }
        }
    }

    private func profileStat(label: String, value: String) -> some View {
        VStack(spacing: LadderSpacing.xxs) {
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
                .lineLimit(1)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Tier Filter

    private var tierFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(tiers, id: \.self) { tier in
                    LadderFilterChip(title: tier, isSelected: selectedTier == tier) {
                        withAnimation { selectedTier = tier }
                    }
                }
            }
        }
    }

    // MARK: - Recommended Courses

    private var recommendedSection: some View {
        let takenCourses = Set(profile?.apCourses ?? [])
        let allSuggestions = APSuggestionEngine.suggestions(
            grade: profile?.grade ?? 10,
            gpa: profile?.gpa ?? 3.5,
            careerPath: profile?.careerPath ?? "General",
            completedAPs: takenCourses
        )

        let filtered: [APSuggestion] = {
            if selectedTier == "All" {
                return allSuggestions
            }
            return allSuggestions.filter { $0.tier == selectedTier }
        }()

        // Group by tier for display
        let strongly = filtered.filter { $0.tier == "Strongly Recommended" }
        let good = filtered.filter { $0.tier == "Good Fit" }
        let consider = filtered.filter { $0.tier == "Consider" }

        return VStack(spacing: LadderSpacing.md) {
            if !strongly.isEmpty {
                tierSection(title: "Strongly Recommended", icon: "star.fill", courses: strongly)
            }
            if !good.isEmpty {
                tierSection(title: "Good Fit", icon: "hand.thumbsup.fill", courses: good)
            }
            if !consider.isEmpty {
                tierSection(title: "Consider", icon: "lightbulb.fill", courses: consider)
            }
            if filtered.isEmpty {
                emptyState
            }
        }
    }

    private func tierSection(title: String, icon: String, courses: [APSuggestion]) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(tierColor(title))
                Text(title.uppercased())
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                Text("\(courses.count)")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(.horizontal, LadderSpacing.xs)

            ForEach(courses) { suggestion in
                apSuggestionCard(suggestion)
            }
        }
    }

    private func apSuggestionCard(_ suggestion: APSuggestion) -> some View {
        let isExpanded = expandedCourseId == suggestion.id

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedCourseId = isExpanded ? nil : suggestion.id
            }
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                // Header row
                HStack(spacing: LadderSpacing.sm) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(suggestion.courseName)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .multilineTextAlignment(.leading)

                        Text(suggestion.category)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    // Difficulty stars
                    difficultyStars(suggestion.difficulty)
                }

                // Stats row
                HStack(spacing: LadderSpacing.md) {
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(LadderColors.primary)
                        Text("\(suggestion.passRate)% pass")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 10))
                            .foregroundStyle(LadderColors.primary)
                        Text("\(suggestion.collegeAcceptance)% accept")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                // Expanded detail
                if isExpanded {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        // Why take this
                        HStack(alignment: .top, spacing: LadderSpacing.sm) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.secondary)
                                .padding(.top, 2)
                            Text(suggestion.whyTakeThis)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineSpacing(2)
                        }

                        // Prerequisites
                        if let prereq = suggestion.prerequisite {
                            HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 12))
                                    .foregroundStyle(LadderColors.tertiary)
                                    .padding(.top, 2)
                                Text("Prerequisite: \(prereq)")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }

                        // College credit info
                        HStack(alignment: .top, spacing: LadderSpacing.sm) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.primary)
                                .padding(.top, 2)
                            Text("\(suggestion.collegeAcceptance)% of colleges accept this AP for credit")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                    .padding(.top, LadderSpacing.xs)
                }

                // Expand indicator
                HStack {
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func difficultyStars(_ level: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= level ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundStyle(star <= level ? LadderColors.secondary : LadderColors.outlineVariant)
            }
        }
    }

    private func tierColor(_ tier: String) -> Color {
        switch tier {
        case "Strongly Recommended": return LadderColors.primary
        case "Good Fit": return LadderColors.secondary
        default: return LadderColors.tertiary
        }
    }

    // MARK: - Completed Courses

    private var completedSection: some View {
        let taken = profile?.apCourses ?? []
        guard !taken.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.primary)
                    Text("COMPLETED".uppercased())
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                }
                .padding(.horizontal, LadderSpacing.xs)

                ForEach(taken, id: \.self) { course in
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(LadderColors.primary)
                        Text(course)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
            }
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 32))
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("No courses in this category")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xxl)
    }
}

// MARK: - AP Suggestion Model

struct APSuggestion: Identifiable {
    let id = UUID()
    let courseName: String
    let category: String
    let difficulty: Int // 1-5
    let passRate: Int // % scoring 3+
    let collegeAcceptance: Int // % of colleges accepting
    let whyTakeThis: String
    let prerequisite: String?
    let tier: String // "Strongly Recommended", "Good Fit", "Consider"
}

// MARK: - AP Suggestion Engine
// Determines recommendations based on student profile

struct APSuggestionEngine {

    // MARK: - All 38 AP Exams

    struct APExamData {
        let name: String
        let category: String
        let difficulty: Int
        let passRate: Int
        let collegeAcceptance: Int
        let prerequisite: String?
        let careerPaths: [String] // career keywords this AP aligns with
        let minGrade: Int // earliest recommended grade
        let minGPA: Double // minimum GPA recommendation
    }

    static let allExams: [APExamData] = [
        // STEM
        APExamData(name: "AP Calculus AB", category: "STEM", difficulty: 3, passRate: 61, collegeAcceptance: 95, prerequisite: "Precalculus", careerPaths: ["stem", "engineering", "science", "data", "finance"], minGrade: 11, minGPA: 3.0),
        APExamData(name: "AP Calculus BC", category: "STEM", difficulty: 4, passRate: 76, collegeAcceptance: 95, prerequisite: "AP Calculus AB or strong Precalculus", careerPaths: ["stem", "engineering", "science", "data", "finance"], minGrade: 11, minGPA: 3.5),
        APExamData(name: "AP Precalculus", category: "STEM", difficulty: 2, passRate: 50, collegeAcceptance: 75, prerequisite: "Algebra 2", careerPaths: ["stem", "engineering", "general"], minGrade: 10, minGPA: 2.5),
        APExamData(name: "AP Statistics", category: "STEM", difficulty: 2, passRate: 60, collegeAcceptance: 90, prerequisite: "Algebra 2", careerPaths: ["stem", "business", "data", "science", "social"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP Biology", category: "STEM", difficulty: 3, passRate: 69, collegeAcceptance: 95, prerequisite: "Biology and Chemistry recommended", careerPaths: ["health", "medical", "science", "stem"], minGrade: 10, minGPA: 3.0),
        APExamData(name: "AP Chemistry", category: "STEM", difficulty: 4, passRate: 56, collegeAcceptance: 95, prerequisite: "Chemistry", careerPaths: ["health", "medical", "science", "stem", "engineering"], minGrade: 11, minGPA: 3.2),
        APExamData(name: "AP Environmental Science", category: "STEM", difficulty: 2, passRate: 53, collegeAcceptance: 85, prerequisite: nil, careerPaths: ["science", "policy", "general"], minGrade: 9, minGPA: 2.5),
        APExamData(name: "AP Physics 1", category: "STEM", difficulty: 4, passRate: 46, collegeAcceptance: 90, prerequisite: "Algebra 2 (concurrent OK)", careerPaths: ["stem", "engineering", "science"], minGrade: 10, minGPA: 3.0),
        APExamData(name: "AP Physics 2", category: "STEM", difficulty: 4, passRate: 62, collegeAcceptance: 85, prerequisite: "AP Physics 1", careerPaths: ["stem", "engineering", "science"], minGrade: 11, minGPA: 3.2),
        APExamData(name: "AP Physics C: Mechanics", category: "STEM", difficulty: 5, passRate: 73, collegeAcceptance: 90, prerequisite: "AP Calculus AB (concurrent OK)", careerPaths: ["engineering", "stem", "science"], minGrade: 11, minGPA: 3.5),
        APExamData(name: "AP Physics C: E&M", category: "STEM", difficulty: 5, passRate: 68, collegeAcceptance: 90, prerequisite: "AP Physics C: Mechanics", careerPaths: ["engineering", "stem"], minGrade: 12, minGPA: 3.5),
        APExamData(name: "AP Computer Science A", category: "STEM", difficulty: 3, passRate: 67, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["stem", "engineering", "tech", "data", "computer"], minGrade: 10, minGPA: 3.0),
        APExamData(name: "AP Computer Science Principles", category: "STEM", difficulty: 1, passRate: 68, collegeAcceptance: 80, prerequisite: nil, careerPaths: ["stem", "tech", "general", "computer"], minGrade: 9, minGPA: 2.5),

        // Humanities
        APExamData(name: "AP English Language", category: "Humanities", difficulty: 3, passRate: 55, collegeAcceptance: 95, prerequisite: nil, careerPaths: ["law", "general", "writing", "education", "policy"], minGrade: 11, minGPA: 2.8),
        APExamData(name: "AP English Literature", category: "Humanities", difficulty: 3, passRate: 50, collegeAcceptance: 95, prerequisite: nil, careerPaths: ["law", "general", "writing", "education", "arts"], minGrade: 12, minGPA: 2.8),
        APExamData(name: "AP World History", category: "Humanities", difficulty: 3, passRate: 57, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["law", "policy", "general", "education"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP US History", category: "Humanities", difficulty: 3, passRate: 48, collegeAcceptance: 95, prerequisite: nil, careerPaths: ["law", "policy", "general", "education"], minGrade: 11, minGPA: 3.0),
        APExamData(name: "AP European History", category: "Humanities", difficulty: 3, passRate: 52, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["law", "policy", "education", "arts"], minGrade: 10, minGPA: 3.0),
        APExamData(name: "AP Art History", category: "Humanities", difficulty: 3, passRate: 56, collegeAcceptance: 85, prerequisite: nil, careerPaths: ["arts", "design", "education"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP African American Studies", category: "Humanities", difficulty: 2, passRate: 58, collegeAcceptance: 70, prerequisite: nil, careerPaths: ["law", "policy", "education", "general"], minGrade: 10, minGPA: 2.5),
        APExamData(name: "AP Seminar", category: "Humanities", difficulty: 2, passRate: 82, collegeAcceptance: 75, prerequisite: nil, careerPaths: ["general", "law", "writing"], minGrade: 10, minGPA: 2.8),

        // Social Science
        APExamData(name: "AP Psychology", category: "Social Science", difficulty: 2, passRate: 59, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["health", "education", "social", "general"], minGrade: 10, minGPA: 2.5),
        APExamData(name: "AP Macroeconomics", category: "Social Science", difficulty: 2, passRate: 57, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["business", "finance", "policy", "law"], minGrade: 11, minGPA: 2.8),
        APExamData(name: "AP Microeconomics", category: "Social Science", difficulty: 2, passRate: 63, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["business", "finance", "policy", "law"], minGrade: 11, minGPA: 2.8),
        APExamData(name: "AP US Govt & Politics", category: "Social Science", difficulty: 2, passRate: 49, collegeAcceptance: 90, prerequisite: nil, careerPaths: ["law", "policy", "government", "general"], minGrade: 11, minGPA: 2.8),
        APExamData(name: "AP Comparative Govt", category: "Social Science", difficulty: 2, passRate: 61, collegeAcceptance: 85, prerequisite: nil, careerPaths: ["law", "policy", "government"], minGrade: 11, minGPA: 2.8),
        APExamData(name: "AP Human Geography", category: "Social Science", difficulty: 1, passRate: 54, collegeAcceptance: 85, prerequisite: nil, careerPaths: ["general", "policy", "education"], minGrade: 9, minGPA: 2.5),

        // Arts
        APExamData(name: "AP Music Theory", category: "Arts", difficulty: 3, passRate: 63, collegeAcceptance: 80, prerequisite: "Music reading ability", careerPaths: ["arts", "music", "education"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP 2-D Art and Design", category: "Arts", difficulty: 2, passRate: 87, collegeAcceptance: 80, prerequisite: nil, careerPaths: ["arts", "design", "creative"], minGrade: 10, minGPA: 2.5),
        APExamData(name: "AP 3-D Art and Design", category: "Arts", difficulty: 2, passRate: 78, collegeAcceptance: 80, prerequisite: nil, careerPaths: ["arts", "design", "creative", "architecture"], minGrade: 10, minGPA: 2.5),
        APExamData(name: "AP Drawing", category: "Arts", difficulty: 2, passRate: 85, collegeAcceptance: 80, prerequisite: nil, careerPaths: ["arts", "design", "creative"], minGrade: 10, minGPA: 2.5),
        APExamData(name: "AP Research", category: "Arts", difficulty: 3, passRate: 80, collegeAcceptance: 75, prerequisite: "AP Seminar", careerPaths: ["general", "science", "law"], minGrade: 11, minGPA: 3.0),

        // Languages
        APExamData(name: "AP Spanish Language", category: "Languages", difficulty: 3, passRate: 88, collegeAcceptance: 95, prerequisite: "Spanish 3-4", careerPaths: ["general", "education", "health", "law", "business"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP Spanish Literature", category: "Languages", difficulty: 4, passRate: 62, collegeAcceptance: 85, prerequisite: "AP Spanish Language", careerPaths: ["education", "arts", "general"], minGrade: 11, minGPA: 3.0),
        APExamData(name: "AP French Language", category: "Languages", difficulty: 3, passRate: 75, collegeAcceptance: 95, prerequisite: "French 3-4", careerPaths: ["general", "education", "law", "business"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP German Language", category: "Languages", difficulty: 3, passRate: 68, collegeAcceptance: 90, prerequisite: "German 3-4", careerPaths: ["general", "engineering", "business"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP Chinese Language", category: "Languages", difficulty: 3, passRate: 91, collegeAcceptance: 90, prerequisite: "Chinese 3-4", careerPaths: ["general", "business", "policy"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP Japanese Language", category: "Languages", difficulty: 3, passRate: 73, collegeAcceptance: 90, prerequisite: "Japanese 3-4", careerPaths: ["general", "business", "tech"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP Italian Language", category: "Languages", difficulty: 3, passRate: 72, collegeAcceptance: 85, prerequisite: "Italian 3-4", careerPaths: ["general", "arts", "education"], minGrade: 10, minGPA: 2.8),
        APExamData(name: "AP Latin", category: "Languages", difficulty: 4, passRate: 56, collegeAcceptance: 85, prerequisite: "Latin 3-4", careerPaths: ["law", "education", "medical"], minGrade: 10, minGPA: 3.0),
    ]

    // MARK: - Generate Suggestions

    static func suggestions(grade: Int, gpa: Double, careerPath: String, completedAPs: Set<String>) -> [APSuggestion] {
        let pathLower = careerPath.lowercased()

        // Map career path to keyword list
        let pathKeywords: [String] = {
            if pathLower.contains("medical") || pathLower.contains("health") || pathLower.contains("nurs") {
                return ["health", "medical", "science"]
            } else if pathLower.contains("engineer") || pathLower.contains("stem") || pathLower.contains("tech") || pathLower.contains("computer") {
                return ["stem", "engineering", "tech", "computer", "data"]
            } else if pathLower.contains("business") || pathLower.contains("finance") || pathLower.contains("market") {
                return ["business", "finance"]
            } else if pathLower.contains("art") || pathLower.contains("design") || pathLower.contains("creative") || pathLower.contains("film") || pathLower.contains("music") {
                return ["arts", "design", "creative", "music"]
            } else if pathLower.contains("educat") || pathLower.contains("teach") {
                return ["education", "general"]
            } else if pathLower.contains("law") || pathLower.contains("legal") || pathLower.contains("policy") || pathLower.contains("government") {
                return ["law", "policy", "government"]
            } else {
                return ["general"]
            }
        }()

        return allExams
            .filter { !completedAPs.contains($0.name) }
            .compactMap { exam -> APSuggestion? in
                // Filter by grade and GPA readiness
                guard grade >= exam.minGrade - 1 else { return nil } // allow 1 year early for strong students
                guard gpa >= exam.minGPA - 0.3 else { return nil } // slight leniency

                // Determine tier
                let careerAlignment = exam.careerPaths.contains(where: { keyword in
                    pathKeywords.contains(keyword)
                })
                let isCoreCourse = ["AP English Language", "AP English Literature", "AP US History", "AP Calculus AB"].contains(exam.name)
                let hasHighPassRate = exam.passRate >= 60
                let isGPAStrong = gpa >= 3.5

                let tier: String
                if careerAlignment && (isCoreCourse || isGPAStrong) {
                    tier = "Strongly Recommended"
                } else if careerAlignment || isCoreCourse {
                    tier = "Good Fit"
                } else {
                    tier = "Consider"
                }

                // Generate "why take this" explanation
                let why: String
                if careerAlignment {
                    why = "Directly aligns with your \(careerPath) career path. Strong preparation for college-level coursework in this field and demonstrates subject mastery to admissions committees."
                } else if isCoreCourse {
                    why = "Core academic course valued by virtually all colleges. Taking this AP shows academic rigor regardless of your intended major."
                } else if hasHighPassRate {
                    why = "High pass rate makes this a smart choice for building your AP portfolio. Broadens your academic profile and earns college credit at most universities."
                } else {
                    why = "Expands your academic breadth and shows intellectual curiosity beyond your primary field. Colleges value well-rounded applicants."
                }

                return APSuggestion(
                    courseName: exam.name,
                    category: exam.category,
                    difficulty: exam.difficulty,
                    passRate: exam.passRate,
                    collegeAcceptance: exam.collegeAcceptance,
                    whyTakeThis: why,
                    prerequisite: exam.prerequisite,
                    tier: tier
                )
            }
            .sorted { lhs, rhs in
                let tierOrder = ["Strongly Recommended": 0, "Good Fit": 1, "Consider": 2]
                let lhsOrder = tierOrder[lhs.tier] ?? 3
                let rhsOrder = tierOrder[rhs.tier] ?? 3
                if lhsOrder != rhsOrder { return lhsOrder < rhsOrder }
                return lhs.difficulty < rhs.difficulty
            }
    }
}

#Preview {
    NavigationStack {
        APSuggestionView()
    }
    .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
