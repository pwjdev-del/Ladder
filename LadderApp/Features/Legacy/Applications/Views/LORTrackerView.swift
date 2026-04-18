import SwiftUI
import SwiftData

// MARK: - Letter of Recommendation Tracker

struct LORTrackerView: View {
    @Environment(\.modelContext) private var context
    @State private var letters: [LetterOfRecModel] = []
    @State private var showingAddSheet = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Summary
                    LadderCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Recommendations")
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                let received = letters.filter { $0.status == "received" || $0.status == "submitted" }.count
                                Text("\(received)/\(letters.count) received")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            Spacer()
                            Button { showingAddSheet = true } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(LadderColors.primary)
                            }
                        }
                    }

                    // Letter cards
                    ForEach(letters, id: \.recommenderName) { letter in
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(letter.recommenderName)
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                        Text(letter.recommenderRole)
                                            .font(LadderTypography.labelSmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                        if let subject = letter.subject {
                                            Text(subject)
                                                .font(LadderTypography.labelSmall)
                                                .foregroundStyle(LadderColors.primary)
                                        }
                                    }
                                    Spacer()
                                    statusBadge(letter.status)
                                }

                                if !letter.collegesFor.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 4) {
                                            ForEach(letter.collegesFor, id: \.self) { college in
                                                Text(college)
                                                    .font(LadderTypography.labelSmall)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(LadderColors.surfaceContainerHigh)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }

                                // Status actions
                                HStack(spacing: LadderSpacing.sm) {
                                    ForEach(nextStatuses(from: letter.status), id: \.self) { nextStatus in
                                        Button {
                                            letter.status = nextStatus
                                            try? context.save()
                                            loadLetters()
                                        } label: {
                                            Text("Mark \(nextStatus.capitalized)")
                                                .font(LadderTypography.labelSmall)
                                                .foregroundStyle(LadderColors.primary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(LadderColors.primary.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if letters.isEmpty {
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "envelope.badge.person.crop")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("No recommendation letters tracked yet")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            LadderPrimaryButton("Add Recommender", icon: "plus") {
                                showingAddSheet = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddRecommenderSheet { name, role, subject in
                let lor = LetterOfRecModel(recommenderName: name, recommenderRole: role)
                lor.subject = subject
                context.insert(lor)
                try? context.save()
                loadLetters()
            }
        }
        .task { loadLetters() }
    }

    private func loadLetters() {
        let descriptor = FetchDescriptor<LetterOfRecModel>(sortBy: [SortDescriptor(\.createdAt)])
        letters = (try? context.fetch(descriptor)) ?? []
    }

    @ViewBuilder
    private func statusBadge(_ status: String) -> some View {
        let (color, icon): (Color, String) = {
            switch status {
            case "requested": return (Color.orange, "clock")
            case "in_progress": return (LadderColors.primaryContainer, "pencil")
            case "submitted", "received": return (LadderColors.primary, "checkmark.circle.fill")
            default: return (LadderColors.outlineVariant, "circle")
            }
        }()

        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(status.replacingOccurrences(of: "_", with: " ").capitalized).font(LadderTypography.labelSmall)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }

    private func nextStatuses(from current: String) -> [String] {
        switch current {
        case "not_requested": return ["requested"]
        case "requested": return ["in_progress", "submitted"]
        case "in_progress": return ["submitted"]
        case "submitted": return ["received"]
        default: return []
        }
    }
}

struct AddRecommenderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var role = "Teacher"
    @State private var subject = ""
    let onSave: (String, String, String?) -> Void
    let roles = ["Teacher", "Counselor", "Coach", "Employer", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                VStack(spacing: LadderSpacing.lg) {
                    LadderTextField("Recommender Name", text: $name)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(roles, id: \.self) { r in
                                LadderFilterChip(title: r, isSelected: role == r) { role = r }
                            }
                        }
                    }
                    LadderTextField("Subject (optional)", text: $subject)
                    LadderPrimaryButton("Add Recommender", icon: "plus") {
                        onSave(name, role, subject.isEmpty ? nil : subject)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    Spacer()
                }
                .padding(LadderSpacing.lg)
            }
            .navigationTitle("Add Recommender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
