import Foundation

enum AffirmationContent {
    static func feed(_ areas: [LifeArea] = []) -> [Affirmation] {
        let targetAreas = areas.isEmpty ? LifeArea.allCases : areas
        return targetAreas.flatMap { area in
            Translations.affirmationStrings(area).map { text in
                Affirmation(text: text, area: area)
            }
        }.shuffled()
    }
}
