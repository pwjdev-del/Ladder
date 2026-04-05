import SwiftUI

// MARK: - Profile Settings View

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = "Kathan"
    @State private var lastName = "Patel"
    @State private var school = "Wharton High School"
    @State private var grade = 10
    @State private var gpa = "3.8"
    @State private var satScore = "1250"
    @State private var actScore = ""
    @State private var careerPath = "Medical Path"
    @State private var isFirstGen = false

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

                        HStack(spacing: LadderSpacing.md) {
                            Text("Grade")
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                            Picker("", selection: $grade) {
                                ForEach(9...12, id: \.self) { g in
                                    Text("\(g)").tag(g)
                                }
                            }
                            .tint(LadderColors.primary)
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
                        LadderTextField("Career Path", text: $careerPath, icon: "sparkle.magnifyingglass")
                    }

                    LadderPrimaryButton("Save Changes") {
                        dismiss()
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
