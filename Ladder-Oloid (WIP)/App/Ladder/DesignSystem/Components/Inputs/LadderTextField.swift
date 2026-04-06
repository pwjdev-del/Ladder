import SwiftUI

// MARK: - Minimalist Text Field
// No bounding box. Single bottom-border at 40% opacity. Focus = primary color line.

struct LadderTextField: View {
    let placeholder: String
    let icon: String?
    @Binding var text: String
    @FocusState private var isFocused: Bool

    init(_ placeholder: String, text: Binding<String>, icon: String? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: LadderSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isFocused ? LadderColors.primary : LadderColors.onSurfaceVariant)
                }

                TextField(placeholder, text: $text)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .focused($isFocused)
            }
            .padding(.vertical, LadderSpacing.md)

            Rectangle()
                .fill(isFocused ? LadderColors.primary : LadderColors.outlineVariant.opacity(0.4))
                .frame(height: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Secure Field variant

struct LadderSecureField: View {
    let placeholder: String
    let icon: String?
    @Binding var text: String
    @State private var isVisible = false
    @FocusState private var isFocused: Bool

    init(_ placeholder: String, text: Binding<String>, icon: String? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: LadderSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isFocused ? LadderColors.primary : LadderColors.onSurfaceVariant)
                }

                Group {
                    if isVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurface)
                .focused($isFocused)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .padding(.vertical, LadderSpacing.md)

            Rectangle()
                .fill(isFocused ? LadderColors.primary : LadderColors.outlineVariant.opacity(0.4))
                .frame(height: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Search Bar (pill-shaped)

struct LadderSearchBar: View {
    let placeholder: String
    @Binding var text: String
    var onFilter: (() -> Void)?
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.onSurfaceVariant)

            TextField(placeholder, text: $text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .focused($isFocused)

            if let onFilter {
                Button(action: onFilter) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(LadderColors.primary)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerLow.opacity(0.3))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 24) {
        LadderTextField("Email address", text: .constant(""), icon: "envelope")
        LadderSecureField("Password", text: .constant(""), icon: "lock")
        LadderSearchBar(placeholder: "Search colleges...", text: .constant(""), onFilter: {})
    }
    .padding(24)
    .background(LadderColors.surface)
}
