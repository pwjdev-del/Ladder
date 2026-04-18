import SwiftUI

// CLAUDE.md §3 — unauthenticated landing.
// Three affordances + hidden founder trigger (press-and-hold logo ≥ 30s).
// Feedback model (Phase 4 design review):
//   0–5s    nothing
//   5s      logo desaturates ~10%
//   15s     soft haptic + faint ring 5%
//   25s     medium haptic + ring 50%
//   30s     success haptic + ring 100% → push to FounderLogin

public struct LandingView: View {
    @State private var holdProgress: Double = 0   // 0 ... 1 over 30s
    @State private var isHolding = false
    @State private var goFounderLogin = false
    @State private var goB2CLogin = false
    @State private var goSchoolPicker = false
    @State private var goB2CSignup = false
    @State private var goSchoolPartnerForm = false

    private let holdTarget: TimeInterval = 30
    @State private var holdStartedAt: Date?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                // Logo — the hidden 30s founder trigger.
                LogoHoldView(progress: holdProgress, isHolding: isHolding)
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 24)
                    .gesture(logoHoldGesture)
                    .accessibilityLabel("Ladder")
                    .accessibilityHint("Double-tap for logo")

                Text("Every kid needs a ladder to success.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)

                VStack(spacing: 16) {
                    Button {
                        goB2CLogin = true
                    } label: {
                        Text("Log in with your ID")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        goSchoolPicker = true
                    } label: {
                        Text("Sign in through your school")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor, lineWidth: 1))
                    }

                    HStack(spacing: 12) {
                        Button("Sign up as a student") { goB2CSignup = true }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button("Partner as a school") { goSchoolPartnerForm = true }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationDestination(isPresented: $goFounderLogin) { FounderLoginView() }
            .navigationDestination(isPresented: $goB2CLogin) { B2CLoginView() }
            .navigationDestination(isPresented: $goSchoolPicker) { SchoolPickerView() }
            .navigationDestination(isPresented: $goB2CSignup) { B2CSignupView() }
            .navigationDestination(isPresented: $goSchoolPartnerForm) { SchoolPartnerInquiryView() }
        }
    }

    private var logoHoldGesture: some Gesture {
        LongPressGesture(minimumDuration: holdTarget)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { _ in
                if !isHolding {
                    isHolding = true
                    holdStartedAt = Date()
                    startProgressTimer()
                }
            }
            .onEnded { _ in
                isHolding = false
                if holdProgress >= 1.0 {
                    fireFounderTrigger()
                }
                resetHold()
            }
    }

    private func startProgressTimer() {
        Task { @MainActor in
            while isHolding {
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms tick
                guard let start = holdStartedAt else { break }
                let elapsed = Date().timeIntervalSince(start)
                let newProgress = min(elapsed / holdTarget, 1.0)
                holdProgress = newProgress

                // Haptic + visual milestones per Phase 4 design review
                if elapsed >= 15, elapsed < 15.1 { softHaptic() }
                if elapsed >= 25, elapsed < 25.1 { mediumHaptic() }
                if newProgress >= 1.0 { break }
            }
        }
    }

    private func resetHold() {
        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.4)) {
                holdProgress = 0
            }
            holdStartedAt = nil
        }
    }

    private func fireFounderTrigger() {
        successHaptic()
        goFounderLogin = true
    }

    #if canImport(UIKit)
    private func softHaptic() {
        let g = UIImpactFeedbackGenerator(style: .soft); g.impactOccurred()
    }
    private func mediumHaptic() {
        let g = UIImpactFeedbackGenerator(style: .medium); g.impactOccurred()
    }
    private func successHaptic() {
        let g = UINotificationFeedbackGenerator(); g.notificationOccurred(.success)
    }
    #else
    private func softHaptic() {}
    private func mediumHaptic() {}
    private func successHaptic() {}
    #endif
}

private struct LogoHoldView: View {
    let progress: Double
    let isHolding: Bool

    var body: some View {
        ZStack {
            // Logo fills when idle; desaturates with hold
            Image(systemName: "figure.stairs")
                .resizable()
                .scaledToFit()
                .foregroundStyle(isHolding ? Color.accentColor.opacity(0.85 - progress * 0.2) : Color.accentColor)
                .padding(16)

            // Invisible until ~15s, then grows
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor.opacity(progress > 0.45 ? 0.4 : 0.05), lineWidth: 3)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: progress)
        }
    }
}
