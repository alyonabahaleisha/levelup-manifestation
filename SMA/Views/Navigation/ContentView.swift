import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var savedProgramsVM = SavedProgramsViewModel()
    @StateObject private var meditationVM = MeditationViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                savedProgramsVM: savedProgramsVM,
                meditationVM: meditationVM,
                onNavigateToReprogram: { selectedTab = 2 },
                onNavigateToMeditations: { selectedTab = 1 }
            )
            .tabItem {
                Image(systemName: "heart")
                Text(Translations.ui("homeTab"))
            }
            .tag(0)

            MeditationsView(viewModel: meditationVM)
                .tabItem {
                    Image(systemName: "headphones")
                    Text(Translations.ui("meditationsTab"))
                }
                .tag(1)

            ReprogramView(savedProgramsVM: savedProgramsVM)
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text(Translations.ui("reprogramTab"))
                }
                .tag(2)

            SettingsView(themeViewModel: themeViewModel)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text(Translations.ui("settingsTitle"))
                }
                .tag(3)
        }
        .tint(ToneTheme.default.accent)
        .statusBarHidden(true)
    }
}
