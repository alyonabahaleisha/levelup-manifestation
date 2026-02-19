import SwiftUI

// ANDROID: MainTabScreen.kt
//   var selectedTab by remember { mutableStateOf(AppTab.Affirmations) }
//   var showSettings by remember { mutableStateOf(false) }
//   Box(Modifier.fillMaxSize()) {
//       AnimatedContent(selectedTab) { tab ->
//           when (tab) {
//               AppTab.Affirmations -> AffirmationsScreen()
//               AppTab.Reprogram -> ReprogramScreen()
//           }
//       }
//       GlassTabBar(selectedTab, onTabChange = { selectedTab = it },
//                  onSettings = { showSettings = true },
//                  modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 36.dp))
//   }
//   if (showSettings) SettingsBottomSheet(onDismiss = { showSettings = false })
//   Status bar: WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false

struct MainTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedTab: AppTab = .affirmations
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full screen content
            // ANDROID: AnimatedContent(selectedTab, transitionSpec = { fadeIn() with fadeOut() })
            ZStack {
                switch selectedTab {
                case .affirmations:
                    AffirmationsFeedView()
                        .transition(.opacity)
                case .reprogram:
                    ReprogramView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // Glass tab bar — bottom center
            // ANDROID: GlassTabBar composable with same layout — see SideTabBar.swift comments
            SideTabBar(selectedTab: $selectedTab, onSettings: { showSettings = true })
                .padding(.bottom, 36)
        }
        .ignoresSafeArea()
        // ANDROID: SideEffect { WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false }
        .statusBarStyle(.lightContent)
        // ANDROID: if (showSettings) ModalBottomSheet(onDismissRequest = { showSettings = false }) { SettingsScreen() }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
