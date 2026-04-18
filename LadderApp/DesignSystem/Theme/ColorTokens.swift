import SwiftUI

// MARK: - Ladder Color Tokens
// Single source of truth for the Evergreen Ascent design system.
// Based on Material 3 semantic naming. Never use raw hex in views — always reference these tokens.

enum LadderColors {

    // MARK: - Primary

    static let primary = Color(light: hex("#42603f"), dark: hex("#a8d4a0"))
    static let primaryContainer = Color(light: hex("#5a7956"), dark: hex("#304e2e"))
    static let onPrimary = Color(light: hex("#ffffff"), dark: hex("#1a3518"))
    static let onPrimaryContainer = Color(light: hex("#e2ffda"), dark: hex("#c4f0bb"))

    // MARK: - Secondary (Lime Accent)

    static let secondary = Color(light: hex("#516600"), dark: hex("#b3d430"))
    static let secondaryFixed = Color(light: hex("#caf24d"), dark: hex("#caf24d"))
    static let secondaryFixedDim = Color(light: hex("#afd531"), dark: hex("#afd531"))
    static let onSecondaryFixed = Color(light: hex("#161e00"), dark: hex("#161e00"))
    static let accentLime = Color(light: hex("#A1C621"), dark: hex("#A1C621"))

    // MARK: - Tertiary

    static let tertiary = Color(light: hex("#725232"), dark: hex("#ddbfa0"))
    static let tertiaryContainer = Color(light: hex("#8d6a48"), dark: hex("#594030"))
    static let tertiaryFixed = Color(light: hex("#ffdcbd"), dark: hex("#ffdcbd"))

    // MARK: - Surface Hierarchy

    static let surface = Color(light: hex("#fff8f2"), dark: hex("#1f1b15"))
    static let surfaceContainerLowest = Color(light: hex("#ffffff"), dark: hex("#1a1612"))
    static let surfaceContainerLow = Color(light: hex("#fbf2e8"), dark: hex("#252119"))
    static let surfaceContainer = Color(light: hex("#f5ede2"), dark: hex("#2a2620"))
    static let surfaceContainerHigh = Color(light: hex("#efe7dd"), dark: hex("#353027"))
    static let surfaceContainerHighest = Color(light: hex("#eae1d7"), dark: hex("#403a30"))
    static let surfaceVariant = Color(light: hex("#eae1d7"), dark: hex("#403a30"))
    static let surfaceDim = Color(light: hex("#e1d9cf"), dark: hex("#1f1b15"))
    static let surfaceBright = Color(light: hex("#fff8f2"), dark: hex("#3a342a"))

    // MARK: - On-Surface (Text)
    // IMPORTANT: Never use pure black. Always use onSurface.

    static let onSurface = Color(light: hex("#1f1b15"), dark: hex("#eae1d7"))
    static let onSurfaceVariant = Color(light: hex("#434840"), dark: hex("#c3c8be"))

    // MARK: - Outline

    static let outline = Color(light: hex("#737970"), dark: hex("#8d9385"))
    static let outlineVariant = Color(light: hex("#c3c8be"), dark: hex("#434840"))

    // MARK: - Inverse

    static let inverseSurface = Color(light: hex("#343029"), dark: hex("#eae1d7"))
    static let inverseOnSurface = Color(light: hex("#f8efe5"), dark: hex("#343029"))
    static let inversePrimary = Color(light: hex("#a8d4a0"), dark: hex("#42603f"))

    // MARK: - Error

    static let error = Color(light: hex("#ba1a1a"), dark: hex("#ffb4ab"))
    static let errorContainer = Color(light: hex("#ffdad6"), dark: hex("#93000a"))
    static let onError = Color(light: hex("#ffffff"), dark: hex("#690005"))

    // MARK: - Helpers

    private static func hex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

// MARK: - Color convenience initializer for light/dark pairs

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
