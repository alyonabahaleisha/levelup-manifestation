import Foundation

struct Affirmation: Identifiable, Codable {
    var id: String = UUID().uuidString
    let text: String
    let area: LifeArea
    var isPersonal: Bool = false
}

struct HiddenProgram: Identifiable {
    var id: String = UUID().uuidString
    let limiting: String
    let rewrite: String
    let area: LifeArea
}

struct Meditation: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let area: LifeArea
    let fileName: String
    let durationSeconds: Int
}

struct MusicTrack: Identifiable {
    let id: String
    let title: String
    let artist: String
    let fileName: String
    let durationSeconds: Int
}

struct Club: Identifiable {
    let id: String
    let country: String
    let city: String
    let region: String
    let leaderName: String
    let telegramUrl: String
    let latitude: Double
    let longitude: Double
}
