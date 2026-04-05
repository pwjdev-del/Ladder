import SwiftUI

// MARK: - 4-Year Roadmap View

struct RoadmapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGrade = 10   // 9, 10, 11, 12, or 0 = Alt Paths

    private let grades: [(label: String, sub: String, value: Int)] = [
        ("9", "Freshman", 9),
        ("10", "Sophomore", 10),
        ("11", "Junior", 11),
        ("12", "Senior", 12),
        ("Alt", "Paths", 0),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    gradePicker
                    if selectedGrade == 0 {
                        alternativePathsSection
                    } else {
                        ForEach(milestonesForGrade(selectedGrade)) { milestone in
                            milestoneCard(milestone)
                        }
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
                Text("4-Year Roadmap")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Grade Picker

    private var gradePicker: some View {
        HStack(spacing: LadderSpacing.xs) {
            ForEach(grades, id: \.value) { grade in
                let isSelected = selectedGrade == grade.value
                Button {
                    withAnimation { selectedGrade = grade.value }
                } label: {
                    VStack(spacing: LadderSpacing.xxs) {
                        Text(grade.label)
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(isSelected ? .white : LadderColors.onSurface)
                        Text(grade.sub)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(isSelected ? .white.opacity(0.75) : LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(
                        isSelected
                            ? (grade.value == 0 ? LadderColors.accentLime.opacity(0.85) : LadderColors.primary)
                            : LadderColors.surfaceContainerLow
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Milestone Card

    private func milestoneCard(_ milestone: RoadmapItem) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            VStack(spacing: 0) {
                Circle()
                    .fill(milestone.isCompleted ? LadderColors.accentLime : LadderColors.outline)
                    .frame(width: 12, height: 12)
                    .overlay(
                        milestone.isCompleted
                            ? Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(.white)
                            : nil
                    )
                Rectangle()
                    .fill(LadderColors.outlineVariant)
                    .frame(width: 2)
            }
            .frame(width: 12)

            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    LadderTagChip(milestone.category, icon: milestone.icon)
                    Spacer()
                    if let quarter = milestone.quarter {
                        Text(quarter)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                Text(milestone.title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(milestone.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                    .strikethrough(milestone.isCompleted)
                if let description = milestone.description {
                    Text(description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .opacity(milestone.isCompleted ? 0.7 : 1.0)
        }
    }

    // MARK: - Alternative Paths Section

    private var alternativePathsSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundStyle(LadderColors.accentLime)
                        Text("Alternative Paths")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    Text("A 4-year university isn't the only route to a successful career. Explore these paths and find what's right for you.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            ForEach(AlternativePath.all) { path in
                alternativePathCard(path)
            }
        }
    }

    private func alternativePathCard(_ path: AlternativePath) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                // Header
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                            .fill(path.color.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: path.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(path.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(path.name)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(path.tagline)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                }

                Text(path.description)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurface)

                // Timeline chip
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(path.timeline)
                        .font(LadderTypography.labelSmall)
                }
                .foregroundStyle(path.color)
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, 4)
                .background(path.color.opacity(0.1))
                .clipShape(Capsule())

                // Pros
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("WHY CONSIDER THIS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    ForEach(path.pros, id: \.self) { pro in
                        HStack(alignment: .top, spacing: LadderSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(path.color)
                            Text(pro)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                    }
                }

                // Things to know
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("THINGS TO KNOW")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    ForEach(path.considerations, id: \.self) { note in
                        HStack(alignment: .top, spacing: LadderSpacing.sm) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            Text(note)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Mock Milestone Data

    private func milestonesForGrade(_ grade: Int) -> [RoadmapItem] {
        switch grade {
        case 9:
            return [
                RoadmapItem(title: "Explore Interests & Clubs", description: "Join 2-3 clubs that match your interests. Quality over quantity.", category: "Extracurriculars", icon: "star", quarter: "Fall", isCompleted: true),
                RoadmapItem(title: "Meet Your School Counselor", description: "Introduce yourself and discuss your 4-year course plan.", category: "Planning", icon: "person.2", quarter: "Fall", isCompleted: true),
                RoadmapItem(title: "Focus on Core Academics", description: "Build strong study habits early. Your GPA starts now.", category: "Academics", icon: "book", quarter: "All Year", isCompleted: true),
                RoadmapItem(title: "Start Community Service", description: "Find a cause you care about and start volunteering regularly.", category: "Extracurriculars", icon: "heart", quarter: "Spring", isCompleted: true),
                RoadmapItem(title: "Take Pre-AP or Honors Courses", description: "Challenge yourself with advanced coursework when possible.", category: "Academics", icon: "graduationcap", quarter: "All Year", isCompleted: true),
            ]
        case 10:
            return [
                RoadmapItem(title: "Take PSAT/NMSQT", description: "Practice for the SAT and qualify for National Merit Scholarships.", category: "Testing", icon: "pencil.line", quarter: "Fall", isCompleted: true),
                RoadmapItem(title: "Deepen Extracurricular Involvement", description: "Aim for leadership roles in your top 2-3 activities.", category: "Extracurriculars", icon: "star", quarter: "All Year", isCompleted: false),
                RoadmapItem(title: "Research Career Paths", description: "Take the Career Quiz to explore majors and career options.", category: "Planning", icon: "sparkle.magnifyingglass", quarter: "Winter", isCompleted: false),
                RoadmapItem(title: "Build Your College List", description: "Start researching colleges. Use the College Discovery tool.", category: "Planning", icon: "building.columns", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Start SAT Prep", description: "Begin light SAT preparation. Khan Academy is free and effective.", category: "Testing", icon: "chart.line.uptrend.xyaxis", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Log All Activities", description: "Keep a running record of all extracurriculars, hours, and achievements.", category: "Extracurriculars", icon: "list.clipboard", quarter: "All Year", isCompleted: false),
            ]
        case 11:
            return [
                RoadmapItem(title: "Take SAT/ACT (First Attempt)", description: "Take the SAT at least once. Plan for 2-3 total attempts.", category: "Testing", icon: "pencil.line", quarter: "Fall/Winter", isCompleted: false),
                RoadmapItem(title: "Visit Colleges", description: "Schedule campus visits and virtual tours for your top schools.", category: "Planning", icon: "map", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Start AP Exams Prep", description: "Prepare for May AP exams. Scores of 4-5 earn college credit.", category: "Testing", icon: "star", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Ask for Recommendation Letters", description: "Ask teachers who know you well. Give them plenty of lead time.", category: "Applications", icon: "envelope", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Draft Personal Statement", description: "Start brainstorming and drafting your Common App essay.", category: "Applications", icon: "text.alignleft", quarter: "Summer", isCompleted: false),
                RoadmapItem(title: "Research Scholarships", description: "Start applying to scholarships. Many have junior-year deadlines.", category: "Financial", icon: "dollarsign.circle", quarter: "All Year", isCompleted: false),
                RoadmapItem(title: "Retake SAT/ACT", description: "Take the test again if needed. Most students improve on retake.", category: "Testing", icon: "arrow.counterclockwise", quarter: "Spring", isCompleted: false),
            ]
        case 12:
            return [
                RoadmapItem(title: "Finalize College List", description: "Confirm your reach, match, and safety schools.", category: "Planning", icon: "checkmark.circle", quarter: "Fall", isCompleted: false),
                RoadmapItem(title: "Submit Early Applications", description: "Early Action/Decision deadlines are typically Nov 1.", category: "Applications", icon: "paperplane", quarter: "Fall", isCompleted: false),
                RoadmapItem(title: "Complete FAFSA", description: "Opens October 1. File ASAP for best financial aid.", category: "Financial", icon: "banknote", quarter: "Fall", isCompleted: false),
                RoadmapItem(title: "Submit Regular Decision Apps", description: "Most deadlines are January 1-15. Don't wait until the last day.", category: "Applications", icon: "doc.badge.plus", quarter: "Winter", isCompleted: false),
                RoadmapItem(title: "Compare Financial Aid Offers", description: "Use the Financial Aid Comparison tool when decisions arrive.", category: "Financial", icon: "chart.bar", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Make Your Decision", description: "Commit to a school by May 1 (National Decision Day).", category: "Planning", icon: "hand.thumbsup", quarter: "Spring", isCompleted: false),
                RoadmapItem(title: "Complete Enrollment Tasks", description: "Pay deposit, submit housing forms, immunization records, etc.", category: "Post-Acceptance", icon: "checklist", quarter: "Spring", isCompleted: false),
            ]
        default:
            return []
        }
    }
}

// MARK: - Roadmap Item

struct RoadmapItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let category: String
    let icon: String
    let quarter: String?
    var isCompleted: Bool
}

// MARK: - Alternative Path Model

struct AlternativePath: Identifiable {
    let id = UUID()
    let name: String
    let tagline: String
    let description: String
    let timeline: String
    let icon: String
    let color: Color
    let pros: [String]
    let considerations: [String]

    static let all: [AlternativePath] = [
        AlternativePath(
            name: "Community College",
            tagline: "2 years, then transfer to a 4-year",
            description: "Earn your Associate's degree and transfer to a 4-year university. Many states have guaranteed transfer agreements — you can end up at the same school as if you had applied directly, for half the cost.",
            timeline: "2 years → transfer",
            icon: "building.2.fill",
            color: Color(red: 0.15, green: 0.50, blue: 0.35),
            pros: [
                "Save $30,000–$60,000 in tuition vs. 4-year directly",
                "Raise GPA before transferring to a competitive school",
                "Explore majors without high-stakes commitment",
                "Guaranteed transfer agreements in FL, CA, TX and more",
            ],
            considerations: [
                "Some scholarships and honors programs are only for freshmen",
                "Must maintain a high GPA to qualify for top transfer programs",
                "Social experience differs from living on campus from day one",
            ]
        ),
        AlternativePath(
            name: "Trade School / Vocational",
            tagline: "Skilled trades — high demand, high pay",
            description: "Electricians, plumbers, HVAC technicians, welders, and dental hygienists are in massive demand. Trade programs typically take 1-2 years and lead directly to well-paying careers — often $60K–$90K+ with no student debt.",
            timeline: "6 months – 2 years",
            icon: "wrench.and.screwdriver.fill",
            color: Color(red: 0.55, green: 0.30, blue: 0.10),
            pros: [
                "Programs cost $5K–$30K vs. $100K+ for a degree",
                "Trades are recession-proof and can't be outsourced",
                "Start earning within 1-2 years",
                "Strong apprenticeship programs with paid training",
            ],
            considerations: [
                "Physical demands vary by trade — research day-to-day work life",
                "Licensing requirements differ by state",
                "Consider which trade aligns with your Career Quiz result",
            ]
        ),
        AlternativePath(
            name: "Military Service",
            tagline: "Serve your country, earn education benefits",
            description: "Enlist in the Army, Navy, Air Force, Marines, Coast Guard, or Space Force. The GI Bill pays for college after service, and many branches offer college credits and technical training during service itself.",
            timeline: "4+ years of service",
            icon: "shield.lefthalf.filled",
            color: Color(red: 0.15, green: 0.35, blue: 0.55),
            pros: [
                "GI Bill covers full college tuition after service",
                "Earn salary + housing + healthcare while serving",
                "Develop leadership, discipline, and technical skills",
                "ROTC programs pay for college while in college",
            ],
            considerations: [
                "Significant time commitment — typically 4 years minimum",
                "Deployment and relocation are part of the commitment",
                "ROTC is a separate path — commit in college, serve as an officer",
            ]
        ),
        AlternativePath(
            name: "Gap Year",
            tagline: "Intentional time before college",
            description: "Take a structured year to travel, work, intern, volunteer, or build a project. Admissions offices view gap years positively when used intentionally. Defer your college acceptance and return with clarity and maturity.",
            timeline: "1 year (defer admission)",
            icon: "airplane.departure",
            color: Color(red: 0.50, green: 0.20, blue: 0.45),
            pros: [
                "Many colleges allow deferral — keep your acceptance",
                "Gain real-world experience before studying it",
                "Programs like AmeriCorps, Peace Corps, and City Year are structured options",
                "Students who take gap years often have higher GPAs and graduation rates",
            ],
            considerations: [
                "Must have a plan — \"taking time off\" without structure rarely helps",
                "Some financial aid may not transfer to deferred year",
                "Notify your college of intent to defer by May 1",
            ]
        ),
    ]
}

#Preview {
    NavigationStack {
        RoadmapView()
    }
}
