import SwiftUI
import SwiftData

// MARK: - Onboarding Container
// Routes between 5 onboarding steps with shared ViewModel

struct OnboardingContainerView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var dataContext
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout (unchanged)

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                OnboardingProgressBar(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps
                )
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.top, LadderSpacing.md)

                // Step content
                TabView(selection: $viewModel.currentStep) {
                    OnboardingStep1View(viewModel: viewModel)
                        .tag(1)
                    OnboardingStep2View(viewModel: viewModel)
                        .tag(2)
                    OnboardingStep3View(viewModel: viewModel)
                        .tag(3)
                    OnboardingStep4View(viewModel: viewModel)
                        .tag(4)
                    OnboardingStep5View(viewModel: viewModel)
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
    }

    // MARK: - iPad Layout (two-column editorial)

    private var iPadLayout: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Left editorial panel (~40%)
                OnboardingEditorialPanel(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps
                )
                .frame(width: geo.size.width * 0.4)

                // Right content panel (~60%)
                ZStack {
                    LadderColors.surface.ignoresSafeArea()

                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            Group {
                                switch viewModel.currentStep {
                                case 1: OnboardingStep1View(viewModel: viewModel)
                                case 2: OnboardingStep2View(viewModel: viewModel)
                                case 3: OnboardingStep3View(viewModel: viewModel)
                                case 4: OnboardingStep4View(viewModel: viewModel)
                                case 5: OnboardingStep5View(viewModel: viewModel)
                                default: OnboardingStep1View(viewModel: viewModel)
                                }
                            }
                            .frame(maxWidth: 600)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, LadderSpacing.xxl)
                            .padding(.top, LadderSpacing.xxl)
                            .padding(.bottom, LadderSpacing.xxxxl)
                        }
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)

                        // Bottom bar: progress + Back/Next
                        OnboardingBottomBar(viewModel: viewModel)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - iPad Editorial Panel

private struct OnboardingEditorialPanel: View {
    let currentStep: Int
    let totalSteps: Int

    private var headline: String {
        switch currentStep {
        case 1: return "Welcome to your next chapter."
        case 2: return "Tell us who you are."
        case 3: return "Your academic story."
        case 4: return "Dream. Aim. Ladder up."
        case 5: return "Ready to lead."
        default: return "Your Future, Designed by You."
        }
    }

    private var subhead: String {
        switch currentStep {
        case 1: return "An editorial companion for the ambitious student."
        case 2: return "We personalize every recommendation for you."
        case 3: return "GPA, tests, and coursework — your foundation."
        case 4: return "The schools that make your heart race."
        case 5: return "Your personalized roadmap awaits."
        default: return ""
        }
    }

    private var iconName: String {
        switch currentStep {
        case 1: return "building.columns.fill"
        case 2: return "person.fill"
        case 3: return "books.vertical.fill"
        case 4: return "star.fill"
        case 5: return "trophy.fill"
        default: return "sparkles"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [LadderColors.primary, LadderColors.primaryContainer],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                // Step indicator
                HStack(spacing: LadderSpacing.sm) {
                    Text("STEP \(currentStep)")
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(.white.opacity(0.9))
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.xs)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())

                    Text("of \(totalSteps)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                // Decorative icon
                Image(systemName: iconName)
                    .font(.system(size: 96, weight: .light))
                    .foregroundStyle(LadderColors.accentLime.opacity(0.9))
                    .ladderShadow(LadderElevation.glow)

                // Editorial headline
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    Text(headline)
                        .font(LadderTypography.displayLargeItalic)
                        .foregroundStyle(.white)
                        .editorialTracking()
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subhead)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Decorative quote
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("\u{201C}The future belongs to those who prepare for it today.\u{201D}")
                        .font(LadderTypography.bodyLarge)
                        .italic()
                        .foregroundStyle(.white.opacity(0.8))
                    Text("— Malcolm X")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(.white.opacity(0.6))
                        .labelTracking()
                }
            }
            .padding(LadderSpacing.xxxl)
        }
    }
}

// MARK: - iPad Bottom Bar

private struct OnboardingBottomBar: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: LadderSpacing.md) {
            OnboardingProgressBar(
                currentStep: viewModel.currentStep,
                totalSteps: viewModel.totalSteps
            )

            HStack(spacing: LadderSpacing.md) {
                if viewModel.currentStep > 1 {
                    Button {
                        viewModel.previousStep()
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .padding(.horizontal, LadderSpacing.xl)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Capsule())
                    }
                }

