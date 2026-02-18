import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct SuggestedQuestion: Identifiable {
    let id = UUID()
    let text: String
}

extension SuggestedQuestion {
    static let defaultQuestions = [
        SuggestedQuestion(text: "Why is it important to align your vibrations with abundance in order to experience it?"),
        SuggestedQuestion(text: "How do our feelings and emotions influence the events we attract into our lives?"),
        SuggestedQuestion(text: "Why is cultivating a sense of abundance the most effective technique for attracting abundance into your life?")
    ]
}
