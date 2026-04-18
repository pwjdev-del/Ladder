import SwiftUI
import SwiftData

// MARK: - Profile Settings View

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppCoordinator.self) private var coordinator
    @Query var profiles: [StudentProfileModel]
    @State private var firstName = "Kathan"
    @State private var lastName = "Patel"
    @State private var school = "Wharton High School"
    @State private var grade = 10
    @State private var gpa = "3.8"
    @State private var satScore = "1250"
    @State private var actScore = ""
    @State private var careerPath = "Medical Path"
    @State private var isFirstGen = false
    @State private var selectedState = "Florida"
    @State private var showCareerOverride = false

    private var student: StudentProfileModel? { profiles.first }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Avatar section
                    VStack(spacing: LadderSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer)
                                .frame(width: 80, height: 80)

                            Text("KP")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.primary)
                        }

                        Button("Change Photo") {}
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                    .frame(maxWidth: .infinity)

                    // Personal Info
                    settingsSection("PERSONAL INFORMATION") {
                        LadderTextField("First Name", text: $firstName, icon: "person")
                        LadderTextField("Last Name", text: $lastName, icon: "person")
                        LadderTextField("School", text: $school, icon: "building.2")

                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            HStack(spacing: LadderSpacing.md) {
                                Text("Grade")
                                    .font(LadderTypography.bodyLarge)
                                    .foregroundStyle(LadderColors.onSurface)
                                Spacer()
                                Text("\(grade)")
                                    .font(LadderTypography.bodyLarge)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            Text("Your grade updates automatically each school year.")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .padding(.vertical, LadderSpacing.sm)

                        // State picker
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            HStack(spacing: LadderSpacing.md) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 20)
                                Text("State")
                                    .font(LadderTypography.bodyLarge)
                                    .foregroundStyle(LadderColors.onSurface)
                                Spacer()
                                Picker("", selection: $selectedState) {
                                    ForEach(StateRequirementsEngine.supportedStates, id: \.self) { state in
                                        Text(state).tag(state)
                                    }
                                }
                                .tint(LadderColors.primary)
                            }
                            Text("Used for state-specific scholarships and graduation requirements.")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .padding(.vertical, LadderSpacing.sm)

                        Toggle(isOn: $isFirstGen) {
                            Text("First-Generation College Student")
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                        .tint(LadderColors.accentLime)
                        .padding(.vertical, LadderSpacing.sm)
                    }

                    // Academic Info
                    settingsSection("ACADEMIC PROFILE") {
                        LadderTextField("GPA", text: $gpa, icon: "chart.bar")
                        LadderTextField("SAT Score", text: $satScore, icon: "pencil.line")
                        LadderTextField("ACT Score (optional)", text: $actScore, icon: "pencil.line")

                        // Career Path row
                        HStack(spacing: LadderSpacing.md) {
                            Image(systemName: "sparkle.magnifyingglass")
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                Text("Career Path")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Text(student?.careerPath ?? "Not set")
                                    .font(LadderTypography.bodyLarge)
                                    .foregroundStyle(LadderColors.onSurface)
                                if let major = student?.selectedMajor {
                                    Text(major)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.primary)
                                }
                            }

                            Spacer()

                            Button {
                                showCareerOverride = true
                            } label: {
                                Text("Change")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.primary)
                                    .padding(.horizontal, LadderSpacing.md)
                                    .padding(.vertical, LadderSpacing.sm)
                                    .background(LadderColors.primaryContainer.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, LadderSpacing.xs)
                    }

                    LadderPrimaryButton("Save Changes") {
                        // Persist state to student profile and notify ConnectionEngine
                        let descriptor = FetchDescriptor<StudentProfileModel>()
                        if let profile = try? modelContext.fetch(descriptor).first {
                            profile.state = selectedState
                            ConnectionEngine.shared.onStateChanged(newState: selectedState, context: modelContext)
                            try? modelContext.save()
                        }
                        dismiss()
                    }

                    settingsSection("LEGAL & PRIVACY") {
                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                coordinator.navigate(to: .legalSettings)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundStyle(LadderColors.primary)
                                    .frame(width: 24)
                                Text("Privacy, Terms & Data Rights")
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            .padding(.vertical, LadderSpacing.xs)
                        }
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
                Text("Edit Profile")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showCareerOverride) {
            CareerOverrideSheet()
        }
        .onAppear {
            // Load student's current state from profile
            let descriptor = FetchDescriptor<StudentProfileModel>()
            if let profile = try? modelContext.fetch(descriptor).first,
               let state = profile.state, !state.isEmpty {
                selectedState = state
            }
        }
    }

    private func settingsSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: LadderSpacing.sm) {
                content()
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var deadlineReminders = true
    @State private var taskReminders = true
    @State private var dailyTip = true
    @State private var streakReminder = true
    @State private var newScholarships = false
    @State private var applicationUpdates = true

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    settingsSection("REMINDERS") {
                        notificationToggle("Deadline Reminders", subtitle: "Get notified before application deadlines", isOn: $deadlineReminders)
                        notificationToggle("Task Reminders", subtitle: "Daily reminder to complete your tasks", isOn: $taskReminders)
                        notificationToggle("Streak Reminder", subtitle: "Don't break your streak!", isOn: $streakReminder)
                    }

                    settingsSection("CONTENT") {
                        notificationToggle("Daily Tip", subtitle: "Receive a daily college prep tip", isOn: $dailyTip)
                        notificationToggle("New Scholarships", subtitle: "Get notified about matching scholarships", isOn: $newScholarships)
                        notificationToggle("Application Updates", subtitle: "Status changes and decision notifications", isOn: $applicationUpdates)
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
                Text("Notifications")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private func settingsSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: 0) {
                content()
            }
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    private func notificationToggle(_ title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)

                Text(subtitle)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
        .tint(LadderColors.accentLime)
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerLow)
    }
}

#Preview {
    NavigationStack {
        ProfileSettingsView()
    }
}
