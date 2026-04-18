import SwiftUI
import SwiftData

// MARK: - Why This School Essay Seed Generator

struct WhyThisSchoolView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let collegeId: String

    @State private var viewModel: WhyThisSchoolViewModel

    init(collegeId: String) {
        self.collegeId = collegeId
        self._viewModel = State(initialValue: WhyThisSchoolViewModel(collegeId: collegeId))
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 40))
                            .foregroundStyle(LadderColors.primary)
                        Text("Why \(viewModel.college?.name ?? "This School")?")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .multilineTextAlignment(.center)
                        Text("AI-powered essay seed to help you craft an authentic \"Why Us\" essay")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LadderSpacing.lg)

                    // Talking Points Section
                    if !viewModel.talkingPoints.isEmpty {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("TALKING POINTS")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()
                        }

                        ForEach(viewModel.talkingPoints) { point in
                            LadderCard {
                                HStack(alignment: .top, spacing: LadderSpacing.md) {
                                    Image(systemName: point.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(LadderColors.primary)
                                        .frame(width: 28)

                                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                                        Text(point.title)
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                        Text(point.detail)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                    }
                                }
                            }
                        }
                    }

                    // Generate button
                    if !viewModel.hasGenerated {
                        LadderPrimaryButton("Generate Essay Outline", icon: "wand.and.stars") {
                            viewModel.generateOutline()
                        }
                        .disabled(viewModel.college == nil || viewModel.isGenerating)
                        .opacity(viewModel.college == nil ? 0.5 : 1)
                    }

                    // Loading
                    if viewModel.isGenerating {
                        LadderCard {
                            HStack(spacing: LadderSpacing.md) {
                                ProgressView()
                                    .tint(LadderColors.primary)
                                Text("Crafting your essay outline...")
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Essay paragraphs
                    if viewModel.hasGenerated {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("YOUR ESSAY OUTLINE")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()
                        }

                        ForEach(Array(viewModel.paragraphs.enumerated()), id: \.element.id) { index, paragraph in
                            essayParagraphCard(index: index, paragraph: paragraph)
                        }

                        // Action buttons
                        HStack(spacing: LadderSpacing.md) {
                            Button {
                                viewModel.copyToClipboard()
                            } label: {
                                Label(
                                    viewModel.copiedToClipboard ? "Copied" : "Copy All",
                                    systemImage: viewModel.copiedToClipboard ? "checkmark" : "doc.on.doc"
                                )
                                .font(LadderTypography.labelLarge)
                                .foregroundStyle(viewModel.copiedToClipboard ? LadderColors.primary : LadderColors.onSurface)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LadderSpacing.md)
                                .background(LadderColors.surfaceContainerHigh)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(ScaleButtonStyle())

                            Button {
                                viewModel.hasGenerated = false
                                viewModel.paragraphs = []
                                viewModel.generateOutline()
                            } label: {
                                Label("Regenerate", systemImage: "arrow.clockwise")
                                    .font(LadderTypography.labelLarge)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, LadderSpacing.md)
                                    .background(LadderColors.surfaceContainerHigh)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(ScaleButtonStyle())
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
            ToolbarItem(placement: .principal) {
                Text("Why This School")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task { viewModel.loadData(context: context) }
    }

    // MARK: - Essay Paragraph Card

    @ViewBuilder
    private func essayParagraphCard(index: Int, paragraph: EssayParagraph) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                // Paragraph number + heading
                HStack(spacing: LadderSpacing.sm) {
                    Text("\(index + 1)")
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.onPrimary)
                        .frame(width: 26, height: 26)
                        .background(LadderColors.primary)
                        .clipShape(Circle())

                    Text(paragraph.heading)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                }

                // Editable text area
                TextEditor(text: Binding(
                    get: {
                        viewModel.paragraphs[index].editedText.isEmpty
                            ? viewModel.paragraphs[index].placeholder
                            : viewModel.paragraphs[index].editedText
                    },
                    set: { newValue in
                        viewModel.paragraphs[index].editedText = newValue
                    }
                ))
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(
                    viewModel.paragraphs[index].editedText.isEmpty
                        ? LadderColors.onSurfaceVariant
                        : LadderColors.onSurface
                )
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(LadderSpacing.sm)
                .background(LadderColors.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

                // Tap hint
                if viewModel.paragraphs[index].editedText.isEmpty {
                    Text("Tap to edit and make it your own")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }
}
