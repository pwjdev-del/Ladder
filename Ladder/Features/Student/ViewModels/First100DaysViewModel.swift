import SwiftUI
import SwiftData

// MARK: - First 100 Days ViewModel
// Tracks a student's first 100 days at their committed college

@Observable
final class First100DaysViewModel {

    // MARK: - State

    var collegeName: String = "Your College"
    var startDate: Date = Date()
    var milestones: [MilestonePhase] = MilestonePhase.defaultPhases

    // MARK: - Computed

    var currentDay: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(max(days + 1, 1), 100)
    }

    var overallProgress: Double {
        let total = milestones.flatMap(\.items).count
        guard total > 0 else { return 0 }
        let completed = milestones.flatMap(\.items).filter(\.isCompleted).count
        return Double(completed) / Double(total)
    }

    var completedCount: Int {
        milestones.flatMap(\.items).filter(\.isCompleted).count
    }

    var totalCount: Int {
        milestones.flatMap(\.items).count
    }

    var currentPhase: MilestonePhase? {
        switch currentDay {
        case 1...7: return milestones.first { $0.id == "move_in" }
        case 8...30: return milestones.first { $0.id == "first_month" }
        case 31...60: return milestones.first { $0.id == "getting_settled" }
        case 61...100: return milestones.first { $0.id == "finding_rhythm" }
        default: return nil
        }
    }

    // MARK: - Persistence Keys

    private func storageKey(for itemId: String) -> String {
        "first100days_\(itemId)"
    }

    // MARK: - Data Loading

    @MainActor
    func loadData(context: ModelContext) {
        // Find committed college
        let appDescriptor = FetchDescriptor<ApplicationModel>()
        if let apps = try? context.fetch(appDescriptor) {
            if let committed = apps.first(where: { $0.status == "committed" }) {
                collegeName = committed.collegeName
                // Use submission date or August 15 of current year as estimated start
                if let submittedAt = committed.submittedAt {
                    let cal = Calendar.current
                    let year = cal.component(.year, from: submittedAt)
                    startDate = cal.date(from: DateComponents(year: year, month: 8, day: 15)) ?? Date()
                } else {
                    let cal = Calendar.current
                    let year = cal.component(.year, from: Date())
                    startDate = cal.date(from: DateComponents(year: year, month: 8, day: 15)) ?? Date()
                }
            }
        }

        // Load completion states from AppStorage
        for phaseIndex in milestones.indices {
            for itemIndex in milestones[phaseIndex].items.indices {
                let key = storageKey(for: milestones[phaseIndex].items[itemIndex].id)
                milestones[phaseIndex].items[itemIndex].isCompleted = UserDefaults.standard.bool(forKey: key)
            }
        }
    }

    // MARK: - Toggle

    func toggleItem(phaseId: String, itemId: String) {
        guard let phaseIndex = milestones.firstIndex(where: { $0.id == phaseId }),
              let itemIndex = milestones[phaseIndex].items.firstIndex(where: { $0.id == itemId }) else { return }

        milestones[phaseIndex].items[itemIndex].isCompleted.toggle()
        let key = storageKey(for: itemId)
        UserDefaults.standard.set(milestones[phaseIndex].items[itemIndex].isCompleted, forKey: key)
    }
}

// MARK: - Models

struct MilestonePhase: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let dayRange: String
    let icon: String
    let color: Color
    var items: [MilestoneItem]

    var completedCount: Int { items.filter(\.isCompleted).count }
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedCount) / Double(items.count)
    }

    static var defaultPhases: [MilestonePhase] {
        [
            MilestonePhase(
                id: "move_in",
                title: "Move In",
                subtitle: "Get settled into your new home",
                dayRange: "Days 1–7",
                icon: "box.truck.fill",
                color: Color(red: 0.55, green: 0.30, blue: 0.10),
                items: [
                    MilestoneItem(id: "unpack", title: "Unpack and organize your room", icon: "shippingbox"),
                    MilestoneItem(id: "meet_roommate", title: "Meet your roommate", icon: "person.2"),
                    MilestoneItem(id: "orientation", title: "Attend orientation", icon: "map"),
                    MilestoneItem(id: "get_id", title: "Get your student ID card", icon: "person.text.rectangle"),
                ]
            ),
            MilestonePhase(
                id: "first_month",
                title: "First Month",
                subtitle: "Build your foundation",
                dayRange: "Days 8–30",
                icon: "calendar.badge.clock",
                color: LadderColors.primary,
                items: [
                    MilestoneItem(id: "attend_classes", title: "Attend all classes for a full week", icon: "book"),
                    MilestoneItem(id: "join_clubs", title: "Join 2 clubs or organizations", icon: "person.3"),
                    MilestoneItem(id: "office_hours", title: "Visit a professor's office hours", icon: "person.crop.circle.badge.questionmark"),
                    MilestoneItem(id: "study_spots", title: "Find your favorite study spots", icon: "building.2"),
                ]
            ),
            MilestonePhase(
                id: "getting_settled",
                title: "Getting Settled",
                subtitle: "Expand your world",
                dayRange: "Days 31–60",
                icon: "house.and.flag",
                color: Color(red: 0.15, green: 0.50, blue: 0.35),
                items: [
                    MilestoneItem(id: "study_group", title: "Form a study group", icon: "person.2.gobackward"),
                    MilestoneItem(id: "explore_campus", title: "Explore campus fully", icon: "figure.walk"),
                    MilestoneItem(id: "dining", title: "Try all campus dining options", icon: "fork.knife"),
                ]
            ),
            MilestonePhase(
                id: "finding_rhythm",
                title: "Finding Your Rhythm",
                subtitle: "Hit your stride",
                dayRange: "Days 61–100",
                icon: "metronome",
                color: Color(red: 0.15, green: 0.35, blue: 0.55),
                items: [
                    MilestoneItem(id: "midterm_prep", title: "Prepare for midterms", icon: "doc.text"),
                    MilestoneItem(id: "campus_job", title: "Search for a campus job", icon: "briefcase"),
                    MilestoneItem(id: "spring_register", title: "Register for spring classes", icon: "list.clipboard"),
                ]
            ),
        ]
    }
}

struct MilestoneItem: Identifiable {
    let id: String
    let title: String
    let icon: String
    var isCompleted: Bool = false
}
