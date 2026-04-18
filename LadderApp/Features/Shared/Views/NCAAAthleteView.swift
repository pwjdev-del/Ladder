import SwiftUI

// MARK: - NCAA Athlete Eligibility View
// NCAA core course requirements, GPA sliding scale, registration steps

struct NCAAAthleteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<Int> = []
    @State private var gpa: Double = 3.0

    // NCAA Division I sliding scale (simplified)
    private var requiredSAT: Int {
        // Approximate sliding scale: higher GPA = lower SAT needed
        if gpa >= 3.55 { return 400 }
        else if gpa >= 3.0 { return 620 }
        else if gpa >= 2.5 { return 820 }
        else if gpa >= 2.3 { return 900 }
        else { return 1010 }
    }

    private let coreCourses: [(subject: String, divI: Int, divII: Int)] = [
        ("English", 4, 3),
        ("Math (Algebra I+)", 3, 2),
        ("Natural/Physical Science", 2, 2),
        ("Additional English/Math/Science", 1, 3),
        ("Social Science", 2, 2),
        ("Additional Core Courses", 4, 4)
    ]

    private let registrationSteps: [(title: String, detail: String, icon: String)] = [
        ("Create Eligibility Center Account", "Register at web3.ncaa.org/ecwr3. Use your legal name exactly as it appears on transcripts.", "person.badge.plus"),
        ("Request Transcript", "Ask your counselor to send your official transcript to the NCAA Eligibility Center.", "doc.text"),
        ("Enter Test Scores", "Use code 9999 when registering for the SAT or ACT to send scores directly to NCAA.", "number"),
        ("List Your Core Courses", "Work with your counselor to verify your 16 core courses meet NCAA requirements.", "list.clipboard"),
        ("Register Before Junior Year", "Ideally register by the end of sophomore year. Required before official college visits.", "calendar"),
        ("Receive Certification", "The NCAA will certify your eligibility once all academic requirements are verified.", "checkmark.shield")
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerSection
                    coreCourseRequirements
                    slidingScaleSection
                    registrationChecklist
                    importantDatesSection
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
                Text("NCAA Eligibility")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 72, height: 72)
                Image(systemName: "figure.run")
                    .font(.system(size: 32))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("NCAA Athlete Guide")
                .font(LadderTypography.headlineLarge)
                .foregroundStyle(LadderColors.onSurface)
            Text("If you plan to play college sports at an NCAA Division I or II school, you must meet academic eligibility requirements and register with the NCAA Eligibility Center.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: LadderSpacing.sm) {
                LadderTagChip("Division I", icon: "trophy")
                LadderTagChip("Division II", icon: "medal")
                LadderTagChip("16 Core Courses")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Core Course Requirements

    private var coreCourseRequirements: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Core Course Requirements")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("NCAA requires 16 core courses completed before your 7th semester of high school.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                // Header row
                HStack {
                    Text("Subject")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("DIV I")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.primary)
                        .labelTracking()
                        .frame(width: 50)
                    Text("DIV II")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.tertiary)
                        .labelTracking()
                        .frame(width: 50)
                }

                ForEach(coreCourses, id: \.subject) { course in
                    HStack {
                        Text(course.subject)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(course.divI)")
                            .font(LadderTypography.labelLarge)
                            .foregroundStyle(LadderColors.primary)
                            .frame(width: 50)
                        Text("\(course.divII)")
                            .font(LadderTypography.labelLarge)
                            .foregroundStyle(LadderColors.tertiary)
                            .frame(width: 50)
                    }
                    .padding(.vertical, LadderSpacing.xs)
                }

                // Totals
                HStack {
                    Text("Total Required")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("16")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.primary)
                        .frame(width: 50)
                    Text("16")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.tertiary)
                        .frame(width: 50)
                }
                .padding(.top, LadderSpacing.xs)
            }
        }
    }

    // MARK: - Sliding Scale

    private var slidingScaleSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("GPA / Test Score Sliding Scale")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Division I uses a sliding scale: the higher your core GPA, the lower the SAT/ACT score you need.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                VStack(spacing: LadderSpacing.sm) {
                    HStack {
                        Text("Your Core GPA")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Spacer()
                        Text(String(format: "%.2f", gpa))
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.primary)
                    }

                    Slider(value: $gpa, in: 2.0...4.0, step: 0.05)
                        .tint(LadderColors.primary)
                }

                HStack {
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("MINIMUM SAT")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Text("\(requiredSAT)")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.accentLime)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: LadderSpacing.xxs) {
                        Text("MINIMUM ACT")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Text("\(satToACT(requiredSAT))")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.primary)
                    }
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerHighest)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
            }
        }
    }

    // MARK: - Registration Checklist

    private var registrationChecklist: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("REGISTRATION STEPS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            ForEach(Array(registrationSteps.enumerated()), id: \.offset) { index, step in
                let isDone = completedSteps.contains(index)

                Button {
                    if isDone { completedSteps.remove(index) }
                    else { completedSteps.insert(index) }
                } label: {
                    HStack(alignment: .top, spacing: LadderSpacing.md) {
                        Image(systemName: step.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(isDone ? LadderColors.accentLime : LadderColors.primary)
                            .frame(width: 36, height: 36)
                            .background(isDone ? LadderColors.accentLime.opacity(0.2) : LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text(step.title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .strikethrough(isDone, color: LadderColors.onSurfaceVariant)
                            Text(step.detail)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()

                        Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(isDone ? LadderColors.accentLime : LadderColors.outlineVariant)
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Important Dates

    private var importantDatesSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .foregroundStyle(LadderColors.error)
                    Text("Key Deadlines")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }

                dateRow("Register by end of sophomore year", "Recommended")
                dateRow("Complete 16 core courses by 7th semester", "Required")
                dateRow("Submit test scores with code 9999", "SAT/ACT")
                dateRow("Request final transcript after graduation", "Required")
            }
        }
    }

    private func dateRow(_ title: String, _ badge: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            Spacer()
            Text(badge.uppercased())
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.primary)
                .labelTracking()
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xxs)
                .background(LadderColors.primary.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    // MARK: - Helpers

    private func satToACT(_ sat: Int) -> Int {
        // Approximate concordance
        switch sat {
        case 0...590: return 12
        case 591...670: return 15
        case 671...750: return 18
        case 751...830: return 20
        case 831...900: return 22
        case 901...970: return 24
        case 971...1040: return 26
        case 1041...1100: return 28
        default: return 30
        }
    }
}

#Preview {
    NavigationStack {
        NCAAAthleteView()
    }
}
