import SwiftUI
import SwiftData

// MARK: - Onboarding Container
// Routes between 6 onboarding steps with shared ViewModel

struct OnboardingContainerView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
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

                // Step content (6 steps: Welcome, Basic Info, Academic, Career Quiz, Dream Schools, Summary)
                TabView(selection: $viewModel.currentStep) {
                    OnboardingStep1View(viewModel: viewModel)
                        .tag(1)
                    OnboardingStep2View(viewModel: viewModel)
                        .tag(2)
                    OnboardingStep3View(viewModel: viewModel)
                        .tag(3)
                    OnboardingCareerQuizStep(viewModel: viewModel)
                        .tag(4)
                    OnboardingStep4View(viewModel: viewModel)
                        .tag(5)
                    OnboardingStep5View(viewModel: viewModel)
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
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

            // Ladder logo
            Image("LadderLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .shadow(color: LadderColors.primary.opacity(0.3), radius: 20, y: 8)
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

                    // State picker
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("STATE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        Text("Used for state-specific graduation requirements and scholarships")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        Menu {
                            ForEach(StateRequirementsEngine.supportedStates, id: \.self) { state in
                                Button(state) {
                                    viewModel.selectedState = state
                                    // Auto-set Florida resident if FL selected
                                    viewModel.isFloridaResident = (state == "Florida")
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedState.isEmpty ? "Select your state" : viewModel.selectedState)
                                    .font(LadderTypography.bodyLarge)
                                    .foregroundStyle(viewModel.selectedState.isEmpty ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerHighest)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }
                    }

                    // Florida Resident toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Florida Resident")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Activates Bright Futures tracking and in-state tuition display")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.isFloridaResident)
                            .tint(LadderColors.accentLime)
                            .labelsHidden()
                    }

                    // Class difficulty preference
                    ClassDifficultyPickerView(selectedDifficulty: $viewModel.classDifficultyPreference)

                    // Free/Reduced Lunch toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Free/Reduced Lunch")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("May qualify you for SAT fee waivers and application fee waivers")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.freeReducedLunch)
                            .tint(LadderColors.accentLime)
                            .labelsHidden()
                    }

                    // Parent Income Bracket picker
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("PARENT INCOME BRACKET")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        Text("Used to estimate financial aid eligibility — never shared")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        FlowLayout(spacing: LadderSpacing.sm) {
                            ForEach(OnboardingViewModel.incomeBrackets, id: \.self) { bracket in
                                LadderFilterChip(title: bracket, isSelected: viewModel.parentIncomeBracket == bracket) {
                                    viewModel.parentIncomeBracket = bracket
                                }
                            }
                        }
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

// MARK: - Step 4: Career Quiz (embedded in onboarding)

