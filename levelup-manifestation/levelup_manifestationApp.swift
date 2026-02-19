import SwiftUI

// ANDROID: Entry point → MainActivity.kt extending ComponentActivity
//   setContent { LevelUpTheme { RootScreen() } }
//   @StateObject x3 → 3 ViewModels injected via Hilt:
//     @HiltViewModel ThemeViewModel, SavedProgramsViewModel, NotificationViewModel
//   UIWindow background → android:windowBackground in themes.xml (dark purple color)

@main
struct levelup_manifestationApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var savedPrograms = SavedProgramsStore()
    @StateObject private var notifications = NotificationManager()

    init() {
        // Set UIWindow background to dark purple so the gap between
        // system launch screen and first SwiftUI frame is never white
        // ANDROID: Set android:windowBackground="#240D24" in res/values/themes.xml
        UIView.appearance(whenContainedInInstancesOf: [UIWindow.self]).backgroundColor =
            UIColor(red: 0.14, green: 0.05, blue: 0.14, alpha: 1)
    }

    var body: some Scene {
        // ANDROID: WindowGroup → single Activity with Compose setContent {}
        //   Provide ViewModels via hiltViewModel() at root composable
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(savedPrograms)
                .environmentObject(notifications)
        }
    }
}
