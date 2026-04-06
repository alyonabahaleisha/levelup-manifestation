import SwiftUI

struct MiniPlayerView: View {
    let title: String
    let contentType: ContentType
    let isPlaying: Bool
    let isBuffering: Bool
    let progress: Double // 0...1
    let coverUrl: String?
    let onTogglePlayPause: () -> Void
    let onDismiss: () -> Void
    let onClick: () -> Void

    private var subtitleKey: String {
        switch contentType {
        case .meditation: return "meditationsTab"
        case .music: return "musicTab"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Cover thumbnail — 52pt square, 8pt corner radius
                Group {
                    if let urlString = coverUrl, let url = URL(string: urlString) {
                        CachedAsyncImage(url: url)
                            .frame(width: 52, height: 52)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(ToneTheme.default.accent.opacity(0.3))
                            .frame(width: 52, height: 52)
                    }
                }
                .cornerRadius(8)

                // Title + subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(Translations.ui(subtitleKey))
                        .font(AppTypography.caption)
                        .foregroundColor(.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Play/Pause button — 44pt tap target, 44pt visual circle
                Button(action: onTogglePlayPause) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 44, height: 44)

                        if isBuffering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                // Close/dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.60))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 80)

        }
        .background(Color(hex: "0D3347"))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .contentShape(RoundedRectangle(cornerRadius: 28))
        .onTapGesture {
            onClick()
        }
    }
}
