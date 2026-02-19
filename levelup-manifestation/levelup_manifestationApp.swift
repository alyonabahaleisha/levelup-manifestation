import SwiftUI

@main
struct levelup_manifestationApp: App {
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
        }
    }
}
