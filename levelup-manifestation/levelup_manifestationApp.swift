import SwiftUI

@main
struct levelup_manifestationApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var savedPrograms = SavedProgramsStore()
    @StateObject private var notifications = NotificationManager()

    init() {
        // Set UIWindow background to dark purple so the gap between
        // system launch screen and first SwiftUI frame is never white
        UIView.appearance(whenContainedInInstancesOf: [UIWindow.self]).backgroundColor =
            UIColor(red: 0.14, green: 0.05, blue: 0.14, alpha: 1)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(savedPrograms)
                .environmentObject(notifications)
        }
    }
}
