import SwiftUI

struct AffirmationTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let colors: [Color]
    let textColor: Color

    static func == (lhs: AffirmationTheme, rhs: AffirmationTheme) -> Bool {
        lhs.id == rhs.id
    }

    @ViewBuilder
    var backgroundView: some View {
        if colors.count > 1 {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            colors.first ?? Color.clear
        }
    }

    static let all: [AffirmationTheme] = [
        AffirmationTheme(
            id: "cream", name: "Крем",
            colors: [Color(hex: "E8DDD3")],
            textColor: Color(hex: "3C2A21")
        ),
        AffirmationTheme(
            id: "teal", name: "Океан",
            colors: [Color(hex: "154C6C")],
            textColor: .white
        ),
        AffirmationTheme(
            id: "lavender", name: "Лаванда",
            colors: [Color(hex: "E6E0F3"), Color(hex: "C9B8E8")],
            textColor: Color(hex: "4A3560")
        ),
        AffirmationTheme(
            id: "sunset", name: "Закат",
            colors: [Color(hex: "FF8C69"), Color(hex: "FF6B95")],
            textColor: .white
        ),
        AffirmationTheme(
            id: "forest", name: "Лес",
            colors: [Color(hex: "2D5A3D"), Color(hex: "1B3A2A")],
            textColor: Color(hex: "E8F5E9")
        ),
        AffirmationTheme(
            id: "rose", name: "Роза",
            colors: [Color(hex: "F5D0D0"), Color(hex: "EBB5B5")],
            textColor: Color(hex: "5A2D3D")
        ),
        AffirmationTheme(
            id: "midnight", name: "Полночь",
            colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
            textColor: Color(hex: "E8E8FF")
        ),
        AffirmationTheme(
            id: "golden", name: "Золото",
            colors: [Color(hex: "F4E4BA"), Color(hex: "E8D5A0")],
            textColor: Color(hex: "5C4A28")
        ),
        AffirmationTheme(
            id: "sky", name: "Небо",
            colors: [Color(hex: "A7D8F0"), Color(hex: "C5E8F7")],
            textColor: Color(hex: "1A3A4A")
        ),
        AffirmationTheme(
            id: "charcoal", name: "Уголь",
            colors: [Color(hex: "2C2C2C"), Color(hex: "3D3D3D")],
            textColor: Color(hex: "F2EDE8")
        ),
        AffirmationTheme(
            id: "peach", name: "Персик",
            colors: [Color(hex: "FFDAB9"), Color(hex: "FFE4C4")],
            textColor: Color(hex: "5A3E2B")
        ),
        AffirmationTheme(
            id: "aurora", name: "Аврора",
            colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F"), Color(hex: "52B788")],
            textColor: Color(hex: "EDFAF0")
        ),
    ]

    static func theme(for id: String) -> AffirmationTheme {
        all.first { $0.id == id } ?? all[0]
    }
}
