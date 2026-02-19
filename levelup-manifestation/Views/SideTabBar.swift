import SwiftUI

// ANDROID: GlassTabBar.kt
//   Row(Modifier.clip(CircleShape).background(Color.Black.copy(0.25f))
//               .border(1.dp, Color.White.copy(0.12f), CircleShape)
//               .shadow(24.dp, CircleShape)
//               .padding(horizontal = 8.dp, vertical = 8.dp)) {
//       TabButton(tab = AppTab.Affirmations, icon = Icons.Outlined.FormatQuote, label = "Affirm")
//       TabButton(tab = AppTab.Reprogram, icon = Icons.Outlined.Refresh, label = "Reprogram")
//       Divider(Modifier.width(1.dp).height(32.dp), color = Color.White.copy(0.12f))
//       SettingsButton(onClick = onSettings)
//   }
//   TabButton: selection haptic via LocalHapticFeedback.current.performHapticFeedback(SelectionChanged)
//   Scale animation: animateFloatAsState(if selected 1.05f else 1f, spring())
//   Icon tint: if selected theme.accent else Color.White.copy(0.4f)

struct SideTabBar: View {
    @EnvironmentObject var theme: ThemeManager
    @Binding var selectedTab: AppTab
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            tabButton(tab: .affirmations, icon: "quote.bubble", label: "Affirm")
            tabButton(tab: .reprogram, icon: "arrow.clockwise.circle", label: "Reprogram")

            // Divider
            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(width: 1, height: 32)
                .padding(.horizontal, 4)

            // Settings
            Button(action: onSettings) {
                VStack(spacing: 4) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(height: 24)
                    Text("Settings")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(width: 72, height: 52)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.25))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
    }

    @ViewBuilder
    private func tabButton(tab: AppTab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        Button {
            let impact = UISelectionFeedbackGenerator()
            impact.selectionChanged()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .light))
                    .foregroundStyle(isSelected ? theme.tone.accent : .white.opacity(0.4))
                    .frame(height: 24)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? theme.tone.accent : .white.opacity(0.4))
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
            .frame(width: 88, height: 52)
            .background(
                Capsule()
                    .fill(isSelected ? theme.tone.accent.opacity(0.14) : Color.clear)
                    .padding(.horizontal, 4)
            )
        }
    }
}
