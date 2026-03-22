import SwiftUI

class SavedProgramsViewModel: ObservableObject {
    @AppStorage("saved_programs_v1") private var savedJSON: String = "[]"
    @Published var saved: [Affirmation] = []
    
    init() { load() }
    
    func save(_ program: HiddenProgram) {
        let affirmation = Affirmation(text: program.rewrite, area: program.area, isPersonal: true)
        guard !saved.contains(where: { $0.text == affirmation.text }) else { return }
        saved.append(affirmation)
        persist()
    }
    
    private func load() {
        guard let data = savedJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Affirmation].self, from: data) else { return }
        saved = decoded
    }
    
    private func persist() {
        guard let data = try? JSONEncoder().encode(saved),
              let json = String(data: data, encoding: .utf8) else { return }
        savedJSON = json
    }
}