struct OnboardingCareerQuizStep: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var currentQuestion = 0
    @State private var selectedOption = -1
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 0) {
            if showResult {
                // Result view
                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        let bucket = viewModel.careerBucket ?? "STEM"
                        let info = BucketInfo.all[bucket]!

                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [info.color, info.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 110, height: 110)
                            Image(systemName: info.icon).font(.system(size: 40)).foregroundStyle(.white)
                        }
                        .padding(.top, LadderSpacing.xl)

                        VStack(spacing: LadderSpacing.sm) {
                            Text(info.archetype)
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(bucket.uppercased())
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.accentLime)
                                .labelTracking()
                            Text(info.description)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, LadderSpacing.lg)
                        }

                        // Score bars
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Your Career Profile").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                                let total = max(viewModel.careerScores.values.reduce(0, +), 1)
                                ForEach(["STEM", "Medical", "Business", "Humanities", "Sports"], id: \.self) { b in
                                    let pct = Double(viewModel.careerScores[b] ?? 0) / Double(total)
                                    HStack(spacing: LadderSpacing.sm) {
                                        Text(b).font(LadderTypography.bodySmall)
                                            .foregroundStyle(b == bucket ? LadderColors.onSurface : LadderColors.onSurfaceVariant)
                                            .frame(width: 80, alignment: .leading)
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 3).fill(LadderColors.surfaceContainerHigh).frame(height: 6)
                                                RoundedRectangle(cornerRadius: 3).fill(b == bucket ? LadderColors.accentLime : LadderColors.primary.opacity(0.4))
                                                    .frame(width: max(geo.size.width * pct, 0), height: 6)
                                            }
                                        }.frame(height: 6)
                                        Text("\(Int(pct * 100))%").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant).frame(width: 30, alignment: .trailing)
                                    }
                                }
                            }
                        }

                        LadderPrimaryButton("Continue to Dream Schools", icon: "arrow.right") {
                            viewModel.quizCompleted = true
                            viewModel.nextStep()
                        }
                        .padding(.horizontal, LadderSpacing.md)
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.bottom, 40)
                }
            } else {
                // Quiz questions
                VStack(spacing: LadderSpacing.xs) {
                    HStack {
                        Text("Career Discovery — Question \(currentQuestion + 1)/\(QuizData.questions.count)")
                            .font(LadderTypography.labelMedium).foregroundStyle(LadderColors.onSurfaceVariant)
                        Spacer()
                    }
                    LinearProgressBar(progress: Double(currentQuestion + 1) / Double(QuizData.questions.count))
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.top, LadderSpacing.sm)

                ScrollView {
                    let q = QuizData.questions[currentQuestion]
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                        HStack(spacing: LadderSpacing.sm) {
                            ZStack {
                                Circle().fill(LadderColors.primaryContainer.opacity(0.3)).frame(width: 44, height: 44)
                                Image(systemName: q.icon).font(.system(size: 18)).foregroundStyle(LadderColors.primary)
                            }
                            Text(q.question).font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, LadderSpacing.lg)
                        .padding(.top, LadderSpacing.md)

                        VStack(spacing: LadderSpacing.sm) {
                            ForEach(Array(q.options.enumerated()), id: \.offset) { idx, opt in
                                Button {
                                    withAnimation(.spring(response: 0.25)) { selectedOption = idx }
                                } label: {
                                    HStack(spacing: LadderSpacing.md) {
                                        ZStack {
                                            Circle().stroke(selectedOption == idx ? LadderColors.accentLime : LadderColors.outlineVariant, lineWidth: 2).frame(width: 20, height: 20)
                                            if selectedOption == idx { Circle().fill(LadderColors.accentLime).frame(width: 10, height: 10) }
                                        }
                                        Text(opt).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurface).multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(LadderSpacing.md)
                                    .background(selectedOption == idx ? LadderColors.primaryContainer.opacity(0.2) : LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, LadderSpacing.lg)
                    }
                    .padding(.bottom, 100)
                }

                LadderPrimaryButton(
                    currentQuestion == QuizData.questions.count - 1 ? "See My Results" : "Next",
                    icon: currentQuestion == QuizData.questions.count - 1 ? "sparkles" : "arrow.right"
                ) {
                    guard selectedOption >= 0 else { return }
                    let weights = QuizData.questions[currentQuestion].weights[selectedOption]
                    for (bucket, pts) in weights { viewModel.careerScores[bucket, default: 0] += pts }
                    if currentQuestion == QuizData.questions.count - 1 {
                        viewModel.careerBucket = viewModel.careerScores.max(by: { $0.value < $1.value })?.key ?? "STEM"
                        withAnimation { showResult = true }
                    } else {
                        withAnimation { currentQuestion += 1; selectedOption = -1 }
                    }
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.bottom, LadderSpacing.md)
                .opacity(selectedOption < 0 ? 0.5 : 1)
            }
        }
    }
}

// MARK: - Step 5 (was 4): Dream Schools — already defined above as OnboardingStep4View

// MARK: - Step 6 (was 5): Ready to Lead

struct OnboardingStep5View: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context

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
                        Task { await viewModel.completeOnboarding(authManager: authManager, context: context) }
                    }

                    LadderSecondaryButton("Review Full Profile") {
                        // TODO: Navigate to profile review
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
