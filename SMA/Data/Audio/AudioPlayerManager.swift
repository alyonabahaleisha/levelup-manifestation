import AVFoundation
import Combine
import MediaPlayer

enum PlaybackState {
    case idle, buffering, playing, paused
}

enum ContentType {
    case meditation, music
}

class AudioPlayerManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioPlayerManager()

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    @Published var playbackState: PlaybackState = .idle
    @Published var currentPosition: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentMeditationId: String?
    @Published var currentTitle: String?
    @Published var contentType: ContentType?
    @Published var currentCoverUrl: String?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        setupRemoteCommandCenter()
    }

    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            DispatchQueue.main.async { self.togglePlayPause() }
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            DispatchQueue.main.async { self.togglePlayPause() }
            return .success
        }

        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            DispatchQueue.main.async { self.togglePlayPause() }
            return .success
        }

        center.skipForwardCommand.preferredIntervals = [10]
        center.skipForwardCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            DispatchQueue.main.async { self.seekTo(self.currentPosition + 10) }
            return .success
        }

        center.skipBackwardCommand.preferredIntervals = [10]
        center.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            DispatchQueue.main.async { self.seekTo(max(0, self.currentPosition - 10)) }
            return .success
        }

        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self,
                  let posEvent = event as? MPChangePlaybackPositionCommandEvent
            else { return .noActionableNowPlayingItem }
            let position = posEvent.positionTime
            DispatchQueue.main.async { self.seekTo(position) }
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard playbackState != .idle, let title = currentTitle else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        let artist: String
        switch contentType {
        case .music: artist = "Музыка"
        default:     artist = "Медитации"
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentPosition,
            MPNowPlayingInfoPropertyPlaybackRate: playbackState == .playing ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0
        ]

        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }

        if let urlString = currentCoverUrl,
           let url = URL(string: urlString),
           let uiImage = ImageCache.shared.image(for: url) {
            let artwork = MPMediaItemArtwork(boundsSize: uiImage.size) { _ in uiImage }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func play(meditationId: String, url: String, title: String? = nil, contentType: ContentType? = nil, coverUrl: String? = nil) {
        guard let audioURL = URL(string: url) else { return }
        stop()
        currentMeditationId = meditationId
        currentTitle = title
        self.contentType = contentType
        currentCoverUrl = coverUrl
        playbackState = .buffering

        // Play from cache if available, otherwise stream
        if let localURL = AudioDownloadManager.shared.localURL(for: meditationId) {
            startPlayback(url: localURL, meditationId: meditationId)
        } else {
            startPlayback(url: audioURL, meditationId: meditationId)
        }

        // Background download for offline use
        AudioDownloadManager.shared.download(id: meditationId, url: url)
    }

    private func startPlayback(url: URL, meditationId: String) {
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    if self?.playbackState == .buffering {
                        self?.playbackState = .playing
                    }
                case .failed:
                    self?.playbackState = .idle
                default:
                    break
                }
            }
        }

        player?.play()
        playbackState = .playing
        startPositionUpdates()
        updateNowPlayingInfo()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            self?.playbackState = .idle
            self?.currentPosition = 0
            self?.updateNowPlayingInfo()
        }
    }

    func togglePlayPause() {
        guard let player else { return }
        if player.rate > 0 {
            player.pause()
            playbackState = .paused
        } else {
            player.play()
            playbackState = .playing
        }
        updateNowPlayingInfo()
    }

    func seekTo(_ seconds: TimeInterval) {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
        currentPosition = seconds
        updateNowPlayingInfo()
    }

    func stop() {
        player?.pause()
        statusObserver?.invalidate()
        statusObserver = nil
        if let obs = timeObserver { player?.removeTimeObserver(obs) }
        timeObserver = nil
        player = nil
        playbackState = .idle
        currentPosition = 0
        duration = 0
        currentMeditationId = nil
        currentTitle = nil
        contentType = nil
        currentCoverUrl = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func startPositionUpdates() {
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentPosition = time.seconds
            if let dur = self.player?.currentItem?.duration.seconds, !dur.isNaN {
                self.duration = dur
            }
            self.updateNowPlayingInfo()
        }
    }
}