                Spacer()

                Text("Step \(viewModel.currentStep) of \(viewModel.totalSteps)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
            }
        }
        .padding(.horizontal, LadderSpacing.xxl)
        .padding(.vertical, LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: LadderSpacing.xs) {
            ForEach(1...totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? LadderColors.accentLime : LadderColors.surfaceContainerHighest)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}

// MARK: - Step 1: Welcome

struct OnboardingStep1View: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: LadderSpacing.xxl) {
            Spacer()

            // Hero image placeholder
            RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primaryContainer, LadderColors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 260)
                .overlay(
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.3))
                )
                .padding(.horizontal, LadderSpacing.lg)

            VStack(spacing: LadderSpacing.md) {
                Text("Your Future,")
                    .font(LadderTypography.displaySmall)
                    .foregroundStyle(LadderColors.onSurface)
                +
                Text(" Designed by You")
                    .font(LadderTypography.displaySmall)
                    .italic()
                    .foregroundStyle(LadderColors.primary)

                Text("Ladder bridges academic excellence and personal growth to guide you through every step of your college journey.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.xl)
            }

            Spacer()

            LadderAccentButton("Let's Get Started", icon: "arrow.right") {
                viewModel.nextStep()
            }
            .padding(.horizontal, LadderSpacing.lg)
            .padding(.bottom, LadderSpacing.xxl)
        }
    }
}

// MARK: - Step 2: Basic Info

struct OnboardingStep2View: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Tell Us About You")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Step 2 of 5")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                VStack(spacing: LadderSpacing.lg) {
                    LadderTextField("First Name", text: $viewModel.firstName, icon: "person")
                    LadderTextField("Last Name", text: $viewModel.lastName, icon: "person")
                    LadderTextField("School Name", text: $viewModel.schoolName, icon: "building.2")
                    LadderTextField("Student ID (optional)", text: $viewModel.studentId, icon: "number")

                    // Grade selector
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("GRADE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        HStack(spacing: LadderSpacing.sm) {
                            ForEach([9, 10, 11, 12], id: \.self) { grade in
                                Button {
                                    viewModel.grade = grade
                                } label: {
                                    Text("\(grade)th")
                                        .font(LadderTypography.labelLarge)
                                        .foregroundStyle(viewModel.grade == grade ? .white : LadderColors.onSurfaceVariant)
                                        .padding(.horizontal, LadderSpacing.md)
                                        .padding(.vertical, LadderSpacing.sm)
                                        .background(viewModel.grade == grade ? LadderColors.primary : LadderColors.surfaceContainerHigh)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // First-gen toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("First-Generation Student")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Neither parent completed a 4-year degree")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.isFirstGen)
                            .tint(LadderColors.accentLime)
                            .labelsHidden()
                    }
                }

                Spacer().frame(height: LadderSpacing.md)

                LadderPrimaryButton("Continue", icon: "arrow.right") {
                    viewModel.nextStep()
                }
                .opacity(viewModel.canProceedStep2 ? 1 : 0.5)
                .disabled(!viewModel.canProceedStep2)
            }
            .padding(LadderSpacing.lg)
        }
    }
}

// MARK: - Step 3: Academic Profile

struct OnboardingStep3View: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Academic Profile")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Step 3 of 5")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                // GPA Slider
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack {
                        Text("GPA")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Spacer()
                        Text(String(format: "%.2f", viewModel.gpa))
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                    }

                    Slider(value: $viewModel.gpa, in: 0...5.0, step: 0.01)
                        .tint(LadderColors.primary)
                }
                .padding(LadderSpacing.lg)
                .background(LadderColors.surfaceContainerHighest)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                // Test Scores
                HStack(spacing: LadderSpacing.md) {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("SAT")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        TextField("1500", text: $viewModel.satScore)
                            .font(LadderTypography.titleLarge)
                            .keyboardType(.numberPad)
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerHighest)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("ACT")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        TextField("34", text: $viewModel.actScore)
                            .font(LadderTypography.titleLarge)
                            .keyboardType(.numberPad)
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerHighest)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                }

                // AP/Honors Courses
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("ADVANCED COURSEWORK")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    FlowLayout(spacing: LadderSpacing.sm) {
                        ForEach(viewModel.apCourses, id: \.self) { course in
                            LadderRemovableChip(title: course) {
                                viewModel.removeCourse(course)
                            }
                        }

                        Button {
                            viewModel.addCourse()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Add Course")
                            }
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.surfaceContainerHighest)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(LadderSpacing.lg)
                .background(LadderColors.surfaceContainerHighest)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                LadderPrimaryButton("Save & Continue", icon: "arrow.right") {
                    viewModel.nextStep()
                }
            }
            .padding(LadderSpacing.lg)
        }
    }
}

