import SwiftUI

// MARK: - Life Area
// ANDROID: enum class LifeArea(val label: String, val emoji: String)
//   Port all 10 cases directly — same raw values, same emoji

enum LifeArea: String, CaseIterable, Identifiable {
    case money = "Money"
    case confidence = "Confidence"
    case love = "Love"
    case calm = "Calm"
    case career = "Career"
    case feminineEnergy = "Feminine Energy"
    case relationships = "Relationships"
    case selfWorth = "Self-Worth"
    case fear = "Fear"
    case body = "Body"

    var id: String { rawValue }

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

// MARK: - Tone Theme
// ANDROID: enum class ToneTheme(val label: String) with:
//   val gradientColors: List<Color>  (same RGB values as Long hex e.g. 0xFF240D24)
//   val accent: Color
//   val glowColor: Color
//   Store selected tone in DataStore: dataStore.edit { it[TONE_KEY] = tone.name }

enum ToneTheme: String, CaseIterable, Identifiable {
    case softFeminine = "Soft Feminine"
    case ceoPowerful = "CEO Powerful"
    case calmSpiritual = "Calm Spiritual"

    var id: String { rawValue }

    // ANDROID: Brush.linearGradient(colors = listOf(...)) with same RGB values as 0xFFRRGGBB
    var gradient: [Color] {
        switch self {
        case .softFeminine:
            return [
                Color(red: 0.14, green: 0.05, blue: 0.14),
                Color(red: 0.20, green: 0.07, blue: 0.18),
                Color(red: 0.09, green: 0.03, blue: 0.09)
            ]
        case .ceoPowerful:
            return [
                Color(red: 0.06, green: 0.05, blue: 0.04),
                Color(red: 0.12, green: 0.09, blue: 0.02),
                Color(red: 0.04, green: 0.03, blue: 0.02)
            ]
        case .calmSpiritual:
            return [
                Color(red: 0.05, green: 0.04, blue: 0.18),
                Color(red: 0.08, green: 0.04, blue: 0.22),
                Color(red: 0.03, green: 0.04, blue: 0.12)
            ]
        }
    }

    // ANDROID: accent: Color (same value as 0xFFRRGGBB hex)
    var accent: Color {
        switch self {
        case .softFeminine: return Color(red: 0.92, green: 0.68, blue: 0.75)
        case .ceoPowerful: return Color(red: 0.84, green: 0.70, blue: 0.38)
        case .calmSpiritual: return Color(red: 0.62, green: 0.56, blue: 0.96)
        }
    }

    // ANDROID: glowColor = accent.copy(alpha = 0.25f)
    var glowColor: Color {
        switch self {
        case .softFeminine: return Color(red: 0.92, green: 0.68, blue: 0.75).opacity(0.25)
        case .ceoPowerful: return Color(red: 0.84, green: 0.70, blue: 0.38).opacity(0.25)
        case .calmSpiritual: return Color(red: 0.62, green: 0.56, blue: 0.96).opacity(0.25)
        }
    }
}

// MARK: - App Tab
// ANDROID: sealed class AppTab { object Affirmations; object Reprogram }

enum AppTab {
    case affirmations
    case reprogram
}

// MARK: - Pressable Button Style
// ANDROID: Custom Modifier — fun Modifier.pressable(scale: Float = 0.96f): Modifier
//   Use interactionSource + collectIsPressedAsState()
//   graphicsLayer { scaleX = if (pressed) scale else 1f; scaleY = ... }
//   animate with spring(stiffness = Spring.StiffnessMediumLow)

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func pressable(scale: CGFloat = 0.96) -> some View {
        self.buttonStyle(PressableButtonStyle(scale: scale))
    }
}

// MARK: - Glass Modifiers
// ANDROID: @Composable fun GlassCard(cornerRadius: Dp = 24.dp, content: @Composable () -> Unit)
//   Box(Modifier
//     .clip(RoundedCornerShape(cornerRadius))
//     .background(Color.White.copy(alpha = 0.07f))  // replaces ultraThinMaterial
//     .border(1.dp, Color.White.copy(alpha = 0.13f), RoundedCornerShape(cornerRadius))
//   ) { content() }
//
// ANDROID: @Composable fun GlassChip(isSelected: Boolean, accentColor: Color, content: @Composable () -> Unit)
//   Box(Modifier
//     .clip(CircleShape)  // Capsule
//     .background(if (isSelected) accentColor.copy(0.18f) else Color.White.copy(0.06f))
//     .border(1.dp, if (isSelected) accentColor.copy(0.6f) else Color.White.copy(0.14f), CircleShape)
//   ) { content() }

extension View {
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
            )
    }

    func glassChip(isSelected: Bool = false, accentColor: Color = .white) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(isSelected ? accentColor.opacity(0.18) : Color.white.opacity(0.06))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? accentColor.opacity(0.6) : Color.white.opacity(0.14), lineWidth: 1)
            )
    }

}
