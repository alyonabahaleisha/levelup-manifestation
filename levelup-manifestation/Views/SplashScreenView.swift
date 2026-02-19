import SwiftUI

struct SplashScreenView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.8
    @State private var taglineOpacity: Double = 0
    @State private var symbolScale: Double = 0.6
    @State private var symbolOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background — soft feminine default on launch
            LinearGradient(
                colors: ToneTheme.softFeminine.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ParticlesView()

            VStack(spacing: 0) {
                Spacer()

                // Symbol
                Text("✦")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(ToneTheme.softFeminine.accent)
                    .scaleEffect(symbolScale)
                    .opacity(symbolOpacity)
                    .padding(.bottom, 20)

                // App name
                Text("LevelUp")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundStyle(.white)
                    .tracking(10)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)

                // Tagline
                Text("become who you are meant to be")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.45))
                    .tracking(2)
                    .padding(.top, 14)
                    .opacity(taglineOpacity)

                Spacer()
            }
        }
        .onAppear { animate() }
    }

    private func animate() {
        // Symbol fades + scales in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            symbolOpacity = 1
            symbolScale = 1
        }

        // Logo fades + scales in with slight delay
        withAnimation(.easeOut(duration: 0.7).delay(0.25)) {
            logoOpacity = 1
            logoScale = 1
        }

        // Tagline fades in last
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            taglineOpacity = 1
        }
    }
}

#Preview {
    SplashScreenView()
}
