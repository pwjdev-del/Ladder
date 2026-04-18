import SwiftUI

// MARK: - Legal Settings View
// Accessible from Settings. Shows links to all legal docs, consent date,
// data export, and data deletion.

struct LegalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showDataDeletion = false
    @State private var showDPASummary = false
    @State private var showFERPA = false

    private var consentDate: String {
        let dateStr = UserDefaults.standard.string(forKey: "ladder_consent_date") ?? ""
        if let isoDate = try? Date(dateStr, strategy: .iso8601) {
            return isoDate.formatted(date: .long, time: .omitted)
        }
        return "Not recorded"
    }

    private var consentVersion: String {
        UserDefaults.standard.string(forKey: "ladder_consent_version") ?? "Unknown"
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {

                    // Consent Status Card
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Label("Your Consent Record", systemImage: "checkmark.shield.fill")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.primary)

                        VStack(spacing: LadderSpacing.sm) {
                            consentStatusRow("Terms of Service", accepted: true)
                            consentStatusRow("Privacy Policy", accepted: true)
                            consentStatusRow("Liability Waiver", accepted: true)
                            consentStatusRow("AI Disclaimer", accepted: true)
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Agreed on")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Text(consentDate)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Version")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Text(consentVersion)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                    // Legal Documents
                    legalSection("LEGAL DOCUMENTS") {
                        legalRow("Terms of Service", icon: "doc.text") { showTerms = true }
                        legalRow("Privacy Policy", icon: "hand.raised") { showPrivacy = true }
                        legalRow("FERPA Notice", icon: "building.columns") { showFERPA = true }
                        legalRow("Data Processing Agreement", icon: "server.rack") { showDPASummary = true }
                    }

                    // Your Data Rights
                    legalSection("YOUR DATA RIGHTS") {
                        legalRow("Delete My Account & Data", icon: "trash", tint: LadderColors.error) {
                            showDataDeletion = true
                        }
                    }

                    // Company
                    VStack(spacing: LadderSpacing.xs) {
                        Text(LegalTexts.companyName)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(LegalTexts.companyAddress)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(LegalTexts.companyEmail)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, LadderSpacing.md)
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
                Text("Legal & Privacy")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showTerms) { TermsOfServiceView() }
        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
        .sheet(isPresented: $showDataDeletion) { DataDeletionView() }
        .sheet(isPresented: $showFERPA) { FERPANoticeView() }
        .sheet(isPresented: $showDPASummary) { DPASummaryView() }
    }

    private func legalSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: 0) {
                content()
            }
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    private func legalRow(_ title: String, icon: String, tint: Color = LadderColors.onSurface, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(tint)
                    .frame(width: 24)

                Text(title)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(tint)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
        }
        .buttonStyle(.plain)
    }

    private func consentStatusRow(_ title: String, accepted: Bool) -> some View {
        HStack {
            Text(title)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
            Image(systemName: accepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(accepted ? LadderColors.primary : LadderColors.error)
        }
    }
}

// MARK: - FERPA Notice Sheet

struct FERPANoticeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                        Text(LegalTexts.ferpaNotice)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineSpacing(4)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(LadderColors.onSurface)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("FERPA Notice").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }
}

// MARK: - DPA Summary Sheet

struct DPASummaryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                        Text("This summary is for school/district admins. Full DPA available at \(LegalTexts.companyEmail).")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        Text(LegalTexts.dpaeSummary)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineSpacing(4)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(LadderColors.onSurface)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Data Processing Agreement").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }
}
