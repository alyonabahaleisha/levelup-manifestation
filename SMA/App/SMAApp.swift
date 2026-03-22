import SwiftUI

@main
struct SMAApp: App {
    @StateObject private var themeViewModel = ThemeViewModel()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environment(\.themeMode, themeViewModel.themeMode)
                        .environmentObject(themeViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                Translations.shared.load()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    showSplash = false
                }
            }
        }
    }
}
