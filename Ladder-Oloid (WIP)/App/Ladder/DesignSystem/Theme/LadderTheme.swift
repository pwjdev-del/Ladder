import SwiftUI

// MARK: - Ladder Theme Manager
// Controls app-wide appearance (light/dark/system)

@Observable
final class LadderTheme {

    enum Appearance: String, CaseIterable {
        case system
        case light
        case dark
    }

    var appearance: Appearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "ladder_appearance")
        }
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "ladder_appearance") ?? "system"
        self.appearance = Appearance(rawValue: stored) ?? .system
    }
}
