import SwiftUI

// MARK: - Dual Enrollment Guide View
// Informational view explaining dual enrollment for Florida high school students.
// Covers eligibility, benefits, how to apply, and frequently asked questions.

struct DualEnrollmentGuideView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var expandedFAQ: String?

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    heroCard
                    whatIsSection
                    floridaInfoSection
                    benefitsSection
                    eligibilitySection
                    howToApplySection
                    faqSection
                    counselorButton
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
                Text("Dual Enrollment")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer)
                        .frame(width: 64, height: 64)
                    Image(systemName: "book.and.wrench")
                        .font(.system(size: 28))
                        .foregroundStyle(LadderColors.onPrimaryContainer)
                }

                Text("Get Ahead with Dual Enrollment")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .multilineTextAlignment(.center)

                Text("Earn college credits while still in high school, completely free for Florida students.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - What Is Dual Enrollment?

    private var whatIsSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "questionmark.circle", title: "What is Dual Enrollment?")

                Text("Dual enrollment lets high school students take college-level courses at a local college or university. These courses count toward both your high school diploma and your college degree simultaneously.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineSpacing(4)

                Text("You will be in real college classes, earning real college credits that transfer to most universities. It is one of the best ways to get a head start on your college education.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Florida-Specific Info

    private var floridaInfoSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(LadderColors.secondary)
                    Text("Florida Dual Enrollment")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                }

                floridaInfoRow(
                    icon: "dollarsign.circle.fill",
                    title: "100% Free for FL Students",
                    detail: "The state of Florida pays your tuition, fees, and textbooks. No cost to you or your family."
                )

                floridaInfoRow(
                    icon: "arrow.triangle.merge",
                    title: "Counts Double",
                    detail: "Every course counts toward your high school graduation requirements AND college credit hours."
                )

                floridaInfoRow(
                    icon: "building.2",
                    title: "Local Community Colleges",
                    detail: "Take classes at your nearest Florida state college. Most offer courses at your high school or online."
                )

                floridaInfoRow(
                    icon: "chart.bar.fill",
                    title: "GPA Requirement",
                    detail: "You typically need a 3.0 unweighted GPA to qualify. Some programs may have additional requirements."
                )

                floridaInfoRow(
                    icon: "checkmark.shield.fill",
                    title: "Guaranteed Transfer",
                    detail: "Credits earned at any Florida state college are guaranteed to transfer to all Florida public universities."
                )
            }
        }
    }

    private func floridaInfoRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 24, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(detail)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, LadderSpacing.xs)
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "star.fill", title: "Benefits")

                benefitRow(icon: "dollarsign", text: "Save thousands on college tuition")
                benefitRow(icon: "clock.arrow.circlepath", text: "Graduate college earlier, potentially a full year sooner")
                benefitRow(icon: "checkmark.seal", text: "Stronger college application showing academic readiness")
                benefitRow(icon: "person.fill.checkmark", text: "Experience real college-level coursework before committing")
                benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Boost your weighted GPA with college-level courses")
                benefitRow(icon: "building.columns", text: "Explore different subjects and potential majors risk-free")
                benefitRow(icon: "arrow.up.forward", text: "Develop independence and time management skills early")
            }
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 20, alignment: .center)
                .padding(.top, 2)
            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(.vertical, LadderSpacing.xxs)
    }

    // MARK: - Eligibility

    private var eligibilitySection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "checklist", title: "Am I Eligible?")

                eligibilityItem(text: "Enrolled in a Florida public or private high school", met: true)
                eligibilityItem(text: "3.0 unweighted GPA (some programs accept 2.5)", met: true)
                eligibilityItem(text: "Must have qualifying scores on PERT or SAT/ACT", met: true)
                eligibilityItem(text: "Parental/guardian consent required", met: true)
                eligibilityItem(text: "Approval from your school counselor", met: true)

                Text("Home education students and private school students in Florida are also eligible for dual enrollment.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.top, LadderSpacing.xs)
            }
        }
    }

    private func eligibilityItem(text: String, met: Bool) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(met ? LadderColors.primary : LadderColors.outlineVariant)
                .padding(.top, 1)
            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    // MARK: - How to Apply

    private var howToApplySection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                sectionHeader(icon: "list.number", title: "How to Apply")

                stepRow(number: 1, title: "Talk to Your Counselor", detail: "Meet with your school counselor to discuss dual enrollment options and make sure it fits your graduation plan.")
                stepRow(number: 2, title: "Check Your Eligibility", detail: "Verify your GPA meets the minimum requirement and ask about any prerequisite courses or test scores needed.")
                stepRow(number: 3, title: "Take the PERT Exam", detail: "If you do not have qualifying SAT/ACT scores, take the PERT (Postsecondary Education Readiness Test) at your local college.")
                stepRow(number: 4, title: "Complete the Application", detail: "Fill out the dual enrollment application through your local state college. Your counselor will help you with paperwork.")
                stepRow(number: 5, title: "Register for Classes", detail: "Work with your counselor and the college advisor to choose courses that satisfy both high school and college requirements.")
                stepRow(number: 6, title: "Attend Orientation", detail: "Many colleges require a brief orientation for new dual enrollment students. Check with your assigned campus.")
                stepRow(number: 7, title: "Start Classes", detail: "Attend your college courses, complete assignments, and earn your credits. Reach out to professors during office hours if you need help.")
            }
        }
    }

    private func stepRow(number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer)
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onPrimaryContainer)
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(detail)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineSpacing(2)
            }
        }
    }

    // MARK: - FAQ

    private var faqSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                sectionHeader(icon: "bubble.left.and.bubble.right", title: "Frequently Asked Questions")

                faqCard(
                    question: "Will dual enrollment courses show on my college transcript?",
                    answer: "Yes. Dual enrollment courses appear on both your high school transcript and your college transcript. The grades you earn are permanent and will be part of your college GPA."
                )

                faqCard(
                    question: "Can I take dual enrollment AND AP courses?",
                    answer: "Absolutely. Many students take a mix of both. AP courses are taken at your high school, while dual enrollment courses are taken at the college campus or online. They complement each other well."
                )

                faqCard(
                    question: "What happens if I fail a dual enrollment course?",
                    answer: "A failing grade will appear on both your high school and college transcripts. This is why it is important to choose courses you are prepared for and to stay on top of your work. Talk to your professor early if you are struggling."
                )

                faqCard(
                    question: "Do dual enrollment credits transfer out of state?",
                    answer: "Florida guarantees transfer within the state system. For out-of-state schools, most accept dual enrollment credits, but policies vary. Check with each university's admissions or registrar office."
                )

                faqCard(
                    question: "How many courses can I take per semester?",
                    answer: "Most students take 1-2 dual enrollment courses per semester alongside their regular high school schedule. Your counselor will help ensure the workload is manageable."
                )

                faqCard(
                    question: "Is it harder than AP?",
                    answer: "It depends on the course and professor. Dual enrollment courses are true college courses with college-level expectations, but there is no high-stakes AP exam at the end. Your grade is based on coursework throughout the semester."
                )

                faqCard(
                    question: "Can dual enrollment affect my Bright Futures scholarship?",
                    answer: "Dual enrollment courses can count toward the community service and credit hour requirements for Bright Futures. The credits earned also count toward the 18-credit threshold for Florida Academic Scholars."
                )
            }
        }
    }

    private func faqCard(question: String, answer: String) -> some View {
        let isExpanded = expandedFAQ == question

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedFAQ = isExpanded ? nil : question
            }
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(alignment: .top, spacing: LadderSpacing.sm) {
                    Text(question)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .padding(.top, 2)
                }

                if isExpanded {
                    Text(answer)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .lineSpacing(3)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Counselor Button

    private var counselorButton: some View {
        Button {
            // Navigation to counselor messaging handled by parent
        } label: {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 18))
                Text("Talk to Your Counselor")
                    .font(LadderTypography.titleSmall)
            }
            .foregroundStyle(LadderColors.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)
            Text(title)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }
}

#Preview {
    NavigationStack {
        DualEnrollmentGuideView()
    }
}
