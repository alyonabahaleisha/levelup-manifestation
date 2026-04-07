import SwiftUI

struct MusicView: View {
    @ObservedObject var viewModel: MusicViewModel

    var body: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(Translations.ui("musicTitle"))
                        .font(AppTypography.headingLarge)
                        .foregroundColor(.white)
                    Text(Translations.ui("musicSubtitle"))
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white.opacity(0.55))
                }
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Track list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.allTracks().enumerated()), id: \.element.id) { index, track in
                            let isActive = viewModel.currentTrackId == track.id
                            let isPlaying = isActive && viewModel.playbackState == .playing
                            let progress: Double = isActive && viewModel.duration > 0
                                ? viewModel.currentPosition / viewModel.duration : 0

                            MusicTrackCard(
                                track: track,
                                isActive: isActive,
                                isPlaying: isPlaying,
                                progress: progress
                            ) {
                                if isActive {
                                    viewModel.togglePlayPause()
                                } else {
                                    viewModel.play(track)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Track Card

private struct MusicTrackCard: View {
    let track: MusicTrack
    let isActive: Bool
    let isPlaying: Bool
    let progress: Double
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Play button
                Circle()
                    .fill(.white.opacity(isActive ? 0.25 : 0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    )

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if !track.artist.isEmpty {
                        Text(track.artist)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Duration
                Text(formatDuration(track.durationSeconds))
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            // Progress bar when active
            if isActive {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.1))
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.6))
                            .frame(width: geo.size.width * CGFloat(progress), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.top, 10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(isActive ? 0.15 : 0.08))
        )
        .onTapGesture(perform: onTap)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return "\(h):\(String(format: "%02d", m)):00"
        }
        return "\(m):\(String(format: "%02d", s))"
    }
}

