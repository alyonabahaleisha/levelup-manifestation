import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var tone: ToneTheme = .softFeminine

    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedTone"),
           let tone = ToneTheme(rawValue: saved) {
            self.tone = tone
        }
    }

    func setTone(_ newTone: ToneTheme) {
        withAnimation(.easeInOut(duration: 0.5)) {
            tone = newTone
        }
        UserDefaults.standard.set(newTone.rawValue, forKey: "selectedTone")
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: tone.gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
