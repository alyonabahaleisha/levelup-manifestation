import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeViewModel: ThemeViewModel
    @Environment(\.themeMode) var currentMode
    
    var body: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(Translations.ui("settingsTitle"))
                        .font(AppTypography.headingLarge)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .padding(.horizontal, 24)
                    
                    // Notifications section
                    settingsSection(title: Translations.ui("notificationsSection")) {
                        Text("Уведомления скоро будут доступны")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.white.opacity(0.55))
                            .padding(16)
                    }
                    
                    // Theme mode section
                    settingsSection(title: "ОФОРМЛЕНИЕ") {
                        VStack(spacing: 8) {
                            themeRow("Классический", mode: .teal)
                            themeRow("Атмосферный", mode: .ethereal)
                        }
                        .padding(16)
                    }
                    
                    Spacer().frame(height: 60)
                }
            }
        }
    }
    
    private func themeRow(_ label: String, mode: ThemeMode) -> some View {
        HStack {
            Text(label)
                .font(AppTypography.bodyLarge)
                .foregroundColor(.white)
            Spacer()
            if currentMode == mode {
                Image(systemName: "checkmark")
                    .foregroundColor(ToneTheme.default.accent)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            themeViewModel.setThemeMode(mode)
        }
    }
    
    private func settingsSection(title: String, @ViewBuilder content: @escaping () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTypography.labelSmall)
                .foregroundColor(.white.opacity(0.55))
                .padding(.horizontal, 24)
            
            GlassCard(cornerRadius: 22) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
        }
    }
}
