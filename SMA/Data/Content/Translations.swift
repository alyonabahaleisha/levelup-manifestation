import Foundation

class Translations: @unchecked Sendable {
    static let shared = Translations()
    
    private var lang: [String: Any] = [:]
    private var loaded = false
    
    func load() {
        guard !loaded else { return }
        guard let url = Bundle.main.url(forResource: "translations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let ru = json["ru"] as? [String: Any] else { return }
        lang = ru
        loaded = true
    }
    
    static func ui(_ key: String) -> String {
        guard let ui = shared.lang["ui"] as? [String: String] else { return key }
        return ui[key] ?? key
    }
    
    static func lifeAreaLabel(_ area: LifeArea) -> String {
        let key = area.rawValue
        guard let areas = shared.lang["lifeAreas"] as? [String: String] else { return area.label }
        return areas[key] ?? area.label
    }
    
    static func affirmationStrings(_ area: LifeArea) -> [String] {
        let key = area.rawValue
        guard let affirmations = shared.lang["affirmations"] as? [String: [String]] else { return [] }
        return affirmations[key] ?? []
    }
    
    struct MeditationRaw {
        let id: String
        let title: String
        let fileName: String
        let durationSeconds: Int
    }
    
    static func meditationData(_ area: LifeArea) -> [MeditationRaw] {
        let key = area.rawValue
        guard let meditations = shared.lang["meditations"] as? [String: [[String: Any]]] else { return [] }
        guard let arr = meditations[key] else { return [] }
        return arr.compactMap { obj in
            guard let id = obj["id"] as? String,
                  let title = obj["title"] as? String,
                  let fileName = obj["fileName"] as? String,
                  let duration = obj["durationSeconds"] as? Int else { return nil }
            return MeditationRaw(id: id, title: title, fileName: fileName, durationSeconds: duration)
        }
    }
    
    static func programPairs(_ area: LifeArea) -> [(limiting: String, rewrite: String)] {
        let key = area.rawValue
        guard let programs = shared.lang["programs"] as? [String: [[String: String]]] else { return [] }
        guard let arr = programs[key] else { return [] }
        return arr.compactMap { obj in
            guard let limiting = obj["limiting"], let rewrite = obj["rewrite"] else { return nil }
            return (limiting: limiting, rewrite: rewrite)
        }
    }
}
