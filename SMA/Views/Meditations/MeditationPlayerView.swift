import SwiftUI

struct MeditationPlayerView: View {
    let meditation: Meditation
    @ObservedObject var viewModel: MeditationViewModel
    var cardImage: String = "bg_player"
    var gifName: String? = nil
    var coverUrl: String? = nil
    var onBack: () -> Void

    @State private var isDragging = false
    @State private var dragProgress: Double = 0
    @State private var sheetExpanded = false

    private var isActive: Bool {
        viewModel.currentMeditationId == meditation.id &&
        (viewModel.playbackState == .playing || viewModel.playbackState == .paused || viewModel.playbackState == .buffering)
    }
    private var isPlaying: Bool {
        viewModel.currentMeditationId == meditation.id && viewModel.playbackState == .playing
    }
    private var isBuffering: Bool {
        viewModel.currentMeditationId == meditation.id && viewModel.playbackState == .buffering
    }
    private var progress: Double {
        if isDragging { return dragProgress }
        return isActive && viewModel.duration > 0 ? viewModel.currentPosition / viewModel.duration : 0
    }
    private var elapsed: TimeInterval {
        if isDragging { return dragProgress * effectiveDuration }
        return isActive ? viewModel.currentPosition : 0
    }
    private var effectiveDuration: TimeInterval {
        isActive && viewModel.duration > 0 ? viewModel.duration : Double(meditation.durationSeconds)
    }
    private var remaining: TimeInterval {
        effectiveDuration - elapsed
    }

    var body: some View {
        ZStack {
            // Layer 0: Background image
            GeometryReader { geo in
                if let urlString = coverUrl, let url = URL(string: urlString) {
                    CachedAsyncImage(url: url)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    areaColor(meditation.area)
                }
            }
            .ignoresSafeArea()

            // Layer 1: Gradient overlay
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.5), location: 0),
                    .init(color: .black.opacity(0.10), location: 0.25),
                    .init(color: .black.opacity(0.10), location: 0.50),
                    .init(color: .black.opacity(0.50), location: 0.70),
                    .init(color: .black.opacity(0.80), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Layer 2: Fixed controls centered on screen
            VStack {
                Spacer()

                // Title
                Text(meditation.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)

                Spacer().frame(height: 8)

                // Duration label
                Text("\(meditation.durationSeconds / 60) \(Translations.ui("minutesShort"))")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.65))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                Spacer().frame(height: 24)

