import SwiftUI
import Vortex

// ANDROID: ParticlesView.kt — custom Canvas-based particle system (no direct Vortex equivalent)
//   data class Particle(var x: Float, var y: Float, var vx: Float, var vy: Float,
//                       var alpha: Float, var radius: Float, var life: Float)
//   Canvas(Modifier.fillMaxSize()) {
//       particles.forEach { p ->
//           drawCircle(color = White.copy(alpha = p.alpha), radius = p.radius, center = Offset(p.x, p.y),
//                      blendMode = BlendMode.Plus)
//       }
//   }
//   Animate with LaunchedEffect + withFrameNanos loop (60fps game loop pattern)
//   Alternatively: use "particles-kt" or "Konfetti" library for simpler integration
//   Birth rate ~3/frame, lifespan ~4s, drift upward slowly, fade in/out

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
