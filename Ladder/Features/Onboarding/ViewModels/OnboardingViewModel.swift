import SwiftUI

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

    func completeOnboarding(authManager: AuthManager) async {
        // TODO: Save to Supabase
        // let profile = StudentProfileModel(firstName: firstName, lastName: lastName)
        // profile.grade = grade
        // profile.gpa = gpa
        // etc.
        authManager.completeOnboarding()
    }
}
