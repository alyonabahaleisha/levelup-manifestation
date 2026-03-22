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

struct Meditation: Identifiable {
    let id: String
    let title: String
    let area: LifeArea
    let fileName: String
    let durationSeconds: Int
}
