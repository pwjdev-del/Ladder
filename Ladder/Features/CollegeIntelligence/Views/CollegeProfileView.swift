import SwiftUI
import SwiftData

// MARK: - College Profile Detail View (Data-Driven)

struct CollegeProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let collegeId: String
    @State private var isFavorite = false
    @State private var selectedSection = 0
    @State private var college: CollegeModel?
    @State private var calendarManager = CalendarManager.shared
    @State private var calendarAlert: CalendarAlertType?
    @State private var showMoreActions = false
    @State private var showDeadlineTypePicker = false
    @State private var showApplicationCreatedAlert = false
    @Query var studentProfiles: [StudentProfileModel]
    private var studentProfile: StudentProfileModel? { studentProfiles.first }

    private enum CalendarAlertType: Identifiable {
        case added(String)
        case alreadyExists(String)
        case noAccess

        var id: String {
            switch self {
            case .added(let t): return "added-\(t)"
            case .alreadyExists(let t): return "exists-\(t)"
            case .noAccess: return "noaccess"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            if let college {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection(college)
                        quickStats(college)
                        sectionPicker
                        sectionContent(college)
                    }
                    .padding(.bottom, 120)
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(LadderColors.primary)
                    Text("Loading college...")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .padding(.top, LadderSpacing.md)
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Wire 2: Save/unsave college + fire ConnectionEngine
                    if let profile = studentProfile, let college = college {
                        let id = college.scorecardId.map { String($0) } ?? college.name
                        if profile.savedCollegeIds.contains(id) {
                            profile.savedCollegeIds.removeAll { $0 == id }
                            ConnectionEngine.shared.onCollegeRemoved(collegeId: id, context: context)
                            isFavorite = false
                        } else {
                            profile.savedCollegeIds.append(id)
                            ConnectionEngine.shared.onCollegeSaved(collegeId: id, collegeName: college.name, context: context)
                            isFavorite = true
                        }
                        try? context.save()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? LadderColors.error : .white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .alert(item: $calendarAlert) { alertType in
            switch alertType {
            case .added(let title):
                Alert(title: Text("Added to Calendar"), message: Text("\(title) has been added to your calendar with reminders."), dismissButton: .default(Text("OK")))
            case .alreadyExists(let title):
                Alert(title: Text("Already Added"), message: Text("\(title) is already on your calendar."), dismissButton: .default(Text("OK")))
            case .noAccess:
                Alert(title: Text("Calendar Access"), message: Text("Please enable calendar access in Settings to add deadlines."), dismissButton: .default(Text("OK")))
            }
        }
        .task {
            loadCollege()
            // Set initial favorite state from saved colleges
            if let profile = studentProfile {
                isFavorite = profile.savedCollegeIds.contains(collegeId)
            }
        }
    }

    private func loadCollege() {
        let descriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(descriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId || $0.name == collegeId }
        }
    }

    // MARK: - Hero with deterministic gradient + school initials

    private func heroSection(_ c: CollegeModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Deterministic gradient from school name
            let colors = gradientColors(for: c.name)
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 240)
                .overlay(
                    // School initials as large background text
                    Text(initials(c.name))
                        .font(.system(size: 120, weight: .bold))
                        .foregroundStyle(.white.opacity(0.1))
                )

            // Name overlay
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                // Type badge
                HStack(spacing: LadderSpacing.xs) {
                    if let type = c.institutionType {
                        Text(type.uppercased())
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white)
                            .labelTracking()
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    if c.isHBCU {
                        Text("HBCU")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.secondaryFixed)
                            .labelTracking()
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(LadderColors.secondaryFixed.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: LadderSpacing.md) {
                    // College logo
                    CollegeLogoView(c.name, websiteURL: c.websiteURL, size: 64, cornerRadius: 16)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(c.name)
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(.white)

                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "mappin.circle.fill").font(.system(size: 14))
                            Text([c.city, c.state].compactMap { $0 }.joined(separator: ", "))
                                .font(LadderTypography.bodyMedium)
                        }
                        .foregroundStyle(.white.opacity(0.8))

                        if let url = c.websiteURL {
                            Text(url.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: ""))
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            )
        }
    }

    // MARK: - Quick Stats

    private func quickStats(_ c: CollegeModel) -> some View {
        HStack(spacing: 0) {
            statItem(value: c.acceptanceRate.map { "\(Int($0 * 100))%" } ?? "N/A", label: "Acceptance", icon: "chart.pie.fill")
            statItem(value: c.inStateTuition.map { "$\(formatNum($0))" } ?? "N/A", label: "In-State", icon: "dollarsign.circle.fill")
            statItem(value: satRangeString(c), label: "SAT Range", icon: "pencil.line")
            statItem(value: c.enrollment.map { formatNum($0) } ?? "N/A", label: "Students", icon: "person.3.fill")
        }
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(LadderColors.primary)
            Text(value).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface).lineLimit(1).minimumScaleFactor(0.7)
            Text(label).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        let sections = ["Overview", "Admissions", "Enrollment", "Actions"]
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, title in
                    Button {
                        withAnimation { selectedSection = index }
                    } label: {
                        Text(title)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(selectedSection == index ? .white : LadderColors.onSurfaceVariant)
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.sm)
                            .background(selectedSection == index ? LadderColors.primary : LadderColors.surfaceContainerHigh)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
        }
    }

    // MARK: - Section Content

    @ViewBuilder
    private func sectionContent(_ c: CollegeModel) -> some View {
        switch selectedSection {
        case 0: overviewSection(c)
        case 1: admissionsSection(c)
        case 2: enrollmentSection(c)
        case 3: actionsSection(c)
        default: EmptyView()
        }
    }

    // MARK: - Overview

    private func overviewSection(_ c: CollegeModel) -> some View {
        VStack(spacing: LadderSpacing.md) {
            // About
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("About").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                    Text("\(c.name) is a \(c.institutionType?.lowercased() ?? "") institution located in \([c.city, c.state].compactMap{$0}.joined(separator: ", ")). \(c.enrollment.map { "With \(formatNum($0)) students, it" } ?? "It") offers a \(c.sizeCategory?.lowercased() ?? "")-sized campus experience.")
                        .font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            // Key facts
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Key Facts").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)

                    if let rate = c.completionRate { factRow("Graduation Rate", "\(Int(rate * 100))%") }
                    if let earnings = c.medianEarnings { factRow("Median Earnings (10yr)", "$\(formatNum(earnings))") }
                    if let pell = c.pellRate { factRow("Pell Grant Recipients", "\(Int(pell * 100))%") }
                    if let debt = c.medianDebt { factRow("Median Student Debt", "$\(formatNum(debt))") }
                    if let netPrice = c.avgNetPrice { factRow("Average Net Price", "$\(formatNum(netPrice))") }
                    if let oos = c.outStateTuition { factRow("Out-of-State Tuition", "$\(formatNum(oos))") }
                    if let rb = c.roomAndBoard { factRow("Room & Board", "$\(formatNum(rb))") }
                    if let acc = c.accreditor { factRow("Accreditor", acc) }
                }
            }

            // Tags
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Tags").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                    FlowLayout(spacing: LadderSpacing.sm) {
                        if let type = c.institutionType { LadderTagChip(type) }
                        if let size = c.sizeCategory { LadderTagChip(size) }
                        if c.isHBCU { LadderTagChip("HBCU") }
                        if c.isOpenAdmissions { LadderTagChip("Open Admission") }
                        if let tp = c.testingPolicy { LadderTagChip(tp) }
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Admissions (real data from Perplexity)

    private func admissionsSection(_ c: CollegeModel) -> some View {
        VStack(spacing: LadderSpacing.md) {
            // Testing Policy
            if let tp = c.testingPolicy {
                LadderCard {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(LadderColors.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Testing Policy").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                            Text(tp).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                    }
                }
            }

            // Application Fee
            if let fee = c.applicationFee {
                LadderCard {
                    infoRow("Application Fee", fee, "dollarsign.circle")
                }
            }

            // Essays & Recommendations
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Requirements").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                    if let essays = c.supplementalEssaysCount { infoRow("Supplemental Essays", essays, "doc.text") }
                    if let recs = c.recommendationLetters { infoRow("Recommendation Letters", recs, "envelope.badge.person.crop") }
                    if let interview = c.interviewPolicy { infoRow("Interview", interview, "person.wave.2") }
                    if let interest = c.demonstratedInterest { infoRow("Demonstrated Interest", interest, "eye") }
                    if let css = c.cssProfileRequired { infoRow("CSS Profile", css, "building.columns") }
                    if let transcript = c.transcriptMethod { infoRow("Transcript Method", transcript, "doc") }
                }
            }

            // Deadlines
            if !c.deadlines.isEmpty {
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Deadlines").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                        ForEach(c.deadlines, id: \.deadlineType) { dl in
                            HStack {
                                Circle().fill(deadlineColor(dl.deadlineType)).frame(width: 8, height: 8)
                                Text(dl.deadlineType).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurface)
                                Spacer()
                                if let date = dl.date {
                                    Button {
                                        addDeadlineToCalendar(
                                            title: "\(c.name) - \(dl.deadlineType)",
                                            date: date,
                                            notes: "Deadline for \(c.name). Source: \(dl.source ?? "Ladder")"
                                        )
                                    } label: {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 14))
                                            .foregroundStyle(LadderColors.primary)
                                    }
                                }
                                Text(dl.source ?? "").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    }
                }
            }

            // Deposit deadline calendar button
            if let depositDeadline = c.depositDeadline {
                LadderCard {
                    HStack {
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text("Deposit Deadline").font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                            Text(depositDeadline).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurface)
                        }
                        Spacer()
                        Button {
                            addDeadlineStringToCalendar(
                                title: "\(c.name) - Enrollment Deposit Due",
                                dateString: depositDeadline,
                                notes: "Enrollment deposit deadline for \(c.name). Amount: \(c.enrollmentDeposit ?? "Check school website")"
                            )
                        } label: {
                            HStack(spacing: LadderSpacing.xs) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 12))
                                Text("Add")
                                    .font(LadderTypography.labelSmall)
                            }
                            .foregroundStyle(LadderColors.primary)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(Capsule())
                        }
                    }
                }
            }

            // Merit Scholarship
            if let merit = c.topMeritScholarship {
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        HStack {
                            Image(systemName: "star.fill").foregroundStyle(LadderColors.secondaryFixed)
                            Text("Top Merit Scholarship").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                        }
                        Text(merit).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurfaceVariant)
                        if let amount = c.meritScholarshipAmount {
                            Text(amount).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.primary)
                        }
                        if let criteria = c.meritCriteria {
                            Text(criteria).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Enrollment (Florida-deep data)

    private func enrollmentSection(_ c: CollegeModel) -> some View {
        VStack(spacing: LadderSpacing.md) {
            let hasEnrollmentData = c.enrollmentDeposit != nil || c.orientationRequired != nil || c.immunizationsRequired != nil || c.placementTests != nil

            if hasEnrollmentData {
                if let deposit = c.enrollmentDeposit {
                    LadderCard { infoRow("Enrollment Deposit", deposit, "dollarsign.circle") }
                }
                if let deadline = c.depositDeadline {
                    LadderCard { infoRow("Deposit Deadline", deadline, "calendar") }
                }
                if let housing = c.housingDeposit {
                    LadderCard { infoRow("Housing Deposit", housing, "house") }
                }
                if let hDeadline = c.housingDeadline {
                    LadderCard { infoRow("Housing Deadline", hDeadline, "calendar.badge.clock") }
                }
                if let orientation = c.orientationRequired {
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            infoRow("Orientation", orientation, "person.3")
                            if let cost = c.orientationCost { infoRow("Orientation Cost", cost, "dollarsign.circle") }
                        }
                    }
                }
                if let immunizations = c.immunizationsRequired {
                    LadderCard { infoRow("Immunizations Required", immunizations, "cross.case") }
                }
                if let placement = c.placementTests {
                    LadderCard { infoRow("Placement Tests", placement, "doc.text") }
                }

                // Enrollment checklist button
                LadderPrimaryButton("View Full Enrollment Checklist", icon: "checklist") {
                    coordinator.navigate(to: .enrollmentChecklist(collegeId: collegeId))
                }
            } else {
                LadderCard {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "info.circle").font(.title2).foregroundStyle(LadderColors.primary)
                        Text("Enrollment process data is available for Florida schools. For other schools, check the admissions office website.")
                            .font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurfaceVariant).multilineTextAlignment(.center)
                        if let url = c.websiteURL {
                            Text(url).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Actions

    private func applyNowLabel(_ c: CollegeModel) -> String {
        if let portal = c.portalURL, portal.lowercased().contains("commonapp") {
            return "Via Common App"
        } else if c.portalURL != nil {
            return "Via Direct Portal"
        } else if let web = c.websiteURL, web.lowercased().contains("commonapp") {
            return "Via Common App"
        } else {
            return "Visit Website"
        }
    }

    private var applyNowURL: URL? {
        if let c = college {
            if let portal = c.portalURL, let url = URL(string: portal) {
                return url
            } else if let web = c.websiteURL, let url = URL(string: web) {
                return url
            }
        }
        return nil
    }

    private func actionsSection(_ c: CollegeModel) -> some View {
        VStack(spacing: LadderSpacing.md) {
            // Apply Now — most prominent action
            if let url = applyNowURL {
                Link(destination: url) {
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [LadderColors.primary, LadderColors.primaryContainer],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))

                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text("Apply Now")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(applyNowLabel(c))
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(LadderColors.primary)
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .overlay(
                        RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                            .stroke(LadderColors.primary.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }

            }

            // 3 Primary Actions — prominent cards
            primaryActionCard(
                title: "View Match Score",
                icon: "percent",
                description: "See how you match this school's requirements",
                accentColor: LadderColors.primary
            ) {
                coordinator.navigate(to: .gapAnalysis(collegeId: collegeId))
            }

            primaryActionCard(
                title: "Start Application",
                icon: "doc.badge.plus",
                description: "Track your application to \(c.name)",
                accentColor: LadderColors.secondaryFixed
            ) {
                showDeadlineTypePicker = true
            }

            primaryActionCard(
                title: "Compare Schools",
                icon: "arrow.left.arrow.right",
                description: "Side-by-side comparison with another college",
                accentColor: LadderColors.tertiary
            ) {
                coordinator.navigate(to: .collegeComparison(leftId: collegeId, rightId: ""))
            }

            // More Actions — collapsible
            VStack(spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showMoreActions.toggle()
                    }
                } label: {
                    HStack {
                        Text("More Actions")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        Image(systemName: showMoreActions ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
                .buttonStyle(.plain)

                if showMoreActions {
                    VStack(spacing: LadderSpacing.sm) {
                        actionButton("AP Credit Policy", icon: "checkmark.seal", description: "See what AP scores earn credit at \(c.name)") {
                            coordinator.navigate(to: .apCredits(collegeId: collegeId))
                        }
                        actionButton("View Personality Profile", icon: "sparkles", description: "AI-generated archetype and admissions philosophy") {
                            coordinator.navigate(to: .collegePersonality(collegeId: collegeId))
                        }
                        actionButton("Mock Interview", icon: "person.wave.2", description: "Practice interview questions for this school") {
                            coordinator.navigate(to: .mockInterviewFull(collegeId: collegeId))
                        }
                        actionButton("Generate LOCI", icon: "envelope", description: "Draft a Letter of Continued Interest") {
                            coordinator.navigate(to: .lociGenerator(collegeId: collegeId))
                        }
                        if c.state == "FL" {
                            actionButton("Enrollment Checklist", icon: "checklist", description: "Deposits, housing, orientation, immunizations") {
                                coordinator.navigate(to: .enrollmentChecklist(collegeId: collegeId))
                            }
                        }
                    }
                    .padding(.top, LadderSpacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
        .confirmationDialog("Choose Deadline Type", isPresented: $showDeadlineTypePicker, titleVisibility: .visible) {
            Button("Early Decision (ED)") { createApplication(c, deadlineType: "Early Decision") }
            Button("Early Action (EA)") { createApplication(c, deadlineType: "Early Action") }
            Button("Regular Decision (RD)") { createApplication(c, deadlineType: "Regular Decision") }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Application Created", isPresented: $showApplicationCreatedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your application to \(c.name) has been added to your tracker.")
        }
    }

    private func createApplication(_ c: CollegeModel, deadlineType: String) {
        let app = ApplicationModel(collegeName: c.name)
        app.collegeId = collegeId
        app.deadlineType = deadlineType
        // Find matching deadline date from college data
        if let dl = c.deadlines.first(where: { $0.deadlineType == deadlineType }) {
            app.deadlineDate = dl.date
        }
        context.insert(app)
        try? context.save()
        showApplicationCreatedAlert = true
    }

    private func primaryActionCard(title: String, icon: String, description: String, accentColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(title)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func actionButton(_ title: String, icon: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon).font(.system(size: 20)).foregroundStyle(LadderColors.primary)
                    .frame(width: 44, height: 44).background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(title).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                    Text(description).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.md).background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon).foregroundStyle(LadderColors.primary).frame(width: 24)
            Text(label).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(value).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurface).multilineTextAlignment(.trailing).frame(maxWidth: 200, alignment: .trailing)
        }
    }

    private func factRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(value).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurface)
        }
    }

    private func deadlineColor(_ type: String) -> Color {
        switch type {
        case "Early Decision": return .red
        case "Early Action": return .orange
        case "Regular Decision": return LadderColors.primary
        default: return LadderColors.primaryContainer
        }
    }

    private func satRangeString(_ c: CollegeModel) -> String {
        if let r25 = c.satReading25, let r75 = c.satReading75, let m25 = c.satMath25, let m75 = c.satMath75 {
            return "\(r25+m25)–\(r75+m75)"
        }
        if let avg = c.satAvg { return "\(avg)" }
        return "N/A"
    }

    private func formatNum(_ n: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    private func initials(_ name: String) -> String {
        let words = name.split(separator: " ").filter { !["of", "the", "and", "at", "in"].contains($0.lowercased()) }
        return words.prefix(2).map { String($0.prefix(1)) }.joined()
    }

    // MARK: - Calendar Integration

    private func addDeadlineToCalendar(title: String, date: Date, notes: String?) {
        Task {
            let success = await calendarManager.addDeadline(title: title, date: date, notes: notes)
            await MainActor.run {
                if success {
                    calendarAlert = .added(title)
                } else if calendarManager.authorizationStatus == .denied || calendarManager.authorizationStatus == .restricted {
                    calendarAlert = .noAccess
                } else {
                    calendarAlert = .alreadyExists(title)
                }
            }
        }
    }

    private func addDeadlineStringToCalendar(title: String, dateString: String, notes: String?) {
        // Try to parse common date formats from the Perplexity data
        if let date = parseDeadlineDate(dateString) {
            addDeadlineToCalendar(title: title, date: date, notes: notes)
        } else {
            // If we can't parse, use a reasonable default (May 1 for deposits)
            if let fallback = CalendarManager.dateFrom(month: 5, day: 1) {
                addDeadlineToCalendar(title: title, date: fallback, notes: "\(notes ?? "") (Date approximated from: \(dateString))")
            }
        }
    }

    private func parseDeadlineDate(_ text: String) -> Date? {
        let formatters: [DateFormatter] = {
            let formats = ["MMMM d", "MMMM d, yyyy", "MMM d", "MMM d, yyyy", "MM/dd/yyyy", "MM/dd"]
            return formats.map { format in
                let f = DateFormatter()
                f.dateFormat = format
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }
        }()

        // Extract the first date-like portion (before any parenthetical or "for" clause)
        let cleaned = text.components(separatedBy: "(").first?
            .components(separatedBy: " for ").first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? text

        for formatter in formatters {
            if let date = formatter.date(from: cleaned) {
                // Set year to current cycle
                var components = Calendar.current.dateComponents([.month, .day], from: date)
                components.year = Calendar.current.component(.year, from: Date())
                if let month = components.month, month < Calendar.current.component(.month, from: Date()) {
                    components.year = (components.year ?? 2026) + 1
                }
                return Calendar.current.date(from: components)
            }
        }
        return nil
    }

    private func gradientColors(for name: String) -> [Color] {
        let pairs: [(Color, Color)] = [
            (Color(red: 0.26, green: 0.37, blue: 0.25), Color(red: 0.35, green: 0.47, blue: 0.34)),
            (Color(red: 0.15, green: 0.30, blue: 0.45), Color(red: 0.20, green: 0.40, blue: 0.55)),
            (Color(red: 0.45, green: 0.25, blue: 0.12), Color(red: 0.55, green: 0.35, blue: 0.20)),
            (Color(red: 0.35, green: 0.15, blue: 0.35), Color(red: 0.45, green: 0.25, blue: 0.45)),
            (Color(red: 0.50, green: 0.15, blue: 0.15), Color(red: 0.60, green: 0.25, blue: 0.20)),
            (Color(red: 0.20, green: 0.35, blue: 0.35), Color(red: 0.30, green: 0.45, blue: 0.45)),
            (Color(red: 0.30, green: 0.30, blue: 0.15), Color(red: 0.40, green: 0.40, blue: 0.25)),
            (Color(red: 0.25, green: 0.25, blue: 0.40), Color(red: 0.35, green: 0.35, blue: 0.50)),
        ]
        let hash = abs(name.hashValue)
        let pair = pairs[hash % pairs.count]
        return [pair.0, pair.1]
    }
}
