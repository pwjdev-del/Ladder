import SwiftUI

// §14.3 — provisioning form for a new tenant. Brand gradient (no white).

public struct AddSchoolFormView: View {
    @State private var schoolName = ""
    @State private var slug = ""
    @State private var primaryColor = "#A8D234"
    @State private var logoURL = ""
    @State private var plan = "Pilot"
    @State private var seedAdminEmail = ""
    @State private var working = false
    @State private var provisionStep: Int = 0
    @State private var provisioned = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroTitle
                        formCard
                        if working || provisioned {
                            progressCard
                        }
                        provisionButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LadderBrand.cream100)
                    .frame(width: 40, height: 40)
                    .background(LadderBrand.cream100.opacity(0.12))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Provision a school")
                .font(.ladderLabel(14))
                .foregroundStyle(LadderBrand.cream100)
            Spacer()
            Spacer().frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var heroTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NEW TENANT · B2B")
                .font(.ladderCaps(11)).tracking(1.4).foregroundStyle(LadderBrand.lime500)
            Text("Add a new school")
                .font(.ladderDisplay(36, relativeTo: .largeTitle))
                .foregroundStyle(LadderBrand.cream100)
            Text("Creates an isolated tenant sandbox, issues a per-tenant DEK via KMS, seeds default flags (via Varun), and emails login credentials to the seed admin.")
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var formCard: some View {
        VStack(spacing: 14) {
            GradientInputField(label: "SCHOOL NAME",
                               icon: "building.columns",
                               placeholder: "Lakewood Ranch Preparatory Academy",
                               text: $schoolName,
                               capitalization: .words)
            GradientInputField(label: "SLUG (URL-SAFE)",
                               icon: "link",
                               placeholder: "lwrpa",
                               text: $slug,
                               mono: true)

            VStack(alignment: .leading, spacing: 6) {
                Text("PRIMARY COLOR").font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.cream100.opacity(0.85))
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: primaryColor) ?? LadderBrand.lime500)
                        .frame(width: 44, height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(LadderBrand.cream100.opacity(0.3), lineWidth: 1))
                    TextField("", text: $primaryColor,
                              prompt: Text("#AABBCC").foregroundColor(LadderBrand.cream100.opacity(0.45)))
                        .font(.ladderBody(15).monospaced())
                        .foregroundStyle(LadderBrand.cream100)
                        .tint(LadderBrand.lime500)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(LadderBrand.cream100.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            GradientInputField(label: "LOGO URL (OPTIONAL)",
                               icon: "photo",
                               placeholder: "https://…/logo.png",
                               text: $logoURL,
                               keyboard: .URL)

            VStack(alignment: .leading, spacing: 6) {
                Text("PLAN").font(.ladderCaps(11)).tracking(1.1).foregroundStyle(LadderBrand.cream100.opacity(0.85))
                HStack(spacing: 8) {
                    ForEach(["Pilot", "Standard", "Custom"], id: \.self) { p in
                        Button { plan = p } label: {
                            Text(p)
                                .font(.ladderLabel(13))
                                .foregroundStyle(plan == p ? LadderBrand.ink900 : LadderBrand.cream100)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(plan == p ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }

            GradientInputField(label: "SEED ADMIN EMAIL",
                               icon: "envelope",
                               placeholder: "admin@school.edu",
                               text: $seedAdminEmail,
                               keyboard: .emailAddress)
        }
        .padding(16)
        .background(LadderBrand.cream100.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(LadderBrand.cream100.opacity(0.15), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Progress

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PROVISIONING")
                .font(.ladderCaps(11)).tracking(1.4).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            progressStep("Creating tenant…",            index: 0)
            progressStep("Generating per-tenant DEK…",  index: 1)
            progressStep("Seeding default flags (Varun)…", index: 2)
            progressStep("Emailing seed admin…",        index: 3)
        }
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func progressStep(_ label: String, index: Int) -> some View {
        let done = provisionStep > index
        let current = provisionStep == index && working
        return HStack(spacing: 10) {
            if done {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(LadderBrand.lime500)
            } else if current {
                ProgressView().tint(LadderBrand.lime500)
            } else {
                Image(systemName: "circle").foregroundStyle(LadderBrand.cream100.opacity(0.35))
            }
            Text(label)
                .font(.ladderBody(13))
                .foregroundStyle(done || current ? LadderBrand.cream100 : LadderBrand.cream100.opacity(0.55))
        }
    }

    // MARK: - Provision

    private var provisionButton: some View {
        Button { provision() } label: {
            HStack(spacing: 8) {
                if working { ProgressView().tint(LadderBrand.ink900) }
                else if provisioned {
                    Text("Done · Back").font(.ladderLabel(16))
                } else {
                    Text("Provision tenant").font(.ladderLabel(16))
                    Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundStyle(LadderBrand.ink900)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(formReady ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.18))
            .clipShape(Capsule())
            .shadow(color: formReady ? LadderBrand.lime500.opacity(0.35) : .clear, radius: 12, y: 4)
        }
        .disabled(working || !formReady)
    }

    private var formReady: Bool {
        !schoolName.isEmpty && !slug.isEmpty && seedAdminEmail.contains("@")
    }

    private func provision() {
        if provisioned { dismiss(); return }
        Task { @MainActor in
            working = true
            for step in 0...3 {
                provisionStep = step
                try? await Task.sleep(nanoseconds: 700_000_000)
            }
            provisionStep = 4
            working = false
            provisioned = true
        }
    }
}
