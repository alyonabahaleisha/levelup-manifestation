import Foundation

enum ProgramContent {
    static func programs(_ area: LifeArea) -> [HiddenProgram] {
        Translations.programPairs(area).map { pair in
            HiddenProgram(limiting: pair.limiting, rewrite: pair.rewrite, area: area)
        }
    }
}
