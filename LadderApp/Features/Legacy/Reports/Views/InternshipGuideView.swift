import SwiftUI

// MARK: - Internship Guide View
// Informational guide to finding internships for high schoolers

struct InternshipGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: String?

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(LadderColors.primary)

                        Text("Internship Guide")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Everything you need to land your first internship")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LadderSpacing.lg)

                    // When to start
                    expandableSection(
                        icon: "calendar",
                        title: "When to Start",
                        content: {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                timelineItem(grade: "9th Grade", action: "Explore interests through clubs and volunteering. Shadow professionals in fields you're curious about.")
                                timelineItem(grade: "10th Grade", action: "Start building skills. Take relevant courses, join competitions, and begin a personal project.")
                                timelineItem(grade: "11th Grade", action: "Apply for summer internships (start applications in January-March). Target local businesses, labs, and nonprofits.")
                                timelineItem(grade: "12th Grade", action: "Pursue competitive internships. Leverage your experience from 11th grade. Consider pre-college programs.")
                            }
                        }
                    )

                    // Where to look
                    expandableSection(
                        icon: "magnifyingglass",
                        title: "Where to Look",
                        content: {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                ForEach([
                                    ("globe", "Your school's career center or guidance counselor"),
                                    ("building.2", "Local businesses and startups"),
                                    ("flask", "University research labs (email professors directly)"),
                                    ("heart", "Nonprofits and community organizations"),
                                    ("laptopcomputer", "LinkedIn, Handshake, and Indeed"),
                                    ("person.2", "Family and friends' professional networks"),
                                    ("star", "Formal programs: MITES, NASA SEES, Google CSSI, Bank of America Student Leaders")
                                ], id: \.1) { icon, text in
                                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                        Image(systemName: icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(LadderColors.primary)
                                            .frame(width: 24)
                                            .padding(.top, 2)
                                        Text(text)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                }
                            }
                        }
                    )

                    // How to apply
                    expandableSection(
                        icon: "doc.text",
                        title: "How to Apply",
                        content: {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                ForEach(Array([
                                    "Research the organization thoroughly. Know their mission, recent projects, and team.",
                                    "Tailor your resume for each application. Highlight relevant coursework, skills, and projects.",
                                    "Write a compelling cover letter. Explain why you're interested and what you can contribute.",
                                    "Reach out directly. A professional email to a manager can open doors that job boards can't.",
                                    "Follow up politely after one week if you haven't heard back.",
                                    "Prepare for interviews by practicing common questions and researching the role."
                                ].enumerated()), id: \.offset) { i, step in
                                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                        Text("\(i + 1)")
                                            .font(LadderTypography.labelMedium)
                                            .foregroundStyle(.white)
                                            .frame(width: 24, height: 24)
                                            .background(LadderColors.primary)
                                            .clipShape(Circle())
                                        Text(step)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                }
                            }
                        }
                    )

                    // Resume tips
                    expandableSection(
                        icon: "doc.richtext",
                        title: "Resume Tips for High Schoolers",
                        content: {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                ForEach([
                                    "Keep it to one page. Quality over quantity.",
                                    "Lead with Education: school name, GPA, relevant courses.",
                                    "Include Skills: programming, languages, software, certifications.",
                                    "List Activities: clubs, sports, volunteering with your role and impact.",
                                    "Add Projects: personal projects, class projects, competitions.",
                                    "Use action verbs: Led, Created, Organized, Analyzed, Designed.",
                                    "Quantify results: 'Raised $2,000 for charity' not just 'Fundraised'.",
                                    "Proofread twice. Then have someone else proofread it."
                                ], id: \.self) { tip in
                                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(LadderColors.primary)
                                            .padding(.top, 3)
                                        Text(tip)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                }
                            }
                        }
                    )

                    // Interview tips
                    expandableSection(
                        icon: "person.wave.2",
                        title: "Interview Tips",
                        content: {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                ForEach([
                                    "Research the company and role before the interview.",
                                    "Practice the STAR method: Situation, Task, Action, Result.",
                                    "Dress professionally, even for video calls.",
                                    "Prepare 2-3 thoughtful questions to ask the interviewer.",
                                    "Be honest about your experience — enthusiasm matters more than expertise.",
                                    "Send a thank-you email within 24 hours.",
                                    "It's OK to say 'I don't know, but I'd love to learn about that.'"
                                ], id: \.self) { tip in
                                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                        Image(systemName: "lightbulb")
                                            .font(.system(size: 12))
                                            .foregroundStyle(LadderColors.primary)
                                            .padding(.top, 3)
                                        Text(tip)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                }
                            }
                        }
                    )

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
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
                Text("Internship Guide")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Timeline Item

    private func timelineItem(grade: String, action: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            VStack(spacing: 0) {
                Circle()
                    .fill(LadderColors.primary)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(LadderColors.outlineVariant)
                    .frame(width: 2)
            }
            .frame(width: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(grade)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.primary)
                Text(action)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
            .padding(.bottom, LadderSpacing.md)
        }
    }

    // MARK: - Expandable Section

    private func expandableSection<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedSection = expandedSection == title ? nil : title
                }
            } label: {
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous)
                            .fill(LadderColors.primaryContainer.opacity(0.25))
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.primary)
                    }

                    Text(title)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Spacer()

                    Image(systemName: expandedSection == title ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                }
                .padding(LadderSpacing.lg)
            }
            .buttonStyle(.plain)

            if expandedSection == title {
                VStack(alignment: .leading) {
                    content()
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.bottom, LadderSpacing.lg)
            }
        }
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}
