import SwiftUI

// MARK: - Tasks Tab — Activities System (4 General + 6 Career-Specific)
// The 4 general activities every student needs + 6 specific to their career path
// Activity impact ratings 1–10 show college application value

struct TasksView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var selectedSegment = 0          // 0=Activities, 1=Checklist
    @State private var careerBucket = "STEM"        // Would come from StudentProfile
    @State private var showAddActivity = false
    @State private var activities: [ActivityEntry] = ActivityEntry.sampleData
    @State private var checklistItems: [AppChecklistEntry] = AppChecklistEntry.sampleItems

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    segmentPicker
                    if selectedSegment == 0 {
                        activitiesSection
                    } else {
                        checklistSection
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddActivity) {
            AddActivitySheet(activities: $activities)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [LadderColors.primary, LadderColors.primaryContainer],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 200)

            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("ACTIVITIES & TASKS").font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed).labelTracking()
                Text("Your Portfolio").font(LadderTypography.headlineLarge).foregroundStyle(.white)

                HStack(spacing: LadderSpacing.lg) {
                    statPill("\(generalCompleted)/4", "General", "checkmark.circle")
                    statPill("\(careerCompleted)/6", "Career", "star")
                    statPill("\(volunteerHours)", "Vol. Hrs", "heart.circle")
                }
            }
            .padding(.horizontal, LadderSpacing.md).padding(.bottom, LadderSpacing.xl)
        }
    }

    private func statPill(_ value: String, _ label: String, _ icon: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 11)).foregroundStyle(LadderColors.accentLime)
                Text(value).font(LadderTypography.titleSmall).foregroundStyle(.white)
            }
            Text(label).font(LadderTypography.labelSmall).foregroundStyle(.white.opacity(0.7))
        }
    }

    private var segmentPicker: some View {
        HStack(spacing: 0) {
            ForEach(["Activities", "App Checklist"], id: \.self) { tab in
                let idx = tab == "Activities" ? 0 : 1
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedSegment = idx }
                } label: {
                    VStack(spacing: LadderSpacing.xs) {
                        Text(tab).font(LadderTypography.titleSmall)
                            .foregroundStyle(selectedSegment == idx ? LadderColors.onSurface : LadderColors.onSurfaceVariant)
                        Rectangle().fill(selectedSegment == idx ? LadderColors.accentLime : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, LadderSpacing.md)
        .background(LadderColors.surface)
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Big 4 General
            sectionHeader("The Big 4 — Required for All Students", subtitle: "Every competitive college wants to see these", icon: "4.circle.fill")
            VStack(spacing: LadderSpacing.sm) {
                ForEach(GeneralActivity.all) { activity in
                    let entry = activities.first(where: { $0.category == activity.id })
                    generalActivityCard(activity: activity, entry: entry)
                }
            }
            .padding(.horizontal, LadderSpacing.md)

            // 6 Career-Specific
            sectionHeader("Career Boosters — \(careerBucket) Track", subtitle: "High-impact activities for your field", icon: "star.fill")
            VStack(spacing: LadderSpacing.sm) {
                ForEach(careerActivities) { activity in
                    let entry = activities.first(where: { $0.category == activity.id })
                    careerActivityCard(activity: activity, entry: entry)
                }
            }
            .padding(.horizontal, LadderSpacing.md)

            // Add button
            Button {
                showAddActivity = true
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "plus.circle.fill").foregroundStyle(LadderColors.primary)
                    Text("Log an Activity").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(LadderSpacing.md)
                .background(LadderColors.primaryContainer.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(LadderColors.primary.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, LadderSpacing.md)
        }
        .padding(.top, LadderSpacing.md)
    }

    private func sectionHeader(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(LadderColors.accentLime)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                Text(subtitle).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    private func generalActivityCard(activity: GeneralActivity, entry: ActivityEntry?) -> some View {
        LadderCard {
            VStack(spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        Circle().fill(entry != nil ? LadderColors.accentLime.opacity(0.2) : LadderColors.surfaceContainerHigh)
                            .frame(width: 44, height: 44)
                        Image(systemName: activity.icon).font(.system(size: 20))
                            .foregroundStyle(entry != nil ? LadderColors.accentLime : LadderColors.onSurfaceVariant)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.name).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                        Text(activity.description).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                    impactBadge(activity.impact)
                }

                if activity.id == "volunteering" {
                    VStack(spacing: 4) {
                        HStack {
                            Text("Volunteer Hours").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                            Spacer()
                            Text("\(volunteerHours) / 120 hrs").font(LadderTypography.labelSmall)
                                .foregroundStyle(volunteerHours >= 120 ? LadderColors.accentLime : LadderColors.onSurfaceVariant)
                        }
                        LinearProgressBar(progress: min(Double(volunteerHours) / 120.0, 1.0))
                        if volunteerHours < 120 {
                            Text("⚡ \(120 - volunteerHours) more hours for Bright Futures eligibility")
                                .font(LadderTypography.labelSmall).foregroundStyle(LadderColors.accentLime)
                        }
                    }
                }

                if let entry = entry {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(LadderColors.accentLime).font(.system(size: 13))
                        Text(entry.description).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                        Spacer()
                    }
                } else {
                    HStack {
                        Image(systemName: "plus.circle").foregroundStyle(LadderColors.primary).font(.system(size: 13))
                        Text("Tap to log this activity").font(LadderTypography.bodySmall).foregroundStyle(LadderColors.primary)
                        Spacer()
                    }
                }
            }
        }
    }

    private func careerActivityCard(activity: CareerActivity, entry: ActivityEntry?) -> some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle().fill(entry != nil ? LadderColors.accentLime.opacity(0.2) : LadderColors.surfaceContainerHigh)
                        .frame(width: 44, height: 44)
                    Image(systemName: activity.icon).font(.system(size: 20))
                        .foregroundStyle(entry != nil ? LadderColors.accentLime : LadderColors.onSurfaceVariant)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.name).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                    Text(activity.tip).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Spacer()
                impactBadge(activity.impact)
            }
        }
    }

    private func impactBadge(_ score: Int) -> some View {
        VStack(spacing: 1) {
            Text("\(score)").font(.system(size: 13, weight: .bold))
                .foregroundStyle(score >= 9 ? LadderColors.accentLime : score >= 7 ? LadderColors.primary : LadderColors.onSurfaceVariant)
            Text("/10").font(.system(size: 9)).foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(width: 32)
    }

    // MARK: - App Checklist

    private var checklistSection: some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach($checklistItems) { $item in
                checklistRow(item: $item)
            }
        }
        .padding(.horizontal, LadderSpacing.md).padding(.top, LadderSpacing.md)
    }

    private func checklistRow(item: Binding<AppChecklistEntry>) -> some View {
        Button {
            withAnimation { item.wrappedValue.isComplete.toggle() }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: item.wrappedValue.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.wrappedValue.isComplete ? LadderColors.accentLime : LadderColors.outlineVariant)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.wrappedValue.title).font(LadderTypography.bodyMedium)
                        .foregroundStyle(item.wrappedValue.isComplete ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                        .strikethrough(item.wrappedValue.isComplete)
                    if let grade = item.wrappedValue.gradeLabel {
                        Text(grade).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.accentLime)
                    }
                }
                Spacer()
                if let dueDate = item.wrappedValue.dueDate {
                    Text(dueDate).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Computed

    private var generalCompleted: Int { activities.filter { GeneralActivity.all.map(\.id).contains($0.category) }.count }
    private var careerCompleted: Int { activities.filter { careerActivities.map(\.id).contains($0.category) }.count }
    private var volunteerHours: Int { activities.filter { $0.category == "volunteering" }.reduce(0) { $0 + $1.hours } }

    private var careerActivities: [CareerActivity] {
        switch careerBucket {
        case "Medical": return CareerActivity.medical
        case "Business": return CareerActivity.business
        case "Humanities": return CareerActivity.humanities
        case "Sports": return CareerActivity.sports
        default: return CareerActivity.stem
        }
    }
}

