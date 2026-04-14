import SwiftUI
import SwiftData

// MARK: - Onboarding ViewModel
// Manages the 5-step onboarding flow data

@Observable
final class OnboardingViewModel {
    // Step tracking
    var currentStep = 1
    let totalSteps = 5

    // Step 2: Basic Info
    var firstName = ""
    var lastName = ""
    var grade = 10
    var schoolName = ""
    var studentId = ""
    var isFirstGen = false

    // Step 3: Academic Profile
    var gpa: Double = 3.5
    var satScore: String = ""
    var actScore: String = ""
    var apCourses: [String] = []
    var newCourse = ""

    // Step 4: Dream Schools
    var selectedCollegeIds: Set<String> = []

    // Step 5: Interests
    var interests: [String] = []
    var extracurriculars: [String] = []

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

    // MARK: - Save Profile

    /// Persists the onboarding data into SwiftData as a brand-new StudentProfileModel
    /// scoped to the current authManager.userId. Wipes any existing profile for strict
    /// sandboxing between accounts.
    @MainActor
    func completeOnboarding(authManager: AuthManager, modelContext: ModelContext) async {
        // Ensure we have a userId — generate if missing (offline/dev mode)
        if authManager.userId == nil {
            authManager.userId = UUID().uuidString
        }
        let currentUserId = authManager.userId!

        // STRICT SANDBOX: delete any leftover profile from a previous account on this device
        let fetch = FetchDescriptor<StudentProfileModel>()
        if let existing = try? modelContext.fetch(fetch) {
            for profile in existing {
                modelContext.delete(profile)
            }
        }

        // Create and populate the new profile
        let profile = StudentProfileModel(firstName: firstName, lastName: lastName)
        profile.userId = currentUserId
        profile.grade = grade
        profile.schoolName = schoolName.isEmpty ? nil : schoolName
        profile.studentId = studentId.isEmpty ? nil : studentId
        profile.isFirstGen = isFirstGen
        profile.gpa = gpa > 0 ? gpa : nil
        profile.satScore = Int(satScore)
        profile.actScore = Int(actScore)
        profile.apCourses = apCourses
        profile.interests = interests
        profile.extracurriculars = extracurriculars
        profile.savedCollegeIds = Array(selectedCollegeIds)

        modelContext.insert(profile)

        do {
            try modelContext.save()
        } catch {
            print("[Onboarding] Failed to save profile: \(error)")
        }

        authManager.completeOnboarding()
    }
}
