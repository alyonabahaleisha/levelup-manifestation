import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var savedProgramsVM = SavedProgramsViewModel()
    @StateObject private var meditationVM = MeditationViewModel()
    @StateObject private var musicVM = MusicViewModel()
    @State private var selectedTab = 0
    @State private var pendingMoodKey: String? = nil
    @State private var pendingMeditation: Meditation? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                savedProgramsVM: savedProgramsVM,
                meditationVM: meditationVM,
                onNavigateToReprogram: { selectedTab = 3 },
                onNavigateToMeditations: { selectedTab = 1 },
                onMeditationTapped: { meditation in
                    pendingMeditation = meditation
                    selectedTab = 1
                },
                onMoodBubbleTapped: { moodKey in
                    pendingMoodKey = moodKey
                    selectedTab = 1
                }
            )
            .tabItem {
                Image(systemName: "heart")
                Text(Translations.ui("homeTab"))
            }
            .tag(0)

            MeditationsView(viewModel: meditationVM, initialMoodKey: pendingMoodKey, pendingMeditation: $pendingMeditation, onNavigateToHome: { selectedTab = 0 })
                .tabItem {
                    Image(systemName: "headphones")
                    Text(Translations.ui("meditationsTab"))
                }
                .tag(1)

            MusicView(viewModel: musicVM)
                .tabItem {
                    Image(systemName: "music.note")
                    Text(Translations.ui("musicTab"))
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
        .statusBarHidden(true)
        .onChange(of: selectedTab) { _, newTab in
            if newTab != 1 {
                pendingMoodKey = nil
                pendingMeditation = nil
            }
        }
    }
}
