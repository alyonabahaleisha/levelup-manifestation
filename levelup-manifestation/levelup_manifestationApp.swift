import SwiftUI

@main
struct levelup_manifestationApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var savedPrograms = SavedProgramsStore()
    @StateObject private var notifications = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(savedPrograms)
                .environmentObject(notifications)
        }
    }
}
