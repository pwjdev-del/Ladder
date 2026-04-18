import SwiftUI
import SwiftData

// MARK: - Bright Futures Tracker (Florida Scholarship)
// Florida Bright Futures is the state scholarship program:
//   Academic Scholars:  3.5 GPA + 100 community service hours → 100% tuition (FL public)
//   Medallion Scholars: 3.0 GPA + 75 community service hours  → 75% tuition (FL public)
//   Gold Seal:          Vocational program for CTE students
//
// Eligibility determined at graduation — all progress counted from 9th grade on.

struct BrightFuturesTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var profiles: [StudentProfileModel]

    @State private var currentGPA: Double = 0
    @State private var weightedGPA: Double = 0
    @State private var serviceHours: Double = 0
    @State private var satScore: Int = 0
    @State private var actScore: Int = 0
    @State private var showAddHoursSheet = false
    @State private var newHoursText = ""
    @State private var serviceEntries: [ServiceEntry] = []
    @State private var loaded = false

    // Scholarship thresholds
    private let academicGPA  = 3.5;  private let academicHours  = 100.0; private let academicSAT  = 1290; private let academicACT  = 29
    private let medallionGPA = 3.0;  private let medallionHours = 75.0;  private let medallionSAT = 1170; private let medallionACT = 23

    private var isFloridaResident: Bool {
        guard let profile = profiles.first else { return false }
        return DomainValidator.normalizedState(profile.state) == "FL"
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if !isFloridaResident {
                notAvailableInState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        scholarshipStatusCard
                        serviceHoursCard
                        requirementsBreakdown
                        serviceLogSection
                        faqSection
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.top, LadderSpacing.md)
                    .padding(.bottom, 120)
                }
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
                Text("Bright Futures Tracker")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddHoursSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.accentLime)
                }
            }
        }
        .sheet(isPresented: $showAddHoursSheet) {
            addHoursSheet
        }
        .task {
            guard !loaded else { return }
            loaded = true
            let descriptor = FetchDescriptor<StudentProfileModel>()
            if let profiles = try? context.fetch(descriptor), let p = profiles.first {
                currentGPA = p.gpa ?? 0
                weightedGPA = (p.gpa ?? 0) + 0.3 // Approximate weighted boost
                satScore = p.satScore ?? 0
                actScore = p.actScore ?? 0
            }
        }
    }

    // MARK: - Scholarship Status Card

    private var scholarshipStatusCard: some View {
        let level = scholarshipLevel
        return LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BRIGHT FUTURES STATUS")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.accentLime)
                            .labelTracking()
                        Text(level.title)
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(level.subtitle)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(level.color.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: level.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(level.color)
                    }
                }

                HStack(spacing: 0) {
                    Rectangle().fill(LadderColors.outlineVariant.opacity(0.4)).frame(height: 1)
                }

                HStack(spacing: LadderSpacing.lg) {
                    scholarshipStat("Tuition", value: level.tuitionCoverage, color: level.color)
                    scholarshipStat("GPA", value: String(format: "%.2f", currentGPA), color: currentGPA >= academicGPA ? LadderColors.accentLime : LadderColors.primary)
                    scholarshipStat("Service", value: "\(Int(serviceHours)) hrs", color: serviceHours >= academicHours ? LadderColors.accentLime : LadderColors.primary)
                }
            }
        }
    }

    private func scholarshipStat(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: LadderSpacing.xxs) {
            Text(label).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
            Text(value).font(LadderTypography.titleSmall).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Service Hours Card

    private var serviceHoursCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack {
                    Text("Community Service Hours")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text("\(Int(serviceHours)) / \(Int(academicHours))")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                // Academic Scholars bar (100 hrs)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Academic Scholars (100 hrs)")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Spacer()
                        Text("\(Int(academicHours - serviceHours > 0 ? academicHours - serviceHours : 0)) hrs to go")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(serviceHours >= academicHours ? LadderColors.accentLime : LadderColors.onSurfaceVariant)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(LadderColors.surfaceContainerHigh)
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(serviceHours >= academicHours ? LadderColors.accentLime : LadderColors.primary)
                                .frame(width: geo.size.width * min(serviceHours / academicHours, 1.0), height: 8)
                            // Medallion threshold marker at 75 hrs
                            Rectangle()
                                .fill(LadderColors.accentLime.opacity(0.7))
                                .frame(width: 2, height: 14)
                                .offset(x: geo.size.width * (medallionHours / academicHours) - 1)
                        }
                    }
                    .frame(height: 8)
                }

                HStack(spacing: LadderSpacing.sm) {
                    Circle().fill(LadderColors.accentLime).frame(width: 8, height: 8)
                    Text("Medallion threshold (75 hrs)")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                    Button {
                        showAddHoursSheet = true
                    } label: {
                        Label("Log Hours", systemImage: "plus")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.primaryContainer.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Requirements Breakdown

    private var requirementsBreakdown: some View {
        VStack(spacing: LadderSpacing.sm) {
            Text("REQUIREMENTS BREAKDOWN")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
                .frame(maxWidth: .infinity, alignment: .leading)

            requirementRow(
                scholarship: "Academic Scholars",
                tuition: "100% FL public tuition",
                gpaReq: academicGPA,
                currentGPA: currentGPA,
                hrsReq: academicHours,
                currentHrs: serviceHours,
                satReq: academicSAT,
                currentSAT: satScore,
                color: LadderColors.accentLime
            )

            requirementRow(
                scholarship: "Medallion Scholars",
                tuition: "75% FL public tuition",
                gpaReq: medallionGPA,
                currentGPA: currentGPA,
                hrsReq: medallionHours,
                currentHrs: serviceHours,
                satReq: medallionSAT,
                currentSAT: satScore,
                color: LadderColors.primary
            )
        }
    }

    private func requirementRow(scholarship: String, tuition: String, gpaReq: Double, currentGPA: Double, hrsReq: Double, currentHrs: Double, satReq: Int, currentSAT: Int, color: Color) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text(scholarship)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text(tuition)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(color)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, 3)
                        .background(color.opacity(0.12))
                        .clipShape(Capsule())
                }

                HStack(spacing: LadderSpacing.lg) {
                    reqItem("GPA", required: String(format: "%.1f", gpaReq), current: String(format: "%.2f", currentGPA), met: currentGPA >= gpaReq, color: color)
                    reqItem("Service", required: "\(Int(hrsReq)) hrs", current: "\(Int(currentHrs)) hrs", met: currentHrs >= hrsReq, color: color)
                    reqItem("SAT", required: "\(satReq)", current: "\(currentSAT)", met: currentSAT >= satReq, color: color)
                }
            }
        }
    }

    private func reqItem(_ label: String, required: String, current: String, met: Bool, color: Color) -> some View {
        VStack(spacing: LadderSpacing.xxs) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(met ? color : LadderColors.outline)
            Text(label).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
            Text(current).font(LadderTypography.titleSmall).foregroundStyle(met ? color : LadderColors.onSurface)
            Text("req. \(required)").font(.system(size: 9)).foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Service Log

    private var serviceLogSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                Text("SERVICE LOG")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                Spacer()
                Button { showAddHoursSheet = true } label: {
                    Label("Add Entry", systemImage: "plus")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.primary)
                }
            }

            ForEach(serviceEntries) { entry in
                serviceEntryRow(entry)
            }
        }
    }

    private func serviceEntryRow(_ entry: ServiceEntry) -> some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                Circle().fill(LadderColors.primaryContainer.opacity(0.25)).frame(width: 40, height: 40)
                Image(systemName: "heart.fill").font(.system(size: 16)).foregroundStyle(LadderColors.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.organization).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                Text(entry.date).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
            Text("+\(Int(entry.hours)) hrs")
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.accentLime)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - FAQ

    private var faqSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "questionmark.circle.fill").foregroundStyle(LadderColors.accentLime)
                    Text("Bright Futures FAQ").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                }
                faqItem("What counts as community service?", answer: "Unpaid service at nonprofits, schools, government agencies, or religious organizations. Paid work and internships do NOT count.")
                faqItem("When do I apply?", answer: "Apply through the Florida Student Assistance Grant (FSAG) portal at floridastudentfinancialaidsg.org during your senior year.")
                faqItem("Does it apply to private FL schools?", answer: "Academic Scholars can use the award at private FL colleges, but at a lower rate (~$2,000/year). Full benefit applies at FL public universities.")
                faqItem("What if I'm below the GPA requirement?", answer: "Your GPA is locked at the time of graduation. Focus on bringing it up before senior year.")
            }
        }
    }

    private func faqItem(_ question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
            Text(answer).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Add Hours Sheet

    private var addHoursSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                VStack(spacing: LadderSpacing.lg) {
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Log Service Hours").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                            LadderTextField("Organization name", text: .constant(""))
                            LadderTextField("Hours (e.g. 4)", text: $newHoursText)
                                .keyboardType(.decimalPad)
                            LadderTextField("Date (e.g. March 2025)", text: .constant(""))
                        }
                    }
                    LadderPrimaryButton("Save Hours", icon: "checkmark") {
                        let hrs = Double(newHoursText) ?? 0
                        if hrs > 0 {
                            serviceHours += hrs
                            let entry = ServiceEntry(organization: "Community Service", hours: hrs, date: "Today")
                            serviceEntries.insert(entry, at: 0)
                        }
                        showAddHoursSheet = false
                        newHoursText = ""
                    }
                    Spacer()
                }
                .padding(LadderSpacing.md)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { showAddHoursSheet = false }
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Computed

    private var notAvailableInState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Image(systemName: "mappin.slash.circle")
                .font(.system(size: 56))
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("Bright Futures is Florida-only")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text("This scholarship program is available to Florida residents. Update your state in Profile Settings if this looks wrong.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.xl)
        }
        .padding(LadderSpacing.xxl)
    }

    private var scholarshipLevel: ScholarshipLevel {
        let academicMet = currentGPA >= academicGPA && serviceHours >= academicHours && satScore >= academicSAT
        let medallionMet = currentGPA >= medallionGPA && serviceHours >= medallionHours && satScore >= medallionSAT

        if academicMet {
            return ScholarshipLevel(title: "Academic Scholars", subtitle: "You qualify for 100% tuition at FL public universities", tuitionCoverage: "100%", icon: "star.fill", color: LadderColors.accentLime)
        } else if medallionMet {
            return ScholarshipLevel(title: "Medallion Scholars", subtitle: "You qualify for 75% tuition at FL public universities", tuitionCoverage: "75%", icon: "checkmark.seal.fill", color: LadderColors.primary)
        } else {
            let closer = (academicGPA - currentGPA) < 0.5 && (academicHours - serviceHours) < 30
            return ScholarshipLevel(title: closer ? "Almost There" : "Not Yet Eligible", subtitle: closer ? "Keep going — you're close to Medallion Scholars" : "Meet the GPA and service hour requirements", tuitionCoverage: "0%", icon: closer ? "flame.fill" : "clock", color: Color.orange)
        }
    }
}

// MARK: - Supporting Models

struct ScholarshipLevel {
    let title: String
    let subtitle: String
    let tuitionCoverage: String
    let icon: String
    let color: Color
}

struct ServiceEntry: Identifiable {
    let id = UUID()
    let organization: String
    let hours: Double
    let date: String

    static var sampleEntries: [ServiceEntry] {
        [
            ServiceEntry(organization: "Community Food Bank", hours: 12, date: "Feb 2025"),
            ServiceEntry(organization: "Hospital Volunteer", hours: 8, date: "Jan 2025"),
            ServiceEntry(organization: "Habitat for Humanity", hours: 6, date: "Dec 2024"),
            ServiceEntry(organization: "Animal Shelter", hours: 10, date: "Nov 2024"),
            ServiceEntry(organization: "School Tutoring Program", hours: 11, date: "Oct 2024"),
        ]
    }
}

#Preview {
    NavigationStack { BrightFuturesTrackerView() }
}
