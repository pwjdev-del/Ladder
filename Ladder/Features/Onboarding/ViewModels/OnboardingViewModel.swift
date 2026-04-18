import SwiftUI
import SwiftData

// MARK: - Onboarding ViewModel
// Manages the 6-step onboarding flow data and saves to SwiftData

@Observable
final class OnboardingViewModel {
    // Step tracking (6 steps: Welcome, Basic Info, Academic, Career Quiz, Dream Schools, Summary)
    var currentStep = 1 { didSet { persistDraft() } }
    let totalSteps = 6

    // Step 4: Career Quiz
    var careerScores: [String: Int] = ["STEM": 0, "Medical": 0, "Business": 0, "Humanities": 0, "Sports": 0] { didSet { persistDraft() } }
    var careerBucket: String? { didSet { persistDraft() } }
    var quizCompleted = false { didSet { persistDraft() } }

    // Step 2: Basic Info
    var firstName = "" { didSet { persistDraft() } }
    var lastName = "" { didSet { persistDraft() } }
    var grade = 10 { didSet { persistDraft() } }
    var schoolName = "" { didSet { persistDraft() } }
    var studentId = "" { didSet { persistDraft() } }
    var isFirstGen = false { didSet { persistDraft() } }
    var isFloridaResident: Bool = false { didSet { persistDraft() } }
    var selectedState: String = "" { didSet { persistDraft() } }
    var classDifficultyPreference: String = "balanced" { didSet { persistDraft() } }
    var parentIncomeBracket: String = "" { didSet { persistDraft() } }
    var freeReducedLunch: Bool = false { didSet { persistDraft() } }

    // Step 3: Academic Profile
    var gpa: Double = 3.5 { didSet { persistDraft() } }
    var satScore: String = "" { didSet { persistDraft() } }
    var actScore: String = "" { didSet { persistDraft() } }
    var apCourses: [String] = [] { didSet { persistDraft() } }
    var newCourse = ""

    // Step 4: Dream Schools
    var selectedCollegeIds: Set<String> = [] { didSet { persistDraft() } }

    // Step 5: Interests
    var interests: [String] = [] { didSet { persistDraft() } }
    var extracurriculars: [String] = [] { didSet { persistDraft() } }

    // MARK: - Draft persistence

    private static let draftKey = "onboarding_draft_v1"
    private var draftLoaded = false
    private var isLoadingDraft = false

    init() {
        loadDraft()
    }

    private struct Draft: Codable {
        var currentStep: Int
        var firstName: String
        var lastName: String
        var grade: Int
        var schoolName: String
        var studentId: String
        var isFirstGen: Bool
        var isFloridaResident: Bool
        var selectedState: String
        var classDifficultyPreference: String
        var parentIncomeBracket: String
        var freeReducedLunch: Bool
        var gpa: Double
        var satScore: String
        var actScore: String
        var apCourses: [String]
        var selectedCollegeIds: [String]
        var interests: [String]
        var extracurriculars: [String]
        var careerScores: [String: Int]
        var careerBucket: String?
        var quizCompleted: Bool
    }

    private func loadDraft() {
        guard !draftLoaded,
              let data = UserDefaults.standard.data(forKey: Self.draftKey),
              let draft = try? JSONDecoder().decode(Draft.self, from: data) else {
            draftLoaded = true
            return
        }
        isLoadingDraft = true
        currentStep = draft.currentStep
        firstName = draft.firstName
        lastName = draft.lastName
        grade = draft.grade
        schoolName = draft.schoolName
        studentId = draft.studentId
        isFirstGen = draft.isFirstGen
        isFloridaResident = draft.isFloridaResident
        selectedState = draft.selectedState
        classDifficultyPreference = draft.classDifficultyPreference
        parentIncomeBracket = draft.parentIncomeBracket
        freeReducedLunch = draft.freeReducedLunch
        gpa = draft.gpa
        satScore = draft.satScore
        actScore = draft.actScore
        apCourses = draft.apCourses
        selectedCollegeIds = Set(draft.selectedCollegeIds)
        interests = draft.interests
        extracurriculars = draft.extracurriculars
        careerScores = draft.careerScores
        careerBucket = draft.careerBucket
        quizCompleted = draft.quizCompleted
        isLoadingDraft = false
        draftLoaded = true
    }

