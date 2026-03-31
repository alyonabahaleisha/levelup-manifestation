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

    static func popularMeditations() -> [Meditation] {
        Translations.popularMeditations().map { raw in
            let area = LifeArea.allCases.first { a in
                Translations.meditationData(a).contains { $0.id == raw.id }
            } ?? .money
            return Meditation(id: raw.id, title: raw.title, description: raw.description, area: area, fileName: raw.fileName, durationSeconds: raw.durationSeconds)
        }
    }

    static func audioURL(_ meditation: Meditation) -> String {
        // Use Firestore audioUrl if available, fall back to GitHub Releases
        if let raw = Translations.meditationData(meditation.area).first(where: { $0.id == meditation.id }),
           !raw.audioUrl.isEmpty {
            return raw.audioUrl
        }
        return "\(releaseBase)/\(meditation.fileName)"
    }

    static func coverURL(_ meditation: Meditation) -> String? {
        guard let raw = Translations.meditationData(meditation.area).first(where: { $0.id == meditation.id }),
              !raw.coverUrl.isEmpty else { return nil }
        return raw.coverUrl
    }

    static func coverColor(_ meditation: Meditation) -> String? {
        guard let raw = Translations.meditationData(meditation.area).first(where: { $0.id == meditation.id }),
              !raw.coverColor.isEmpty else { return nil }
        return raw.coverColor
    }
}
