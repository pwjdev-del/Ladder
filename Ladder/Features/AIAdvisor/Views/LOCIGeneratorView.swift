import SwiftUI

// MARK: - LOCI Generator (Letter of Continued Interest)

struct LOCIGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    let collegeId: String?

    @State private var collegeName = ""
    @State private var recentAccomplishments = ""
    @State private var whyThisSchool = ""
    @State private var newInformation = ""
    @State private var generatedLetter = ""
    @State private var isGenerating = false
    @State private var showResult = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "envelope.open.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(LadderColors.primary)
                        Text("LOCI Generator")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Generate a Letter of Continued Interest for your waitlisted school")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LadderSpacing.lg)

                    if !showResult {
                        // Input form
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("School Name")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                LadderTextField("e.g., University of Florida", text: $collegeName)

                                Text("Recent Accomplishments")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                TextEditor(text: $recentAccomplishments)
                                    .frame(minHeight: 80)
                                    .font(LadderTypography.bodyMedium)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

                                Text("Why This School?")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                TextEditor(text: $whyThisSchool)
                                    .frame(minHeight: 80)
                                    .font(LadderTypography.bodyMedium)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

                                Text("New Information Since Application")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                TextEditor(text: $newInformation)
                                    .frame(minHeight: 80)
                                    .font(LadderTypography.bodyMedium)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                            }
                        }

                        LadderPrimaryButton("Generate LOCI", icon: "wand.and.stars") {
                            generateLetter()
                        }
                        .disabled(collegeName.isEmpty)
                        .opacity(collegeName.isEmpty ? 0.5 : 1)
                    } else {
                        // Result
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("Your LOCI Draft")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)

                                Text(generatedLetter)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .textSelection(.enabled)
                            }
                        }

                        HStack(spacing: LadderSpacing.md) {
                            Button {
                                UIPasteboard.general.string = generatedLetter
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.primary)
                                    .padding(.horizontal, LadderSpacing.lg)
                                    .padding(.vertical, LadderSpacing.sm)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(Capsule())
                            }

                            Button {
                                showResult = false
                                generatedLetter = ""
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .padding(.horizontal, LadderSpacing.lg)
                                    .padding(.vertical, LadderSpacing.sm)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if isGenerating {
                        ProgressView()
                            .tint(LadderColors.primary)
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
    }

    private func generateLetter() {
        isGenerating = true
        // In production, this calls AIService. For now, template-based.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generatedLetter = """
            Dear Admissions Committee,

            I am writing to express my continued and sincere interest in attending \(collegeName). Since submitting my application, I have had several meaningful experiences that I believe strengthen my candidacy.

            \(recentAccomplishments.isEmpty ? "" : "Most notably, \(recentAccomplishments)")

            \(collegeName) remains my top choice because \(whyThisSchool.isEmpty ? "of its exceptional programs and campus community" : whyThisSchool).

            \(newInformation.isEmpty ? "" : "Additionally, I wanted to share that \(newInformation)")

            I am fully committed to enrolling at \(collegeName) if admitted and would be honored to join your community. Thank you for reconsidering my application.

            Sincerely,
            [Your Name]
            """
            isGenerating = false
            showResult = true
        }
    }
}
