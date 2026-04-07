import Foundation
import FirebaseFirestore

class Translations: @unchecked Sendable {
    static let shared = Translations()

    private var lang: [String: Any] = [:]
    private var loaded = false

    // Remote content overrides from Firestore
    private var remoteAffirmations: [String: [String]] = [:]
    private var remotePrograms: [String: [(limiting: String, rewrite: String)]] = [:]
    private var remoteMeditations: [String: [MeditationRaw]] = [:]
    private var remoteMusic: [MusicTrackRaw] = []
    private var remoteUiStrings: [String: String] = [:]

    private var listeners: [ListenerRegistration] = []
    var onMeditationsLoaded: (() -> Void)?

    func load() {
        guard !loaded else { return }
        guard let url = Bundle.main.url(forResource: "translations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let ru = json["ru"] as? [String: Any] else { return }
        lang = ru
        loaded = true
    }

    /// Start Firestore snapshot listeners for real-time content updates
    func syncFromFirestore() {
        let db: Firestore
        do {
            db = Firestore.firestore()
        } catch {
            return
        }

        // Affirmations
        listeners.append(db.collection("affirmations").addSnapshotListener { [weak self] snap, _ in
            guard let snap = snap else { return }
            var result: [String: [String]] = [:]
            for doc in snap.documents {
                if let texts = doc.data()["texts"] as? [String] {
                    result[doc.documentID] = texts
                }
            }
            self?.remoteAffirmations = result
        })

        // Programs
        listeners.append(db.collection("programs").addSnapshotListener { [weak self] snap, _ in
            guard let snap = snap else { return }
            var result: [String: [(limiting: String, rewrite: String)]] = [:]
            for doc in snap.documents {
                if let pairs = doc.data()["pairs"] as? [[String: String]] {
                    result[doc.documentID] = pairs.compactMap { p in
                        guard let l = p["limiting"], let r = p["rewrite"] else { return nil }
                        return (limiting: l, rewrite: r)
                    }
                }
            }
            self?.remotePrograms = result
        })

        // Meditations
        listeners.append(db.collection("meditations").addSnapshotListener { [weak self] snap, _ in
            guard let snap = snap else { return }
            var byArea: [String: [MeditationRaw]] = [:]
            for doc in snap.documents {
                let data = doc.data()
                guard let area = data["area"] as? String else { continue }
                let raw = MeditationRaw(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    fileName: data["fileName"] as? String ?? "",
                    durationSeconds: data["durationSeconds"] as? Int ?? 0,
                    audioUrl: data["audioUrl"] as? String ?? "",
                    coverUrl: data["coverUrl"] as? String ?? "",
                    coverColor: data["coverColor"] as? String ?? "",
                    popular: data["popular"] as? Bool ?? false
                )
                byArea[area, default: []].append(raw)
            }
            self?.remoteMeditations = byArea
            self?.onMeditationsLoaded?()
        })

        // Music
        listeners.append(db.collection("musicTracks").addSnapshotListener { [weak self] snap, _ in
            guard let snap = snap else { return }
            self?.remoteMusic = snap.documents.compactMap { doc in
                let data = doc.data()
                return MusicTrackRaw(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    artist: data["artist"] as? String ?? "",
                    fileName: data["fileName"] as? String ?? "",
                    durationSeconds: data["durationSeconds"] as? Int ?? 0,
                    audioUrl: data["audioUrl"] as? String ?? ""
                )
            }
        })

        // UI strings
        listeners.append(db.document("config/ui_strings").addSnapshotListener { [weak self] snap, _ in
            guard let snap = snap, snap.exists, let data = snap.data() else { return }
            var strings: [String: String] = [:]
            for (key, value) in data {
                if let s = value as? String { strings[key] = s }
            }
            self?.remoteUiStrings = strings
        })
    }

    static func ui(_ key: String) -> String {
        if let remote = shared.remoteUiStrings[key] { return remote }
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
        if let remote = shared.remoteAffirmations[key] { return remote }
        guard let affirmations = shared.lang["affirmations"] as? [String: [String]] else { return [] }
        return affirmations[key] ?? []
    }

    struct MeditationRaw {
        let id: String
        let title: String
        let description: String
        let fileName: String
        let durationSeconds: Int
        var audioUrl: String = ""
        var coverUrl: String = ""
        var coverColor: String = ""
        var popular: Bool = false
    }

    static func meditationData(_ area: LifeArea) -> [MeditationRaw] {
        let key = area.rawValue
        if let remote = shared.remoteMeditations[key] { return remote }
        guard let meditations = shared.lang["meditations"] as? [String: [[String: Any]]] else { return [] }
        guard let arr = meditations[key] else { return [] }
        return arr.compactMap { obj in
            guard let id = obj["id"] as? String,
                  let title = obj["title"] as? String,
                  let fileName = obj["fileName"] as? String,
                  let duration = obj["durationSeconds"] as? Int else { return nil }
            let description = obj["description"] as? String ?? ""
            return MeditationRaw(id: id, title: title, description: description, fileName: fileName, durationSeconds: duration)
        }
    }

    static func popularMeditations() -> [MeditationRaw] {
        shared.remoteMeditations.values.flatMap { $0 }.filter { $0.popular }
    }

    struct MusicTrackRaw {
        let id: String
        let title: String
        let artist: String
        let fileName: String
        let durationSeconds: Int
        var audioUrl: String = ""
    }

    static func musicData() -> [MusicTrackRaw] {
        if !shared.remoteMusic.isEmpty { return shared.remoteMusic }
        guard let arr = shared.lang["music"] as? [[String: Any]] else { return [] }
        return arr.compactMap { obj in
            guard let id = obj["id"] as? String,
                  let title = obj["title"] as? String,
                  let fileName = obj["fileName"] as? String,
                  let duration = obj["durationSeconds"] as? Int else { return nil }
            let artist = obj["artist"] as? String ?? ""
            return MusicTrackRaw(id: id, title: title, artist: artist, fileName: fileName, durationSeconds: duration)
        }
    }

    static func programPairs(_ area: LifeArea) -> [(limiting: String, rewrite: String)] {
        let key = area.rawValue
        if let remote = shared.remotePrograms[key] { return remote }
        guard let programs = shared.lang["programs"] as? [String: [[String: String]]] else { return [] }
        guard let arr = programs[key] else { return [] }
        return arr.compactMap { obj in
            guard let limiting = obj["limiting"], let rewrite = obj["rewrite"] else { return nil }
            return (limiting: limiting, rewrite: rewrite)
        }
    }
}
