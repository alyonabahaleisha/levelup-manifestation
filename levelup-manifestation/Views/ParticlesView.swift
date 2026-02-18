import SwiftUI
import Vortex

struct ParticlesView: View {
    var body: some View {
        VortexView(makeStars()) {
            Circle()
                .fill(.white)
                .frame(width: 32)
                .blur(radius: 3)
                .blendMode(.plusLighter)
                .tag("star")
        }
    }

    private func makeStars() -> VortexSystem {
        VortexSystem(
            tags: ["star"],
            shape: .box(width: 1, height: 1),
            birthRate: 60,
            lifespan: 4,
            speed: 0,
            speedVariation: 0.1,
            angleRange: .degrees(360),
            colors: .ramp(.white, .white, .white.opacity(0)),
            size: 0.15,
            sizeVariation: 0.1,
            sizeMultiplierAtDeath: 0
        )
    }
}
