import Foundation

struct MeditationMessage: Identifiable {
    let id = UUID()
    let text: String
    let category: String
}

extension MeditationMessage {
    static let sampleMessages = [
        MeditationMessage(
            text: "You found what you're looking for",
            category: "Abundance"
        ),
        MeditationMessage(
            text: "Everything you need is already within you",
            category: "Self-Love"
        ),
        MeditationMessage(
            text: "Your vibration attracts your reality",
            category: "Manifestation"
        ),
        MeditationMessage(
            text: "Abundance flows to you effortlessly",
            category: "Prosperity"
        ),
        MeditationMessage(
            text: "You are worthy of all good things",
            category: "Worthiness"
        )
    ]
}
