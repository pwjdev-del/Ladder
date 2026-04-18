import SwiftUI

// MARK: - DPA Consent View
// Data Processing Agreement consent for school admins during onboarding
// Required for FERPA compliance before school can use Ladder

struct DPAConsentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var hasAuthority = false
    @State private var schoolName = ""

    var onConsent: (() -> Void)?

    private let dpaPoints: [(icon: String, text: String)] = [
        ("building.columns", "Ladder processes student data as a school official under FERPA"),
        ("lock.shield", "Student data is encrypted at rest and in transit"),
        ("building.2", "Data is never shared between schools"),
        ("trash", "Parents/students can request data deletion at any time"),
        ("archivebox", "Data is automatically archived 2 years after graduation"),
        ("eye", "All counselor access to student data is logged")
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(LadderColors.primary)

                        Text("Data Processing Agreement")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Please review and accept to continue")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, LadderSpacing.lg)

                    // DPA Summary Card
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("KEY TERMS")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        ForEach(dpaPoints.indices, id: \.self) { index in
                            dpaPointRow(
                                icon: dpaPoints[index].icon,
                                text: dpaPoints[index].text,
                                number: index + 1
                            )
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: LadderRadius.lg)
                            .fill(LadderColors.surfaceContainerLow)
                    )

                    // School Name Field
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("School / District Name")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        LadderTextField("Enter school name", text: $schoolName, icon: "building.2")
                    }

                    // Authority Checkbox
                    Button {
                        hasAuthority.toggle()
                    } label: {
                        HStack(alignment: .top, spacing: LadderSpacing.md) {
                            Image(systemName: hasAuthority ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundStyle(hasAuthority ? LadderColors.primary : LadderColors.onSurfaceVariant)

                            Text("I have authority to sign this agreement on behalf of \(schoolName.isEmpty ? "[School Name]" : schoolName)")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .buttonStyle(.plain)

                    // Agree Button
                    LadderPrimaryButton("I Agree", icon: "checkmark.shield") {
                        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "dpa_signed_at")
                        UserDefaults.standard.set(schoolName, forKey: "dpa_school_name")
                        onConsent?()
                        dismiss()
                    }
                    .disabled(!hasAuthority || schoolName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(hasAuthority && !schoolName.trimmingCharacters(in: .whitespaces).isEmpty ? 1.0 : 0.5)

                    // Legal note
                    Text("By agreeing, you confirm compliance with FERPA, COPPA, and applicable state privacy laws.")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, LadderSpacing.xl)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - DPA Point Row

    @ViewBuilder
    private func dpaPointRow(icon: String, text: String, number: Int) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer)
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.primary)
            }

            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DPAConsentView()
}
