import SwiftUI

// MARK: - Essay Hub View

struct EssayHubView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @State private var essays: [EssayItem] = EssayItem.samples

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Header card
                    LadderCard(elevated: true) {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(LadderColors.accentLime)
                                Text("AI-Powered Essay Assistant")
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }

                            Text("Brainstorm ideas, get feedback on drafts, and refine your essays with your AI advisor.")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            LadderPrimaryButton("Start New Essay", icon: "plus") {
                                coordinator.navigate(to: .advisorChat(sessionId: nil))
                            }
                        }
                    }

                    // Common App Prompts
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("COMMON APP PROMPTS 2026-2027")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        ForEach(CommonAppPrompt.prompts) { prompt in
                            promptCard(prompt)
                        }
                    }

                    // My Essays
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("MY ESSAYS")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        if essays.isEmpty {
                            emptyState
                        } else {
                            ForEach(essays) { essay in
                                essayCard(essay)
                            }
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
                Text("Essay Hub")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private func promptCard(_ prompt: CommonAppPrompt) -> some View {
        Button {
            coordinator.navigate(to: .advisorChat(sessionId: nil))
        } label: {
            HStack(alignment: .top, spacing: LadderSpacing.md) {
                Text("\(prompt.number)")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(prompt.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(prompt.description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func essayCard(_ essay: EssayItem) -> some View {
        HStack(spacing: LadderSpacing.md) {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(essay.title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text(essay.type)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                HStack(spacing: LadderSpacing.sm) {
                    LadderTagChip(essay.status, icon: essay.statusIcon)
                    Text("\(essay.wordCount) words")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            Spacer()

            LinearProgressBar(progress: essay.progress)
                .frame(width: 60)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundStyle(LadderColors.onSurfaceVariant)

            Text("No essays yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Start writing with AI assistance")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xxl)
    }
}

// MARK: - Models

struct CommonAppPrompt: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String

    static let prompts: [CommonAppPrompt] = [
        CommonAppPrompt(number: 1, title: "Background & Identity", description: "Some students have a background, identity, interest, or talent so meaningful they believe their application would be incomplete without it."),
        CommonAppPrompt(number: 2, title: "Obstacle & Setback", description: "The lessons we take from obstacles we encounter can be fundamental to later success. Recount a time when you faced a challenge, setback, or failure."),
        CommonAppPrompt(number: 3, title: "Questioned a Belief", description: "Reflect on a time when you questioned or challenged a belief or idea. What prompted your thinking?"),
        CommonAppPrompt(number: 4, title: "Gratitude & Kindness", description: "Reflect on something that someone has done for you that has made you happy or thankful in a surprising way."),
        CommonAppPrompt(number: 5, title: "Personal Growth", description: "Discuss an accomplishment, event, or realization that sparked a period of personal growth and a new understanding of yourself."),
        CommonAppPrompt(number: 6, title: "Topic of Fascination", description: "Describe a topic, idea, or concept you find so engaging that it makes you lose all track of time."),
        CommonAppPrompt(number: 7, title: "Your Choice", description: "Share an essay on any topic of your choice. It can be one you've already written, one that responds to a different prompt, or one of your own design."),
    ]
}

struct EssayItem: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let status: String
    let statusIcon: String
    let wordCount: Int
    let progress: Double

    static var samples: [EssayItem] {
        [
            EssayItem(title: "My Journey in Healthcare", type: "Personal Statement", status: "Draft", statusIcon: "pencil", wordCount: 320, progress: 0.5),
            EssayItem(title: "Why UF Honors College", type: "Supplemental", status: "Not Started", statusIcon: "circle", wordCount: 0, progress: 0.0),
        ]
    }
}

#Preview {
    NavigationStack {
        EssayHubView()
            .environment(AppCoordinator())
    }
}
