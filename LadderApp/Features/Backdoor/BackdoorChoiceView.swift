import SwiftUI

// §14.1 — staff backdoor choice screen.
// Reached via the 30-second logo long-press on LandingView.
// Routes to FounderLoginView (existing) or EmployeeLoginView (new).
// Visual language mirrors FounderLoginView: dark forest, lime accents.

public struct BackdoorChoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var goFounderLogin = false
    @State private var goEmployeeLogin = false

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.forest700.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    header
                    // MaxWidthContainer prevents the card from becoming unreadably wide on iPad
                    MaxWidthContainer(maxWidth: 460) {
                        choiceCard
                    }
                }
                .padding(.horizontal, sizeClass == .regular ? 0 : 24)

                Spacer()

                footer
                    .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goFounderLogin) { FounderLoginView() }
        .navigationDestination(isPresented: $goEmployeeLogin) { EmployeeLoginView() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("LADDER · STAFF")
                .font(.ladderCaps(12))
                .tracking(3.0)
                .foregroundStyle(LadderBrand.cream100.opacity(0.85))

            Text("Select your role to continue.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))
        }
    }

    // MARK: - Choice card

    private var choiceCard: some View {
        VStack(spacing: 16) {
            // Primary — lime solid (founder)
            Button {
                goFounderLogin = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Login as Founder")
                        .font(.ladderLabel(16))
                }
                .foregroundStyle(LadderBrand.ink900)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(LadderBrand.lime500)
                .clipShape(Capsule())
                .shadow(color: LadderBrand.lime500.opacity(0.3), radius: 10, y: 4)
            }

            // Secondary — outlined (employee)
            Button {
                goEmployeeLogin = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Login as Employee")
                        .font(.ladderLabel(16))
                }
                .foregroundStyle(LadderBrand.cream100)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay(Capsule().stroke(LadderBrand.cream100.opacity(0.35), lineWidth: 1.5))
                .clipShape(Capsule())
            }
        }
        .padding(24)
        .background(LadderBrand.forest900.opacity(0.35))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LadderBrand.cream100.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 12) {
            Text("This surface does not render tenant data.\nEvery action is audited.")
                .font(.ladderBody(12))
                .foregroundStyle(LadderBrand.cream100.opacity(0.5))
                .multilineTextAlignment(.center)

            Button("Cancel") { dismiss() }
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.cream100.opacity(0.45))
        }
    }
}
