import SwiftUI

class ThemeViewModel: ObservableObject {
    @AppStorage("theme_mode") private var themeModeRaw: String = "teal"
    
    var themeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRaw) ?? .teal
    }
    
    func setThemeMode(_ mode: ThemeMode) {
        themeModeRaw = mode.rawValue
        objectWillChange.send()
    }
}
