import SwiftUI

// SPEC v2 §3 — placeholder employee dashboard.
// Full operational console (transfer approvals, etc.) is a follow-up task.
// No tenant data is rendered here. This surface is blocked by §14.4 data-wall
// via the .employee branch in SignedInRouter which routes directly here.

public struct EmployeeDashboardView: View {
    public let onLogout: () -> Void

    @State private var showComingSoon = false

    public init(onLogout: @escaping () -> Void) {
        self.onLogout = onLogout
    }

    public var body: some View {
        ZStack {
            LadderBrand.forest700.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView {
                    VStack(spacing: 20) {
                        pendingTransfersCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Coming soon", isPresented: $showComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Coming soon — see SPEC v2 §3")
        }
    }

    // MARK: - Header bar

    private var headerBar: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Employee Dashboard")
                    .font(.ladderLabel(20))
                    .foregroundStyle(LadderBrand.cream100)

                Text("Operational console for Ladder staff")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.6))
            }

            Spacer()

            Button(action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
            }
            .accessibilityLabel("Sign out")
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 20)
        .background(LadderBrand.forest900.opacity(0.4))
    }

    // MARK: - Pending transfers card

    private var pendingTransfersCard: some View {
        Button {
            showComingSoon = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "tray.and.arrow.up.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(LadderBrand.lime500)
                    .frame(width: 40, height: 40)
                    .background(LadderBrand.lime500.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Pending Transfer Requests")
                        .font(.ladderLabel(15))
                        .foregroundStyle(LadderBrand.cream100)

                    Text("0 awaiting review")
                        .font(.ladderBody(13))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.35))
            }
            .padding(18)
            .background(LadderBrand.forest900.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LadderBrand.cream100.opacity(0.1), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
