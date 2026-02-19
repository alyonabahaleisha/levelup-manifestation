import SwiftUI

/// This view IS the app icon design.
/// To export: open Preview in Xcode → screenshot at 1024×1024 → save as PNG
/// → drag into Assets.xcassets → AppIcon
struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.04, blue: 0.12),
                    Color(red: 0.18, green: 0.06, blue: 0.18),
                    Color(red: 0.06, green: 0.02, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.92, green: 0.68, blue: 0.75).opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 60,
                        endRadius: 200
                    )
                )
                .scaleEffect(1.4)

            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.92, green: 0.68, blue: 0.75).opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )

            VStack(spacing: 10) {
                // Star cluster
                ZStack {
                    // Outer stars
                    Text("·")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundStyle(Color(red: 0.92, green: 0.68, blue: 0.75).opacity(0.5))
                        .offset(x: -52, y: -28)

                    Text("·")
                        .font(.system(size: 18, weight: .thin))
                        .foregroundStyle(Color(red: 0.92, green: 0.68, blue: 0.75).opacity(0.35))
                        .offset(x: 54, y: -38)

                    Text("·")
                        .font(.system(size: 14, weight: .thin))
                        .foregroundStyle(.white.opacity(0.3))
                        .offset(x: -38, y: 44)

                    Text("·")
                        .font(.system(size: 22, weight: .thin))
                        .foregroundStyle(.white.opacity(0.25))
                        .offset(x: 44, y: 36)

                    // Main symbol
                    Text("✦")
                        .font(.system(size: 72, weight: .ultraLight))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.82, blue: 0.87),
                                    Color(red: 0.92, green: 0.68, blue: 0.75)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(width: 160, height: 140)

                // App name
                Text("LevelUp")
                    .font(.system(size: 36, weight: .thin))
                    .foregroundStyle(.white)
                    .tracking(5)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 224, style: .continuous))
    }
}

#Preview {
    AppIconView()
        .frame(width: 400, height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 88, style: .continuous))
}
