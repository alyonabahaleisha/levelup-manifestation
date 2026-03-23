import Foundation

enum MeditationContent {
    private static let releaseBase = "https://github.com/alyonabahaleisha/levelup-manifestation-android/releases/download/v1.0.0-meditations"
    
    static func meditations(_ area: LifeArea) -> [Meditation] {
        Translations.meditationData(area).map { raw in
            Meditation(id: raw.id, title: raw.title, description: raw.description, area: area, fileName: raw.fileName, durationSeconds: raw.durationSeconds)
        }
    }
    
    static func allMeditations() -> [Meditation] {
        LifeArea.allCases.flatMap { meditations($0) }
    }
    
    static func audioURL(_ meditation: Meditation) -> String {
        "\(releaseBase)/\(meditation.fileName)"
    }
}
