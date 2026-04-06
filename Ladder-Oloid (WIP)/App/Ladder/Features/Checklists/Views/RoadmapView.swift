import SwiftUI

// MARK: - 4-Year Roadmap View

struct RoadmapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGrade = 10

    private let grades = [9, 10, 11, 12]

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Grade selector
                    gradePicker

                    // Milestones for selected grade
                    ForEach(milestonesForGrade(selectedGrade)) { milestone in
                        milestoneCard(milestone)
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
        HStack(spacing: LadderSpacing.sm) {
            ForEach(grades, id: \.self) { grade in
                Button {
                    withAnimation { selectedGrade = grade }
                } label: {
                    VStack(spacing: LadderSpacing.xs) {
                        Text("Grade")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(selectedGrade == grade ? .white.opacity(0.7) : LadderColors.onSurfaceVariant)

                        Text("\(grade)")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(selectedGrade == grade ? .white : LadderColors.onSurface)

                        Text(gradeLabel(grade))
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(selectedGrade == grade ? .white.opacity(0.7) : LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                    .background(
                        selectedGrade == grade
                            ? LadderColors.primary
                            : LadderColors.surfaceContainerLow
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func gradeLabel(_ grade: Int) -> String {
        switch grade {
        case 9: return "Freshman"
        case 10: return "Sophomore"
        case 11: return "Junior"
        case 12: return "Senior"
        default: return ""
        }
    }

    // MARK: - Milestone Card

    private func milestoneCard(_ milestone: RoadmapItem) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            // Timeline indicator
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

            // Content
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

    // MARK: - Mock Data

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

#Preview {
    NavigationStack {
        RoadmapView()
    }
}
