import SwiftUI

// MARK: - Thank You Note Generator

struct ThankYouNoteView: View {
    @Environment(\.dismiss) private var dismiss
    let collegeId: String?

    @State private var recipientName = ""
    @State private var recipientRole = "Interviewer"
    @State private var whatDiscussed = ""
    @State private var specificDetails = ""
    @State private var generatedNote = ""
    @State private var isGenerating = false
    @State private var showResult = false

    let roles = ["Interviewer", "Admissions Counselor", "Teacher", "School Counselor", "Coach"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(LadderColors.primary)
                        Text("Thank You Note")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .padding(.top, LadderSpacing.lg)

                    if !showResult {
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("Recipient Name")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                LadderTextField("e.g., Ms. Johnson", text: $recipientName)

                                Text("Role")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: LadderSpacing.xs) {
                                        ForEach(roles, id: \.self) { role in
                                            LadderFilterChip(title: role, isSelected: recipientRole == role) {
                                                recipientRole = role
                                            }
                                        }
                                    }
                                }

                                Text("What You Discussed")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                TextEditor(text: $whatDiscussed)
                                    .frame(minHeight: 60)
                                    .font(LadderTypography.bodyMedium)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

                                Text("Specific Details to Mention")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                TextEditor(text: $specificDetails)
                                    .frame(minHeight: 60)
                                    .font(LadderTypography.bodyMedium)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                            }
                        }

                        LadderPrimaryButton("Generate Note", icon: "wand.and.stars") {
                            generateNote()
                        }
                        .disabled(recipientName.isEmpty)
                        .opacity(recipientName.isEmpty ? 0.5 : 1)
                    } else {
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("Your Thank You Note")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text(generatedNote)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .textSelection(.enabled)
                            }
                        }

                        HStack(spacing: LadderSpacing.md) {
                            Button {
                                UIPasteboard.general.string = generatedNote
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.primary)
                                    .padding(.horizontal, LadderSpacing.lg)
                                    .padding(.vertical, LadderSpacing.sm)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(Capsule())
                            }

                            Button { showResult = false; generatedNote = "" } label: {
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

                    if isGenerating { ProgressView().tint(LadderColors.primary) }
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

    private func generateNote() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            generatedNote = """
            Dear \(recipientName),

            Thank you so much for taking the time to \(recipientRole == "Interviewer" ? "interview me" : "support my college application journey"). I truly appreciated our conversation\(whatDiscussed.isEmpty ? "" : " about \(whatDiscussed)").

            \(specificDetails.isEmpty ? "Your insights were incredibly valuable and have reinforced my enthusiasm." : "I was particularly grateful for \(specificDetails).")

            Thank you again for your generosity with your time and expertise. It meant a great deal to me.

            Warm regards,
            [Your Name]
            """
            isGenerating = false
            showResult = true
        }
    }
}
