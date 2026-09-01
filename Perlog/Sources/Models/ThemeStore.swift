import SwiftUI
import Combine

/// The five theme presets shown in Theme Studio.
enum ThemePreset: String, Codable, CaseIterable, Identifiable {
    case black, grey, white, iridescent, custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .black: return "Black"
        case .grey: return "Grey"
        case .white: return "White"
        case .iridescent: return "Iridescent"
        case .custom: return "Custom"
        }
    }

    var subtitle: String {
        switch self {
        case .black: return "Deep glass, true black background"
        case .grey: return "Soft charcoal glass"
        case .white: return "Bright glass, light background"
        case .iridescent: return "Color shifts by record type"
        case .custom: return "Pick your own base hue"
        }
    }
}

/// Central theme state for the whole app. Plain `ObservableObject` +
/// `@Published` rather than the `@Observable` macro — this is injected
/// with `@StateObject` at the app root and read with `@EnvironmentObject`
/// everywhere else, which keeps the property-wrapper story simple and
/// avoids macro/environment key mismatches.
final class ThemeStore: ObservableObject {
    @Published var preset: ThemePreset {
        didSet { persist() }
    }
    @Published var customHue: Double {
        didSet { persist() }
    }

    private let presetKey = "perlog.theme.preset"
    private let hueKey = "perlog.theme.customHue"

    init() {
        let store = UserDefaults.standard
        if let raw = store.string(forKey: presetKey), let saved = ThemePreset(rawValue: raw) {
            self.preset = saved
        } else {
            self.preset = .black
        }
        let savedHue = store.double(forKey: hueKey)
        self.customHue = savedHue > 0 ? savedHue : 0.62
    }

    private func persist() {
        let store = UserDefaults.standard
        store.set(preset.rawValue, forKey: presetKey)
        store.set(customHue, forKey: hueKey)
    }

    /// Background color for full-screen surfaces.
    var background: Color {
        switch preset {
        case .black: return Color.black
        case .grey: return Color(red: 0.09, green: 0.09, blue: 0.10)
        case .white: return Color(red: 0.96, green: 0.96, blue: 0.97)
        case .iridescent: return Color.black
        case .custom: return Color(hue: customHue, saturation: 0.35, brightness: 0.08)
        }
    }

    /// The color scheme this theme wants to run in.
    var colorScheme: ColorScheme {
        preset == .white ? .light : .dark
    }

    /// Primary accent used for buttons, selection states, progress rings.
    var accent: Color {
        switch preset {
        case .black: return Color.blue
        case .grey: return Color(red: 0.68, green: 0.70, blue: 0.75)
        case .white: return Color.blue
        case .iridescent: return Color(hue: customHue, saturation: 0.75, brightness: 0.95)
        case .custom: return Color(hue: customHue, saturation: 0.75, brightness: 0.95)
        }
    }

    /// Tint used for a specific entry-type badge. In Iridescent mode
    /// every record type gets its own hue; otherwise everything shares
    /// the single accent color, which keeps Black/Grey/White/Custom calm.
    func tint(for type: EntryType) -> Color {
        switch preset {
        case .iridescent:
            return Color(hue: type.baseHue, saturation: 0.7, brightness: 0.95)
        default:
            return accent
        }
    }

    /// The frosted-glass material used behind cards and sheets.
    var glassMaterial: Material {
        preset == .white ? .thinMaterial : .ultraThinMaterial
    }

    var cardStroke: Color {
        preset == .white ? Color.black.opacity(0.08) : Color.white.opacity(0.12)
    }

    var primaryText: Color {
        preset == .white ? Color.black : Color.white
    }

    var secondaryText: Color {
        preset == .white ? Color.black.opacity(0.55) : Color.white.opacity(0.55)
    }
}
