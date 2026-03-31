import SwiftUI

struct MeditationPlayerView: View {
    let meditation: Meditation
    @ObservedObject var viewModel: MeditationViewModel
    var cardImage: String = "bg_player"
    var gifName: String? = nil
    var coverUrl: String? = nil
    var onBack: () -> Void
    
    private var isActive: Bool {
        viewModel.currentMeditationId == meditation.id &&
        (viewModel.playbackState == .playing || viewModel.playbackState == .paused || viewModel.playbackState == .buffering)
    }
    private var isPlaying: Bool {
        viewModel.currentMeditationId == meditation.id && viewModel.playbackState == .playing
    }
    private var progress: Double {
        isActive && viewModel.duration > 0 ? viewModel.currentPosition / viewModel.duration : 0
    }
    
    var body: some View {
        ZStack {
            // Background: prefer remote coverUrl, fall back to local asset/GIF
            GeometryReader { geo in
                if let urlString = coverUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        default:
                            localBackground(width: geo.size.width, height: geo.size.height)
                        }
                    }
                } else {
                    localBackground(width: geo.size.width, height: geo.size.height)
                }
            }
            .ignoresSafeArea()

            // Gradient overlay: dark at top/bottom, clear in center
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.6), location: 0),
                    .init(color: .black.opacity(0.15), location: 0.3),
                    .init(color: .black.opacity(0.15), location: 0.55),
                    .init(color: .black.opacity(0.55), location: 0.75),
                    .init(color: .black.opacity(0.75), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: onBack) {
                        GlassCard(cornerRadius: 14) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Arc + portrait
                ZStack {
                    // Progress arc
                    CircularArc(progress: progress, accentColor: ToneTheme.default.accent)
                        .frame(width: 280, height: 280)
                    
                }
                
                Spacer().frame(height: 40)
                
                // Title
                Text(meditation.title)
                    .font(AppTypography.headingLarge)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer().frame(height: 12)
                
                Text("\(Translations.lifeAreaLabel(meditation.area))  ·  \(meditation.durationSeconds / 60) \(Translations.ui("minutesShort"))")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                // Controls
                HStack(spacing: 32) {
                    // Rewind 10s
                    Button {
                        if isActive { viewModel.seekTo(max(0, viewModel.currentPosition - 10)) }
                    } label: {
                        GlassCard(cornerRadius: 28) {
                            Image(systemName: "gobackward.10")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 56, height: 56)
                        }
                    }
                    
                    // Play/Pause
                    Button {
                        if isActive { viewModel.togglePlayPause() } else { viewModel.play(meditation) }
                    } label: {
                        Circle()
                            .fill(Color(hex: "2A2A3A"))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Forward 10s
                    Button {
                        if isActive { viewModel.seekTo(min(viewModel.duration, viewModel.currentPosition + 10)) }
                    } label: {
                        GlassCard(cornerRadius: 28) {
                            Image(systemName: "goforward.10")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 56, height: 56)
                        }
                    }
                }
                
                Spacer().frame(height: 80)
            }
        }
    }

    @ViewBuilder
    private func localBackground(width: CGFloat, height: CGFloat) -> some View {
        if let gif = gifName {
            GIFView(gifName: gif)
                .frame(width: width, height: height)
                .clipped()
        } else {
            Image(cardImage)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
        }
    }
}

// MARK: - Circular Arc

struct CircularArc: View {
    let progress: Double
    let accentColor: Color
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 16
            let startAngle = Angle.degrees(150)
            let sweepAngle = Angle.degrees(240)
            
            // Track
            var trackPath = Path()
            trackPath.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: startAngle + sweepAngle, clockwise: false)
            context.stroke(trackPath, with: .color(.white.opacity(0.1)), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            
            // Progress
            if progress > 0 {
                var progressPath = Path()
                let progressAngle = startAngle + Angle.degrees(240 * progress)
                progressPath.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: progressAngle, clockwise: false)
                context.stroke(progressPath, with: .color(accentColor), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                
                // Dot
                let dotAngle = (startAngle + Angle.degrees(240 * progress)).radians
                let dotX = center.x + radius * cos(dotAngle)
                let dotY = center.y + radius * sin(dotAngle)
                
                context.fill(Circle().path(in: CGRect(x: dotX - 12, y: dotY - 12, width: 24, height: 24)), with: .color(accentColor.opacity(0.3)))
                context.fill(Circle().path(in: CGRect(x: dotX - 9, y: dotY - 9, width: 18, height: 18)), with: .color(.white))
            }
        }
    }
}
