import SwiftUI

// MARK: - Essay Hub View

struct EssayHubView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var essays: [EssayItem] = EssayItem.samples
    @State private var selectedEssay: EssayItem? = EssayItem.samples.first
    @State private var draftText: String = ""

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
                Text("Essay Hub")
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
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(spacing: 0) {
                iPadEssayListColumn
                    .frame(width: 300)
                    .background(LadderColors.surfaceContainerLow)

                Rectangle().fill(LadderColors.outlineVariant).frame(width: 1)

                iPadEditorColumn
                    .frame(maxWidth: .infinity)

                Rectangle().fill(LadderColors.outlineVariant).frame(width: 1)

                iPadFeedbackColumn
                    .frame(width: 340)
                    .background(LadderColors.surfaceContainerLow)
            }
        }
    }

    private var iPadEssayListColumn: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Text("My Essays")
                    .font(LadderTypography.titleLarge)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                Button {
                    coordinator.navigate(to: .advisorChat(sessionId: nil))
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LadderColors.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.top, LadderSpacing.lg)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    iPadEssaySection(title: "DRAFTS", items: essays.filter { $0.status == "Draft" })
                    iPadEssaySection(title: "IN PROGRESS", items: essays.filter { $0.status == "Not Started" })
                    iPadEssaySection(title: "COMPLETE", items: [])

                    Divider().padding(.vertical, LadderSpacing.sm)

                    Text("COMMON APP PROMPTS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.md)

                    ForEach(CommonAppPrompt.prompts.prefix(4)) { prompt in
                        Button {
                            coordinator.navigate(to: .advisorChat(sessionId: nil))
                        } label: {
                            HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                Text("\(prompt.number)")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.primary)
                                    .frame(width: 20)
                                Text(prompt.title)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, LadderSpacing.xl)
            }
        }
    }

    private func iPadEssaySection(title: String, items: [EssayItem]) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
                .padding(.horizontal, LadderSpacing.md)

            if items.isEmpty {
                Text("None yet")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.xs)
            } else {
                ForEach(items) { essay in
                    Button { selectedEssay = essay } label: {
                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text(essay.title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)
                            HStack(spacing: LadderSpacing.xs) {
                                Text(essay.type)
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Spacer()
                                Text("\(essay.wordCount)w")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            LinearProgressBar(progress: essay.progress)
                        }
                        .padding(LadderSpacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            (selectedEssay?.id == essay.id
                                ? LadderColors.primaryContainer.opacity(0.3)
                                : LadderColors.surfaceContainer.opacity(0.5))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, LadderSpacing.sm)
                }
            }
        }
    }

    private var iPadEditorColumn: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(selectedEssay?.title ?? "Untitled Essay")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()
                    if let essay = selectedEssay {
                        Text("\(essay.type) · \(essay.wordCount) words")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                Spacer()
                LadderAccentButton("Get AI Review", icon: "sparkles") { }
            }
            .padding(.horizontal, LadderSpacing.xl)
            .padding(.top, LadderSpacing.lg)

            ScrollView(showsIndicators: false) {
                TextEditor(text: $draftText)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 500)
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLowest)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    .padding(.horizontal, LadderSpacing.xl)
                    .padding(.bottom, LadderSpacing.xl)
            }
        }
    }

    private var iPadFeedbackColumn: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(LadderColors.accentLime)
                    Text("AI Feedback")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }

                feedbackCard(
                    title: "Overall Score",
                    body: "82 / 100 — strong opening hook, room to deepen reflection.",
                    icon: "star.fill",
                    tint: LadderColors.accentLime
                )

                feedbackCard(
                    title: "Strengths",
                    body: "Vivid sensory details in the opening paragraph. Clear voice throughout.",
                    icon: "checkmark.seal.fill",
                    tint: LadderColors.primary
                )

                feedbackCard(
                    title: "Improve",
                    body: "Tighten the middle section — cut 40-60 words. Show impact more concretely.",
                    icon: "exclamationmark.triangle.fill",
                    tint: LadderColors.tertiary
                )

                feedbackCard(
                    title: "Structure",
                    body: "Intro: Strong. Body: Needs focus. Conclusion: Good callback.",
                    icon: "square.stack.3d.up.fill",
                    tint: LadderColors.primary
                )

                LadderPrimaryButton("Apply Suggestions", icon: "wand.and.stars") { }
            }
            .padding(LadderSpacing.md)
            .padding(.top, LadderSpacing.lg)
        }
    }

    private func feedbackCard(title: String, body: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(tint)
                Text(title)
                    .font(LadderTypography.labelLarge)
                    .foregroundStyle(LadderColors.onSurface)
            }
            Text(body)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(LadderSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LadderColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
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
