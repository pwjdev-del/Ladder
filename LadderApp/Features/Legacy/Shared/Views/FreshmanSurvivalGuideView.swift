import SwiftUI
import SwiftData

// MARK: - Freshman Survival Guide

struct FreshmanSurvivalGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let collegeId: String

    @State private var college: CollegeModel?
    @State private var completedItems: Set<String> = []

    private let sections: [(title: String, icon: String, items: [String])] = [
        ("Move-In Day", "box.truck", [
            "Pack essentials first (bedding, toiletries, documents)",
            "Bring copies of your ID, insurance card, and acceptance letter",
            "Label all electronics with your name",
            "Meet your RA and floor neighbors",
        ]),
        ("First Week", "calendar", [
            "Attend all orientation sessions",
            "Walk your class route before day 1",
            "Get your student ID and meal plan activated",
            "Download your school's app and set up email",
            "Locate the health center, library, and tutoring center",
        ]),
        ("Academics", "book", [
            "Buy or rent textbooks (check library reserves first)",
            "Introduce yourself to each professor during office hours",
            "Join a study group within the first 2 weeks",
            "Set up a consistent study schedule",
        ]),
        ("Campus Life", "person.3", [
            "Attend the activities fair — join 2-3 clubs",
            "Find your campus gym and recreation center",
            "Explore dining options beyond the main cafeteria",
            "Save campus safety number in your phone",
        ]),
        ("Wellness", "heart", [
            "Locate the counseling center (free for students)",
            "Establish a sleep schedule (aim for 7-8 hours)",
            "Stay hydrated and maintain regular meals",
            "Call home regularly but embrace independence",
        ]),
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    LadderCard {
                        VStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 36))
                                .foregroundStyle(LadderColors.primary)
                            Text("Freshman Survival Guide")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            if let name = college?.name {
                                Text(name)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            let completed = completedItems.count
                            let total = sections.flatMap(\.items).count
                            Text("\(completed)/\(total) complete")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.primary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Sections
                    ForEach(sections, id: \.title) { section in
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                HStack {
                                    Image(systemName: section.icon)
                                        .foregroundStyle(LadderColors.primary)
                                    Text(section.title)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                }

                                ForEach(section.items, id: \.self) { item in
                                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                        Button {
                                            if completedItems.contains(item) {
                                                completedItems.remove(item)
                                            } else {
                                                completedItems.insert(item)
                                            }
                                        } label: {
                                            Image(systemName: completedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(completedItems.contains(item) ? LadderColors.primary : LadderColors.outlineVariant)
                                        }

                                        Text(item)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                            .strikethrough(completedItems.contains(item))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .task {
            let descriptor = FetchDescriptor<CollegeModel>()
            if let results = try? context.fetch(descriptor) {
                college = results.first { String($0.scorecardId ?? 0) == collegeId }
            }
        }
    }
}