// MARK: - Add Activity Sheet

struct AddActivitySheet: View {
    @Binding var activities: [ActivityEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var category = "volunteering"
    @State private var hours = 0
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Details") {
                    TextField("Title (e.g. NHS Volunteering)", text: $title)
                    Picker("Category", selection: $category) {
                        Text("Volunteering").tag("volunteering")
                        Text("Athletics").tag("athletics")
                        Text("Clubs").tag("clubs")
                        Text("Job / Internship").tag("job")
                        Text("Research Paper").tag("research")
                        Text("Award / Competition").tag("award")
                        Text("Other").tag("other")
                    }
                    if category == "volunteering" {
                        Stepper("Hours: \(hours)", value: $hours, in: 0...500)
                    }
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard !title.isEmpty else { return }
                        activities.append(ActivityEntry(title: title, category: category, hours: hours, description: description.isEmpty ? title : description))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Data Models

struct ActivityEntry: Identifiable {
    let id = UUID()
    var title: String
    var category: String
    var hours: Int
    var description: String
    var isCompleted: Bool = true

    static let sampleData: [ActivityEntry] = [
        ActivityEntry(title: "NHS Volunteering", category: "volunteering", hours: 45, description: "45 hrs at Halifax Medical Center"),
        ActivityEntry(title: "Robotics Club", category: "clubs", hours: 0, description: "Member since 9th grade, VP in 11th"),
    ]
}

struct AppChecklistEntry: Identifiable {
    let id = UUID()
    var title: String
    var gradeLabel: String?
    var dueDate: String?
    var isComplete: Bool = false

    static let sampleItems: [AppChecklistEntry] = [
        AppChecklistEntry(title: "Complete Career Quiz", gradeLabel: "9th Grade — Start Here"),
        AppChecklistEntry(title: "Upload freshman transcript", gradeLabel: "9th Grade"),
        AppChecklistEntry(title: "Join at least 1 club", gradeLabel: "9th Grade"),
        AppChecklistEntry(title: "Start volunteering (goal: 120 hrs)", gradeLabel: "9th–10th Grade"),
        AppChecklistEntry(title: "Register for PSAT", gradeLabel: "10th Grade", dueDate: "Oct"),
        AppChecklistEntry(title: "Begin SAT prep", gradeLabel: "10th Summer"),
        AppChecklistEntry(title: "Register for SAT", gradeLabel: "11th Grade", dueDate: "Sep"),
        AppChecklistEntry(title: "Create college wishlist (5+ schools)", gradeLabel: "11th Grade"),
        AppChecklistEntry(title: "Request letters of recommendation", gradeLabel: "11th Grade"),
        AppChecklistEntry(title: "Create Common App account", gradeLabel: "12th Grade"),
        AppChecklistEntry(title: "Submit Early Action applications", gradeLabel: "12th Grade", dueDate: "Nov 1"),
        AppChecklistEntry(title: "Submit Regular Decision applications", gradeLabel: "12th Grade", dueDate: "Jan 1"),
        AppChecklistEntry(title: "Compare financial aid packages", gradeLabel: "12th Grade", dueDate: "Apr"),
        AppChecklistEntry(title: "Commit to a school (National Decision Day)", gradeLabel: "12th Grade", dueDate: "May 1"),
    ]
}

// MARK: - Activity Definitions

struct GeneralActivity: Identifiable {
    let id: String; let name: String; let description: String; let icon: String; let impact: Int

    static let all: [GeneralActivity] = [
        GeneralActivity(id: "volunteering", name: "Community Service", description: "Min 120 hrs for Bright Futures • 75 hrs Medallion", icon: "heart.circle", impact: 8),
        GeneralActivity(id: "clubs", name: "School Clubs", description: "1+ per year with at least one leadership role", icon: "person.3", impact: 7),
        GeneralActivity(id: "athletics", name: "Athletics", description: "School sport, club sport, or physical activity", icon: "figure.run", impact: 7),
        GeneralActivity(id: "job", name: "Job / Work Experience", description: "Shows responsibility, time management, and initiative", icon: "briefcase", impact: 6),
    ]
}

struct CareerActivity: Identifiable {
    let id: String; let name: String; let tip: String; let icon: String; let impact: Int

    static let stem: [CareerActivity] = [
        CareerActivity(id: "research", name: "Research Paper / STEM Project", tip: "Submit to Regeneron or Google Science Fair", icon: "doc.text", impact: 8),
        CareerActivity(id: "internship", name: "Tech Internship or Job Shadow", tip: "Look for paid internships via LinkedIn or Indeed", icon: "laptopcomputer", impact: 9),
        CareerActivity(id: "award", name: "Competition / Award (Tech)", tip: "Hackathons, Math Olympiad, AMC competitions", icon: "trophy", impact: 10),
        CareerActivity(id: "project", name: "Personal Project (App / Website)", tip: "GitHub repo shows real-world skills to admissions", icon: "cpu", impact: 9),
        CareerActivity(id: "interview", name: "Informational Interview", tip: "Interview a software engineer or researcher in your field", icon: "mic", impact: 7),
        CareerActivity(id: "dualenroll", name: "Dual Enrollment (STEM)", tip: "Take college-level math or CS at community college", icon: "graduationcap", impact: 8),
    ]

    static let medical: [CareerActivity] = [
        CareerActivity(id: "clinical", name: "Clinical Volunteering", tip: "Hospital, free clinic, or nursing home — 100+ hrs", icon: "cross.case", impact: 10),
        CareerActivity(id: "research", name: "Health Research Paper", tip: "Biology experiment or medical case study", icon: "doc.text", impact: 8),
        CareerActivity(id: "award", name: "Science Fair / Competition", tip: "ISEF, regional science fair, or biology olympiad", icon: "trophy", impact: 9),
        CareerActivity(id: "cert", name: "CNA / CPR / First Aid Cert", tip: "Shows commitment to the medical path", icon: "staroflife", impact: 7),
        CareerActivity(id: "internship", name: "Healthcare Job Shadow", tip: "Shadow a doctor, PA, or NP for 20+ hours", icon: "stethoscope", impact: 8),
        CareerActivity(id: "interview", name: "Interview a Healthcare Professional", tip: "Ask them about their path and what they wish they knew", icon: "mic", impact: 6),
    ]

    static let business: [CareerActivity] = [
        CareerActivity(id: "entrepreneurship", name: "Start Something (Business/Club)", tip: "Even an Etsy shop or tutoring service counts", icon: "storefront", impact: 10),
        CareerActivity(id: "deca", name: "DECA or FBLA Competition", tip: "Regional, state, or national placement is impressive", icon: "trophy", impact: 9),
        CareerActivity(id: "internship", name: "Business Internship or Job", tip: "Finance, marketing, real estate, any industry", icon: "briefcase", impact: 9),
        CareerActivity(id: "research", name: "Business Research / Essay", tip: "Case study on a company or market analysis", icon: "doc.text", impact: 7),
        CareerActivity(id: "leadership", name: "Leadership Role in Any Club", tip: "President, treasurer, or officer of any organization", icon: "person.badge.shield.checkmark", impact: 8),
        CareerActivity(id: "interview", name: "Interview a Business Professional", tip: "Ask an entrepreneur or executive about their journey", icon: "mic", impact: 6),
    ]

    static let humanities: [CareerActivity] = [
        CareerActivity(id: "publish", name: "Published Writing or Blog", tip: "School paper, local newspaper, or online publication", icon: "newspaper", impact: 9),
        CareerActivity(id: "competition", name: "Writing or Speech Competition", tip: "Debate, essay contests, speech & drama", icon: "trophy", impact: 8),
        CareerActivity(id: "creative", name: "Theater, Film, or Art Exhibition", tip: "Lead role, short film, or juried art show", icon: "theatermasks", impact: 8),
        CareerActivity(id: "internship", name: "Journalism or Teaching Internship", tip: "Newsroom, tutoring center, or museum education", icon: "pencil.and.outline", impact: 8),
        CareerActivity(id: "research", name: "Research Paper (Social Sciences)", tip: "Sociology, political analysis, or opinion research", icon: "doc.text", impact: 7),
        CareerActivity(id: "interview", name: "Interview a Humanities Professional", tip: "Author, journalist, lawyer, or educator", icon: "mic", impact: 6),
    ]

    static let sports: [CareerActivity] = [
        CareerActivity(id: "varsity", name: "Varsity Sport", tip: "Playing varsity shows elite dedication and commitment", icon: "figure.run", impact: 10),
        CareerActivity(id: "coach", name: "Coach / Referee / Team Manager", tip: "Shows leadership even if not playing competitively", icon: "whistle", impact: 7),
        CareerActivity(id: "recruitvideo", name: "Athletic Recruiting Video", tip: "Highlights + GPA on tape sent to college coaches", icon: "video", impact: 9),
        CareerActivity(id: "cert", name: "Sports / Fitness Certification", tip: "CPR, personal trainer cert, or athletic training cert", icon: "staroflife", impact: 6),
        CareerActivity(id: "research", name: "Sports / Kinesiology Research", tip: "Biomechanics experiment or sports nutrition paper", icon: "doc.text", impact: 7),
        CareerActivity(id: "camp", name: "Sports Camp Counselor", tip: "Coach or lead younger athletes at a summer camp", icon: "person.3", impact: 7),
    ]
}

#Preview {
    NavigationStack {
        TasksView()
            .environment(AppCoordinator())
    }
}
