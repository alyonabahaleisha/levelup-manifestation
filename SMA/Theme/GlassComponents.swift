import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    let content: () -> Content
    
    init(cornerRadius: CGFloat = 24, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.40), Color.white.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }
}

struct GlassChip<Content: View>: View {
    var isSelected: Bool = false
    var accentColor: Color = .white
    let content: () -> Content
    
    init(isSelected: Bool = false, accentColor: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.content = content
    }
    
    var body: some View {
        content()
            .background(isSelected ? accentColor.opacity(0.25) : Color.white.opacity(0.50))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? accentColor.opacity(0.6) : Color.white.opacity(0.50),
                        lineWidth: 0.5
                    )
            )
    }
}
