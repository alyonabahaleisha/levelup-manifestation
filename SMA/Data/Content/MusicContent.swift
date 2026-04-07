import Foundation

enum MusicContent {
    private static let releaseBase = "https://github.com/alyonabahaleisha/levelup-manifestation-android/releases/download/v1.0.0-music"

    static func allTracks() -> [MusicTrack] {
        Translations.musicData().map { raw in
            MusicTrack(id: raw.id, title: raw.title, artist: raw.artist, fileName: raw.fileName, durationSeconds: raw.durationSeconds)
        }
    }

    static func audioURL(_ track: MusicTrack) -> String {
        // Use Firestore audioUrl if available, fall back to GitHub Releases
        if let raw = Translations.musicData().first(where: { $0.id == track.id }),
           !raw.audioUrl.isEmpty {
            return raw.audioUrl
        }
        return "\(releaseBase)/\(track.fileName)"
    }
}
