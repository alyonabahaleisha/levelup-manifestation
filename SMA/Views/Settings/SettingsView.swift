import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeViewModel: ThemeViewModel
    @Environment(\.themeMode) var currentMode
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("bg_home")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
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
                            .foregroundColor(Color(hex: "5A5070"))
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
                .foregroundColor(Color(hex: "2A2A3A"))
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
                .foregroundColor(Color(hex: "5A5070"))
                .padding(.horizontal, 24)
            
            GlassCard(cornerRadius: 22) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
        }
    }
}