                // Playback controls
                HStack(spacing: 32) {
                    Button {
                        if isActive { viewModel.seekTo(max(0, viewModel.currentPosition - 10)) }
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 56, height: 56)
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.22))
                            .clipShape(Circle())
                    }

                    Button {
                        if isActive { viewModel.togglePlayPause() } else { viewModel.play(meditation) }
                    } label: {
                        let dlState: DownloadState = {
                            let id = meditation.id
                            if let state = viewModel.downloads[id] { return state }
                            return AudioDownloadManager.shared.isDownloaded(id)
                                ? DownloadState(status: .downloaded, progress: 1)
                                : DownloadState()
                        }()

                        ZStack {
                            if dlState.status == .downloading {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 3)
                                    .frame(width: 88, height: 88)
                                Circle()
                                    .trim(from: 0, to: dlState.progress)
                                    .stroke(Color(hex: "B88AAE").opacity(0.90), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 88, height: 88)
                                    .animation(.linear(duration: 0.2), value: dlState.progress)
                            } else if dlState.status == .downloaded {
                                Circle()
                                    .stroke(Color(hex: "B88AAE").opacity(0.30), lineWidth: 2)
                                    .frame(width: 88, height: 88)
                            }

                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().fill(Color.white.opacity(0.12)))
                                .frame(width: 80, height: 80)

                            if isBuffering {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                                    .scaleEffect(1.2)
                            } else {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    Button {
                        if isActive { viewModel.seekTo(min(viewModel.duration, viewModel.currentPosition + 10)) }
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 56, height: 56)
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.22))
                            .clipShape(Circle())
                    }
                }

                Spacer().frame(height: 32)

                // Seek bar
                seekBarSection
                    .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.bottom, 120)

            // Layer 3: Draggable bottom sheet (only when description exists)
            if !meditation.description.isEmpty {
                GeometryReader { geo in
                    let sheetHeight: CGFloat = sheetExpanded ? geo.size.height * 0.6 : 120
                    let safeBottom = geo.safeAreaInsets.bottom

                    VStack(spacing: 0) {
                        // Drag handle
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.30))
                            .frame(width: 40, height: 4)
                            .padding(.top, 12)

                        Spacer().frame(height: 12)

                        // "Описание" label — always visible
                        Text("Описание")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.50))

                        // Description content — visible only when expanded
                        if sheetExpanded {
                            Spacer().frame(height: 16)

                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                                .padding(.horizontal, 24)

                            Spacer().frame(height: 16)

                            ScrollView(.vertical, showsIndicators: false) {
                                Text(meditation.description)
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineSpacing(9)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, safeBottom + 16)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: sheetHeight + safeBottom)
                    .background(Color(hex: "101820").opacity(0.92))
                    .clipShape(
                        .rect(
                            topLeadingRadius: 24,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 24
                        )
                    )
                    .position(x: geo.size.width / 2, y: geo.size.height + geo.safeAreaInsets.bottom - (sheetHeight + safeBottom) / 2)
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onEnded { value in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    if value.translation.height < -50 {
                                        sheetExpanded = true
                                    } else if value.translation.height > 50 {
                                        sheetExpanded = false
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            sheetExpanded.toggle()
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: sheetExpanded)
                }
                .ignoresSafeArea()
            }

            // Layer 4: Back button — fixed top-left, respects safe area
            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.22))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 8)
                Spacer()
            }
        }
    }

    // MARK: - Seek Bar

    private var seekBarSection: some View {
        VStack(spacing: 8) {
            // Seek track
            GeometryReader { geo in
                let trackWidth = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: max(0, trackWidth * progress), height: 4)

                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .frame(width: isDragging ? 16 : 12, height: isDragging ? 16 : 12)
                        .offset(x: max(0, trackWidth * progress - (isDragging ? 8 : 6)))
                        .animation(.easeOut(duration: 0.15), value: isDragging)
                }
                .contentShape(Rectangle().size(CGSize(width: trackWidth, height: 44)))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let fraction = min(max(value.location.x / trackWidth, 0), 1)
                            dragProgress = fraction
                        }
                        .onEnded { value in
                            let fraction = min(max(value.location.x / trackWidth, 0), 1)
                            let seekTime = fraction * effectiveDuration
                            if isActive {
                                viewModel.seekTo(seekTime)
                            }
                            isDragging = false
                        }
                )
            }
            .frame(height: 44)

            // Time labels
            HStack {
                Text(formatTime(elapsed))
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.65))
                    .monospacedDigit()

                Spacer()

                Text("-\(formatTime(remaining))")
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.65))
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
            context.stroke(trackPath, with: .color(.white.opacity(0.12)), style: StrokeStyle(lineWidth: 8, lineCap: .round))

            // Progress
            if progress > 0 {
                var progressPath = Path()
                let progressAngle = startAngle + Angle.degrees(240 * progress)
                progressPath.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: progressAngle, clockwise: false)

                // Glow
                context.stroke(progressPath, with: .color(accentColor.opacity(0.3)), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                // Main stroke
                context.stroke(progressPath, with: .color(accentColor), style: StrokeStyle(lineWidth: 8, lineCap: .round))

                // Dot
                let dotAngle = progressAngle.radians
                let dotX = center.x + radius * cos(dotAngle)
                let dotY = center.y + radius * sin(dotAngle)

                context.fill(Circle().path(in: CGRect(x: dotX - 12, y: dotY - 12, width: 24, height: 24)), with: .color(accentColor.opacity(0.3)))
                context.fill(Circle().path(in: CGRect(x: dotX - 8, y: dotY - 8, width: 16, height: 16)), with: .color(.white))
            }
        }
    }
}
