import SwiftUI

// Password input with a VERY obvious text box + press-and-hold reveal.
// Fix for reported issue: "I don't see any passwords. Can you give me the
// password space?" — previous variant used cream-at-12% fill which was
// almost invisible against the forest gradient. New variant uses:
//  - cream-at-22% fill (clearly distinct from the background)
//  - persistent lime 1pt hairline stroke so the box edge is always visible
//  - focused state bumps to lime 2pt with a soft glow
//  - "Show" / "Hide" text label next to the eye so the button's purpose
//    can't be missed
//  - press-and-hold on the eye reveals while held; release re-masks.
//    Tap = 1.2s peek.

public struct PasswordField: View {
    public let label: String
    public let icon: String
    public let placeholder: String
    @Binding public var text: String
    public var onDarkSurface: Bool = false

    @State private var isRevealed = false
    @FocusState private var focused: Bool
    @State private var tapPeekTask: Task<Void, Never>?

    public init(label: String,
                icon: String = "lock.fill",
                placeholder: String = "••••••••",
                text: Binding<String>,
                onDarkSurface: Bool = false) {
        self.label = label
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.onDarkSurface = onDarkSurface
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ladderCaps(11))
                .tracking(1.1)
                .foregroundStyle(labelColor)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)

                Group {
                    if isRevealed {
                        TextField("", text: $text,
                                  prompt: Text(placeholder).foregroundColor(placeholderColor))
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("", text: $text,
                                    prompt: Text(placeholder).foregroundColor(placeholderColor))
                            .textContentType(.password)
                    }
                }
                .font(.ladderBody(16))
                .focused($focused)
                .foregroundStyle(textColor)
                .tint(LadderBrand.lime500)

                revealButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(fillColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: focused ? 2 : 1)
            )
            .shadow(color: focused ? LadderBrand.lime500.opacity(0.25) : .clear,
                    radius: focused ? 8 : 0, y: 0)
            .animation(.easeOut(duration: 0.15), value: focused)
        }
    }

    // MARK: - Eye button: tap for peek, hold to keep revealed

    private var revealButton: some View {
        HStack(spacing: 4) {
            Image(systemName: isRevealed ? "eye.fill" : "eye.slash.fill")
                .font(.system(size: 16, weight: .semibold))
            Text(isRevealed ? "Hide" : "Show")
                .font(.ladderCaps(11))
                .tracking(1.0)
        }
        .foregroundStyle(isRevealed ? LadderBrand.lime500 : revealButtonColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isRevealed ? LadderBrand.lime500.opacity(0.22) : revealButtonBg)
        .overlay(
            Capsule().stroke(isRevealed ? LadderBrand.lime500.opacity(0.8) : revealButtonBorder,
                             lineWidth: 1)
        )
        .clipShape(Capsule())
        .contentShape(Rectangle())
        .gesture(
            // Long-press: reveal while held; release to re-mask.
            LongPressGesture(minimumDuration: 0.15)
                .sequenced(before: DragGesture(minimumDistance: 0))
                .onChanged { value in
                    if case .second(true, _) = value {
                        if !isRevealed {
                            tapPeekTask?.cancel()
                            withAnimation(.easeInOut(duration: 0.12)) { isRevealed = true }
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.12)) { isRevealed = false }
                }
        )
        .simultaneousGesture(
            // Tap: 1.2s peek then auto-mask.
            TapGesture().onEnded {
                tapPeekTask?.cancel()
                withAnimation(.easeInOut(duration: 0.12)) { isRevealed = true }
                tapPeekTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_200_000_000)
                    if !Task.isCancelled {
                        withAnimation(.easeInOut(duration: 0.12)) { isRevealed = false }
                    }
                }
            }
        )
        .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        .accessibilityHint("Press and hold to reveal, release to hide. Tap for a 1-second peek.")
    }

    // MARK: - Colors

    private var labelColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.85) : LadderBrand.ink600
    }

    private var iconColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.8) : LadderBrand.ink600
    }

    private var textColor: Color {
        onDarkSurface ? LadderBrand.cream100 : LadderBrand.ink900
    }

    private var placeholderColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.45) : LadderBrand.ink400
    }

    private var fillColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.22) : LadderBrand.paper
    }

    private var borderColor: Color {
        if focused { return LadderBrand.lime500 }
        return onDarkSurface ? LadderBrand.cream100.opacity(0.4) : LadderBrand.ink400.opacity(0.4)
    }

    private var revealButtonColor: Color {
        onDarkSurface ? LadderBrand.cream100 : LadderBrand.ink900
    }

    private var revealButtonBg: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.18) : LadderBrand.stone200
    }

    private var revealButtonBorder: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.4) : LadderBrand.ink400.opacity(0.4)
    }
}

// MARK: - Matching GradientInputField for email / code / TOTP on dark bg

public struct GradientInputField: View {
    public let label: String
    public let icon: String
    public let placeholder: String
    @Binding public var text: String
    public var keyboard: UIKeyboardType = .default
    public var capitalization: TextInputAutocapitalization = .never
    public var mono: Bool = false
    public var onDarkSurface: Bool = true

    @FocusState private var focused: Bool

    public init(label: String,
                icon: String,
                placeholder: String,
                text: Binding<String>,
                keyboard: UIKeyboardType = .default,
                capitalization: TextInputAutocapitalization = .never,
                mono: Bool = false,
                onDarkSurface: Bool = true) {
        self.label = label
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.keyboard = keyboard
        self.capitalization = capitalization
        self.mono = mono
        self.onDarkSurface = onDarkSurface
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ladderCaps(11)).tracking(1.1)
                .foregroundStyle(onDarkSurface ? LadderBrand.cream100.opacity(0.85) : LadderBrand.ink600)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(onDarkSurface ? LadderBrand.cream100.opacity(0.8) : LadderBrand.ink600)
                TextField("", text: $text,
                          prompt: Text(placeholder)
                            .foregroundColor(onDarkSurface ? LadderBrand.cream100.opacity(0.45) : LadderBrand.ink400))
                    .font(mono ? .ladderBody(16).monospaced() : .ladderBody(16))
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(capitalization)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .foregroundStyle(onDarkSurface ? LadderBrand.cream100 : LadderBrand.ink900)
                    .tint(LadderBrand.lime500)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(onDarkSurface ? LadderBrand.cream100.opacity(0.22) : LadderBrand.paper)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: focused ? 2 : 1)
            )
            .shadow(color: focused ? LadderBrand.lime500.opacity(0.25) : .clear,
                    radius: focused ? 8 : 0, y: 0)
            .animation(.easeOut(duration: 0.15), value: focused)
        }
    }

    private var borderColor: Color {
        if focused { return LadderBrand.lime500 }
        return onDarkSurface ? LadderBrand.cream100.opacity(0.4) : LadderBrand.ink400.opacity(0.4)
    }
}