// MARK: - Step 4: Dream Schools

struct OnboardingStep4View: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var searchText = ""

    // Sample colleges for the grid
    private let sampleColleges = [
        ("Harvard", "Cambridge, MA"),
        ("Stanford", "Stanford, CA"),
        ("MIT", "Cambridge, MA"),
        ("RIT", "Rochester, NY"),
        ("UF", "Gainesville, FL"),
        ("Georgia Tech", "Atlanta, GA"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Your Dream Schools")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Step 4 of 5")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                LadderSearchBar(placeholder: "Search colleges...", text: $searchText)

                // College grid
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: LadderSpacing.md) {
                    ForEach(sampleColleges, id: \.0) { college in
                        let isSelected = viewModel.selectedCollegeIds.contains(college.0)
                        Button {
                            if isSelected {
                                viewModel.selectedCollegeIds.remove(college.0)
                            } else {
                                viewModel.selectedCollegeIds.insert(college.0)
                            }
                        } label: {
                            VStack(spacing: LadderSpacing.sm) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                                        .fill(LadderColors.surfaceContainerHigh)
                                        .frame(height: 80)

                                    Image(systemName: "building.columns")
                                        .font(.system(size: 32))
                                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.3))

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(LadderColors.accentLime)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                            .padding(LadderSpacing.sm)
                                    }
                                }

                                Text(college.0)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)

                                Text(college.1)
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            .padding(LadderSpacing.sm)
                            .background(isSelected ? LadderColors.surfaceContainerLow : LadderColors.surfaceContainerLowest)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                                    .stroke(isSelected ? LadderColors.accentLime : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    LadderTertiaryButton("Skip for now") { viewModel.nextStep() }
                    Spacer()
                }

                LadderPrimaryButton("Continue", icon: "arrow.right") {
                    viewModel.nextStep()
                }
            }
            .padding(LadderSpacing.lg)
        }
    }
}

// MARK: - Step 5: Ready to Lead

struct OnboardingStep5View: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var dataContext

    var body: some View {
        ScrollView {
            VStack(spacing: LadderSpacing.xxl) {
                Spacer().frame(height: LadderSpacing.xl)

                // Trophy
                ZStack {
                    Circle()
                        .fill(LadderColors.secondaryFixed.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(LadderColors.secondaryFixed)
                }

                VStack(spacing: LadderSpacing.sm) {
                    Text("Ready to Lead?")
                        .font(LadderTypography.displaySmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Your personalized college roadmap is ready")
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                // Profile summary card
                LadderCard(elevated: true) {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LadderColors.primary)

                            VStack(alignment: .leading) {
                                Text(viewModel.firstName.isEmpty ? "Student" : viewModel.firstName)
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("Grade \(viewModel.grade) · GPA \(String(format: "%.2f", viewModel.gpa))")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }

                        // Blueprint card
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("12")
                                    .font(LadderTypography.headlineMedium)
                                    .foregroundStyle(.white)
                                Text("Milestones")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(.white.opacity(0.7))
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(viewModel.selectedCollegeIds.count)")
                                    .font(LadderTypography.headlineMedium)
                                    .foregroundStyle(.white)
                                Text("Top Targets")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(
                            LinearGradient(
                                colors: [LadderColors.primary, LadderColors.primaryContainer],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                }
                .padding(.horizontal, LadderSpacing.lg)

                VStack(spacing: LadderSpacing.md) {
                    LadderAccentButton("Enter Dashboard", icon: "arrow.right") {
                        Task { await viewModel.completeOnboarding(authManager: authManager, modelContext: dataContext) }
                    }

                    LadderSecondaryButton("Review Full Profile") {
                        // Complete onboarding, then user can navigate to Profile from MainTabView
                        Task { await viewModel.completeOnboarding(authManager: authManager, modelContext: dataContext) }
                    }
                }
                .padding(.horizontal, LadderSpacing.lg)

                Spacer().frame(height: LadderSpacing.xxl)
            }
        }
    }
}

// MARK: - Flow Layout (for wrapping chips)

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
