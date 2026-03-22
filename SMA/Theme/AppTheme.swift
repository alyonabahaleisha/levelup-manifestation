import SwiftUI

// MARK: - Life Areas

enum LifeArea: String, CaseIterable, Codable {
    case money, confidence, love, calm, career
    case feminineEnergy, relationships, selfWorth, fear, body
    
    var label: String {
        switch self {
        case .money: return "Money"
        case .confidence: return "Confidence"
        case .love: return "Love"
        case .calm: return "Calm"
        case .career: return "Career"
        case .feminineEnergy: return "Feminine Energy"
        case .relationships: return "Relationships"
        case .selfWorth: return "Self-Worth"
        case .fear: return "Fear"
        case .body: return "Body"
        }
    }
    
    var emoji: String {
        switch self {
        case .money: return "💰"
        case .confidence: return "✨"
        case .love: return "🌹"
        case .calm: return "🌊"
        case .career: return "🚀"
        case .feminineEnergy: return "🌸"
        case .relationships: return "💞"
        case .selfWorth: return "👑"
        case .fear: return "🦋"
        case .body: return "🌿"
        }
    }
}

// MARK: - Theme Mode

enum ThemeMode: String {
    case teal, ethereal
}

// MARK: - Tone Theme

struct ToneTheme {
    let accent: Color
    let glowColor: Color
    let surface: Color
    let surfaceBorder: Color
    
    static let `default` = ToneTheme(
        accent: Color(hex: "B88AAE"),
        glowColor: Color(hex: "B88AAE").opacity(0.25),
        surface: Color.white.opacity(0.55),
        surfaceBorder: Color.white.opacity(0.70)
    )
}

// MARK: - Area Colors

func areaColor(_ area: LifeArea) -> Color {
    switch area {
    case .money: return Color(hex: "FFD966")
    case .confidence: return Color(hex: "FFE566")
    case .love: return Color(hex: "FF7A9A")
    case .calm: return Color(hex: "7EC8E3")
    case .career: return Color(hex: "FFB347")
    case .feminineEnergy: return Color(hex: "FFB3DE")
    case .relationships: return Color(hex: "FF9AAF")
    case .selfWorth: return Color(hex: "B39DFF")
    case .fear: return Color(hex: "80D4FF")
    case .body: return Color(hex: "7FFFD4")
    }
}

// MARK: - Environment

private struct ThemeModeKey: EnvironmentKey {
    static let defaultValue: ThemeMode = .teal
}

extension EnvironmentValues {
    var themeMode: ThemeMode {
        get { self[ThemeModeKey.self] }
        set { self[ThemeModeKey.self] = newValue }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        r = Double((int >> 16) & 0xFF) / 255.0
        g = Double((int >> 8) & 0xFF) / 255.0
        b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
