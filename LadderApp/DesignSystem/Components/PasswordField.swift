import SwiftUI

// Press-and-hold to reveal password. Release → masks again.
// Used everywhere a password is typed: B2CLogin, SchoolLogin, FounderLogin,
// B2CSignup, ParentalCoSign.
//
// The eye button is NOT a toggle. Tap is treated as "peek for 1.2s then
// re-mask"; long-press holds the reveal as long as the user keeps pressing.

public struct PasswordField: View {
    public let label: String
    public let icon: String
    public let placeholder: String
    @Binding public var text: String
    public var onDarkSurface: Bool = false

    @State private var isRevealed = false
    @FocusState private var focused: Bool

    public init(label: String,
                icon: String = "lock",
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
                        TextField(placeholder, text: $text)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(placeholder, text: $text)
                            .textContentType(.password)
                    }
                }
                .font(.ladderBody(15))
                .focused($focused)
                .foregroundStyle(textColor)
                .tint(LadderBrand.lime500)

                revealButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(fillColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? LadderBrand.lime500 : Color.clear, lineWidth: 1.5)
            )
        }
    }

    // MARK: - Eye button with press-and-hold semantics

    @State private var tapPeekTask: Task<Void, Never>?

    private var revealButton: some View {
        Image(systemName: isRevealed ? "eye.fill" : "eye.slash.fill")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(isRevealed ? LadderBrand.lime500 : iconColor)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .simultaneousGesture(
                // Long-press: reveal only while held.
                LongPressGesture(minimumDuration: 0.12)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onChanged { value in
                        switch value {
                        case .first: break
                        case .second(true, _):
                            if !isRevealed {
                                tapPeekTask?.cancel()
                                withAnimation(.easeInOut(duration: 0.12)) { isRevealed = true }
                            }
                        default: break
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.12)) { isRevealed = false }
                    }
            )
            .simultaneousGesture(
                // Tap: brief 1.2s peek, then auto-mask.
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
            .accessibilityLabel("Show password")
            .accessibilityHint("Press and hold to reveal, release to hide. Tap for a 1-second peek.")
    }

    // MARK: - Colors (swap for dark-surface / light-surface usage)

    private var labelColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.8) : LadderBrand.ink600
    }

    private var iconColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.7) : LadderBrand.ink600
    }

    private var textColor: Color {
        onDarkSurface ? LadderBrand.cream100 : LadderBrand.ink900
    }

    private var fillColor: Color {
        onDarkSurface ? LadderBrand.cream100.opacity(0.12) : LadderBrand.stone200
    }
}

// MARK: - Matching GradientInputField (for text fields on dark backgrounds)

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
                .font(.ladderCaps(11))
                .tracking(1.1)
                .foregroundStyle(onDarkSurface ? LadderBrand.cream100.opacity(0.8) : LadderBrand.ink600)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(onDarkSurface ? LadderBrand.cream100.opacity(0.7) : LadderBrand.ink600)
                TextField(placeholder, text: $text)
                    .font(mono ? .ladderBody(15).monospaced() : .ladderBody(15))
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(capitalization)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .foregroundStyle(onDarkSurface ? LadderBrand.cream100 : LadderBrand.ink900)
                    .tint(LadderBrand.lime500)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(onDarkSurface ? LadderBrand.cream100.opacity(0.12) : LadderBrand.stone200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? LadderBrand.lime500 : Color.clear, lineWidth: 1.5)
            )
        }
    }
}