    private func persistDraft() {
        guard draftLoaded, !isLoadingDraft else { return }
        let draft = Draft(
            currentStep: currentStep,
            firstName: firstName,
            lastName: lastName,
            grade: grade,
            schoolName: schoolName,
            studentId: studentId,
            isFirstGen: isFirstGen,
            isFloridaResident: isFloridaResident,
            selectedState: selectedState,
            classDifficultyPreference: classDifficultyPreference,
            parentIncomeBracket: parentIncomeBracket,
            freeReducedLunch: freeReducedLunch,
            gpa: gpa,
            satScore: satScore,
            actScore: actScore,
            apCourses: apCourses,
            selectedCollegeIds: Array(selectedCollegeIds),
            interests: interests,
            extracurriculars: extracurriculars,
            careerScores: careerScores,
            careerBucket: careerBucket,
            quizCompleted: quizCompleted
        )
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: Self.draftKey)
        }
    }

    private func clearDraft() {
        UserDefaults.standard.removeObject(forKey: Self.draftKey)
    }

    // Income bracket options
    static let incomeBrackets = ["Under $30K", "$30K-$48K", "$48K-$75K", "$75K-$110K", "Over $110K"]

    // MARK: - Navigation

    func nextStep() {
        if currentStep < totalSteps {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }

    func previousStep() {
        if currentStep > 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    // MARK: - Validation

    var canProceedStep2: Bool {
        !firstName.isEmpty && !lastName.isEmpty
    }

    var canProceedStep3: Bool {
        gpa > 0
    }

    // MARK: - AP Course Management

    func addCourse() {
        let trimmed = newCourse.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !apCourses.contains(trimmed) else { return }
        apCourses.append(trimmed)
        newCourse = ""
    }

    func removeCourse(_ course: String) {
        apCourses.removeAll { $0 == course }
    }

    // MARK: - Save Profile to SwiftData

    var saveError: String?

    @MainActor
    @discardableResult
    func completeOnboarding(authManager: AuthManager, context: ModelContext) async -> Bool {
        // Build the student profile from onboarding data
        let profile = StudentProfileModel(firstName: firstName, lastName: lastName)
        profile.grade = DomainValidator.clampedGrade(grade)
        profile.schoolName = schoolName.isEmpty ? nil : schoolName
        profile.studentId = studentId.isEmpty ? nil : studentId

        if DomainValidator.isValidGPA(gpa) { profile.gpa = gpa }

        if let sat = Int(satScore), DomainValidator.isValidSATTotal(sat) {
            profile.satScore = sat
        }
        if let act = Int(actScore), (1...36).contains(act) {
            profile.actScore = act
        }

        profile.isFirstGen = isFirstGen
        profile.isFloridaResident = isFloridaResident
        profile.state = DomainValidator.normalizedState(selectedState)
        profile.classDifficultyPreference = classDifficultyPreference
        profile.parentIncomeBracket = parentIncomeBracket.isEmpty ? nil : parentIncomeBracket
        profile.freeReducedLunch = freeReducedLunch
        profile.careerPath = careerBucket
        profile.apCourses = apCourses
        profile.savedCollegeIds = Array(selectedCollegeIds)
        profile.interests = interests
        profile.extracurriculars = extracurriculars
        profile.userId = authManager.userId

        context.insert(profile)

        do {
            try context.save()
        } catch {
            Log.error("Onboarding save failed: \(error)")
            saveError = error.localizedDescription
            context.rollback()
            return false
        }

        clearDraft()
        authManager.completeOnboarding()
        return true
    }
}
