import SwiftUI

// MARK: - Profile Settings View

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var firstName = "Kathan"
    @State private var lastName = "Patel"
    @State private var school = "Wharton High School"
    @State private var grade = 10
    @State private var gpa = "3.8"
    @State private var satScore = "1250"
    @State private var actScore = ""
    @State private var careerPath = "Medical Path"
    @State private var isFirstGen = false
    @State private var selectedCategory: SettingsCategory = .profile

    enum SettingsCategory: String, CaseIterable, Identifiable {
        case profile = "Profile"
        case account = "Account"
        case notifications = "Notifications"
        case privacy = "Privacy"
        case legal = "Legal"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .profile: return "person.fill"
            case .account: return "lock.fill"
            case .notifications: return "bell.fill"
            case .privacy: return "hand.raised.fill"
            case .legal: return "doc.text.fill"
            }
        }
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
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

                    versionRow
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }

    private var versionRow: some View {
        HStack {
            Text("Version")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            Text("\(v) (\(b))")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
        }
        .padding(.horizontal, LadderSpacing.lg)
        .padding(.vertical, LadderSpacing.md)
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(alignment: .top, spacing: LadderSpacing.xl) {
                // Left sidebar
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("SETTINGS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.top, LadderSpacing.sm)

                    ForEach(SettingsCategory.allCases) { category in
                        categoryRow(category)
                    }
                    Spacer()
                }
                .frame(maxWidth: 300)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))

                // Right content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                        categoryContent
                    }
                    .padding(LadderSpacing.xl)
                    .frame(maxWidth: 820, alignment: .leading)
                    .padding(.bottom, LadderSpacing.xxl)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, LadderSpacing.xxl)
            .padding(.vertical, LadderSpacing.xl)
        }
    }

    private func categoryRow(_ category: SettingsCategory) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(selectedCategory == category ? .white : LadderColors.primary)
                    .frame(width: 24)

                Text(category.rawValue)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(selectedCategory == category ? .white : LadderColors.onSurface)

                Spacer()
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .background(
                selectedCategory == category
                    ? LadderColors.primary
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
            .padding(.horizontal, LadderSpacing.sm)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var categoryContent: some View {
        switch selectedCategory {
        case .profile: profileCategory
        case .account: accountCategory
        case .notifications: notificationsCategory
        case .privacy: privacyCategory
        case .legal: legalCategory
        }
    }

    private var profileCategory: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            Text("Profile")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            // Avatar row
            HStack(spacing: LadderSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer)
                        .frame(width: 100, height: 100)
                    Text("KP")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.primary)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("\(firstName) \(lastName)")
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.onSurface)
                    Button("Change Photo") {}
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.primary)
                }
                Spacer()
            }

            settingsSection("PERSONAL INFORMATION") {
                HStack(spacing: LadderSpacing.md) {
                    LadderTextField("First Name", text: $firstName, icon: "person")
                    LadderTextField("Last Name", text: $lastName, icon: "person")
                }
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

            settingsSection("ACADEMIC PROFILE") {
                HStack(spacing: LadderSpacing.md) {
                    LadderTextField("GPA", text: $gpa, icon: "chart.bar")
                    LadderTextField("SAT Score", text: $satScore, icon: "pencil.line")
                }
                HStack(spacing: LadderSpacing.md) {
                    LadderTextField("ACT Score (optional)", text: $actScore, icon: "pencil.line")
                    LadderTextField("Career Path", text: $careerPath, icon: "sparkle.magnifyingglass")
                }
            }

            LadderPrimaryButton("Save Changes") { dismiss() }

            versionRow
        }
    }

    private var accountCategory: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            Text("Account")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            settingsSection("ACCOUNT") {
                infoRow("Email", value: "student@ladder.app")
                infoRow("Password", value: "••••••••")
                infoRow("Linked Accounts", value: "Apple")
            }
        }
    }

    private var notificationsCategory: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Notifications")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Manage how and when Ladder notifies you.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            NotificationSettingsView()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var privacyCategory: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            Text("Privacy")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            settingsSection("DATA") {
                infoRow("Analytics", value: "Enabled")
                infoRow("Personalized Recommendations", value: "Enabled")
                infoRow("Data Export", value: "Request")
            }
        }
    }

    private var legalCategory: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            Text("Legal")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            settingsSection("LEGAL") {
                infoRow("Terms of Service", value: "View")
                infoRow("Privacy Policy", value: "View")
                infoRow("Data Deletion", value: "Request")
                infoRow("Licenses", value: "View")
            }
        }
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
            Text(value)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(.vertical, LadderSpacing.sm)
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
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var deadlineReminders = true
    @State private var taskReminders = true
    @State private var dailyTip = true
    @State private var streakReminder = true
    @State private var newScholarships = false
    @State private var applicationUpdates = true
    @State private var selectedCategory: NotifCategory = .reminders

    @State private var pushEnabled = true
    @State private var emailEnabled = true
    @State private var quietHoursEnabled = false

    enum NotifCategory: String, CaseIterable, Identifiable {
        case reminders = "Reminders"
        case content = "Content"
        case delivery = "Delivery"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .reminders: return "alarm.fill"
            case .content: return "sparkles"
            case .delivery: return "paperplane.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .reminders: return "Deadlines, tasks, streaks"
            case .content: return "Tips, scholarships, updates"
            case .delivery: return "Push, email, quiet hours"
            }
        }
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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

    private var iPhoneLayout: some View {
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
    }

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: LadderSpacing.lg) {
            // Left: categories
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("CATEGORIES")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                    .padding(.horizontal, LadderSpacing.md)

                ForEach(NotifCategory.allCases) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: LadderSpacing.md) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(selectedCategory == cat ? .white : LadderColors.primary)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(cat.rawValue)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(selectedCategory == cat ? .white : LadderColors.onSurface)
                                Text(cat.subtitle)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(selectedCategory == cat ? .white.opacity(0.8) : LadderColors.onSurfaceVariant)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(LadderSpacing.md)
                        .background(
                            selectedCategory == cat
                                ? LadderColors.primary
                                : LadderColors.surfaceContainerLow
                        )
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity * 0.4, alignment: .leading)
            .frame(minWidth: 240, maxWidth: 340)

            // Right: controls
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    switch selectedCategory {
                    case .reminders:
                        settingsSection("REMINDERS") {
                            notificationToggle("Deadline Reminders", subtitle: "Get notified before application deadlines", isOn: $deadlineReminders)
                            notificationToggle("Task Reminders", subtitle: "Daily reminder to complete your tasks", isOn: $taskReminders)
                            notificationToggle("Streak Reminder", subtitle: "Don't break your streak!", isOn: $streakReminder)
                        }
                    case .content:
                        settingsSection("CONTENT") {
                            notificationToggle("Daily Tip", subtitle: "Receive a daily college prep tip", isOn: $dailyTip)
                            notificationToggle("New Scholarships", subtitle: "Get notified about matching scholarships", isOn: $newScholarships)
                            notificationToggle("Application Updates", subtitle: "Status changes and decision notifications", isOn: $applicationUpdates)
                        }
                    case .delivery:
                        settingsSection("DELIVERY PREFERENCES") {
                            notificationToggle("Push Notifications", subtitle: "Send alerts to this device", isOn: $pushEnabled)
                            notificationToggle("Email Notifications", subtitle: "Weekly digest to your inbox", isOn: $emailEnabled)
                            notificationToggle("Quiet Hours", subtitle: "Pause notifications 10pm - 7am", isOn: $quietHoursEnabled)
                        }
                    }
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(.bottom, LadderSpacing.xxl)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(LadderSpacing.lg)
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
