import SwiftUI
import SwiftData

// MARK: - Counselor Verification View
// Allows freelance counselors to submit credentials for verification.

struct CounselorVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var counselorProfiles: [CounselorProfileModel]

    @State private var licenseNumber: String = ""
    @State private var schoolAffiliation: String = ""
    @State private var yearsOfExperience: String = ""
    @State private var linkedInURL: String = ""
    @State private var bio: String = ""
    @State private var selectedSpecialties: Set<String> = []
    @State private var isSubmitted: Bool = false
    @State private var isVerified: Bool = false

    private let allSpecialties = [
        "College Admissions",
        "Financial Aid",
        "STEM Programs",
        "Liberal Arts",
        "Athletics Recruiting",
        "International Students",
        "First-Generation Students",
        "Special Education",
        "Test Preparation",
        "Essay Coaching",
        "Career Counseling",
        "Scholarship Applications"
    ]

    private var existingProfile: CounselorProfileModel? {
        counselorProfiles.first
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    statusBanner
                    formSection
                    specialtiesSection
                    bioSection

                    if isSubmitted {
                        submittedConfirmation
                    } else {
                        submitButton
                    }

                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Verification")
                    .font(LadderTypography.titleSmall)
            }
        }
        .onAppear { loadExistingData() }
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: isVerified ? "checkmark.seal.fill" : "clock.fill")
                .font(.system(size: 22))
                .foregroundStyle(isVerified ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color(red: 0.9, green: 0.7, blue: 0.1))

            VStack(alignment: .leading, spacing: 2) {
                Text(isVerified ? "Verified" : (isSubmitted ? "Verification: Pending" : "Not Verified"))
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text(isVerified
                     ? "Your credentials have been confirmed."
                     : (isSubmitted
                        ? "Your credentials are being reviewed."
                        : "Submit your credentials to get verified."))
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()
        }
        .padding(LadderSpacing.lg)
        .background(
            (isVerified
                ? Color(red: 0.2, green: 0.7, blue: 0.3)
                : (isSubmitted
                    ? Color(red: 0.9, green: 0.7, blue: 0.1)
                    : LadderColors.outlineVariant)
            ).opacity(0.12)
        )
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Form Fields

    private var formSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            Text("Credentials")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            LadderTextField("License Number", text: $licenseNumber, icon: "number")
            LadderTextField("School Affiliation", text: $schoolAffiliation, icon: "building.columns")
            LadderTextField("Years of Experience", text: $yearsOfExperience, icon: "calendar")
            LadderTextField("LinkedIn URL", text: $linkedInURL, icon: "link")
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Specialties

    private var specialtiesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Specialties")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Select all that apply")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            FlowLayout(spacing: LadderSpacing.sm) {
                ForEach(allSpecialties, id: \.self) { specialty in
                    SpecialtyChip(
                        title: specialty,
                        isSelected: selectedSpecialties.contains(specialty)
                    ) {
                        if selectedSpecialties.contains(specialty) {
                            selectedSpecialties.remove(specialty)
                        } else {
                            selectedSpecialties.insert(specialty)
                        }
                    }
                }
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Bio

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Bio")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            TextEditor(text: $bio)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

            Text("\(bio.count)/500 characters")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        LadderPrimaryButton("Submit for Verification", icon: "checkmark.shield") {
            submitVerification()
        }
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Submitted Confirmation

    private var submittedConfirmation: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 32))
                .foregroundStyle(LadderColors.primary)

            Text("Credentials Submitted")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Your credentials are being reviewed. This typically takes 1-2 business days. You'll receive a notification once verification is complete.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(LadderSpacing.xl)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Data Persistence

    private func loadExistingData() {
        guard let profile = existingProfile else { return }
        schoolAffiliation = profile.schoolName
        bio = profile.bio ?? ""
        if let specialty = profile.specialty {
            selectedSpecialties = Set(specialty.components(separatedBy: ", "))
        }
        // Check UserDefaults for verification submission state
        isSubmitted = UserDefaults.standard.bool(forKey: "counselor_verification_submitted")
    }

    private func submitVerification() {
        let profile: CounselorProfileModel
        if let existing = existingProfile {
            profile = existing
        } else {
            profile = CounselorProfileModel(name: "", schoolName: schoolAffiliation)
            modelContext.insert(profile)
        }

        profile.schoolName = schoolAffiliation
        profile.specialty = selectedSpecialties.joined(separator: ", ")
        profile.bio = bio.isEmpty ? nil : bio
        profile.isFreelance = true

        // Store extra fields in UserDefaults since they're not on the model
        UserDefaults.standard.set(licenseNumber, forKey: "counselor_license_number")
        UserDefaults.standard.set(yearsOfExperience, forKey: "counselor_years_experience")
        UserDefaults.standard.set(linkedInURL, forKey: "counselor_linkedin_url")
        UserDefaults.standard.set(true, forKey: "counselor_verification_submitted")

        try? modelContext.save()

        withAnimation(.easeInOut(duration: 0.3)) {
            isSubmitted = true
        }
    }
}

// MARK: - Specialty Chip

struct SpecialtyChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.xs) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(title)
                    .font(LadderTypography.labelMedium)
            }
            .foregroundStyle(isSelected ? .white : LadderColors.onSurfaceVariant)
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(isSelected ? LadderColors.primary : LadderColors.surfaceContainerHigh)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
