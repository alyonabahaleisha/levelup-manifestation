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
                onNavigateToAffirmations: { selectedTab = 1 },
                onNavigateToReprogram: { selectedTab = 3 },
                onNavigateToMeditations: { selectedTab = 2 }
            )
            .tabItem {
                Image(systemName: "heart")
                Text(Translations.ui("homeTab"))
            }
            .tag(0)
            
            AffirmationsView()
                .tabItem {
                    Image(systemName: "quote.closing")
                    Text(Translations.ui("affirmationsTab"))
                }
                .tag(1)
            
            MeditationsView(viewModel: meditationVM)
                .tabItem {
                    Image(systemName: "headphones")
                    Text(Translations.ui("meditationsTab"))
                }
                .tag(2)
            
            ReprogramView(savedProgramsVM: savedProgramsVM)
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text(Translations.ui("reprogramTab"))
                }
                .tag(3)
            
            SettingsView(themeViewModel: themeViewModel)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text(Translations.ui("settingsTitle"))
                }
                .tag(4)
        }
        .tint(ToneTheme.default.accent)
    }
}
