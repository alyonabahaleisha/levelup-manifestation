import AVFoundation
import Combine

enum PlaybackState {
    case idle, buffering, playing, paused
}

class AudioPlayerManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var playbackState: PlaybackState = .idle
    @Published var currentPosition: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentMeditationId: String?
    
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func play(meditationId: String, url: String) {
        guard let audioURL = URL(string: url) else { return }
        stop()
        currentMeditationId = meditationId
        let item = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: item)
        player?.play()
        playbackState = .playing
        startPositionUpdates()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            self?.playbackState = .idle
            self?.currentPosition = 0
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
    }
    
    func seekTo(_ seconds: TimeInterval) {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
        currentPosition = seconds
    }
    
    func stop() {
        player?.pause()
        if let obs = timeObserver { player?.removeTimeObserver(obs) }
        timeObserver = nil
        player = nil
        playbackState = .idle
        currentPosition = 0
        duration = 0
        currentMeditationId = nil
    }
    
    private func startPositionUpdates() {
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentPosition = time.seconds
            if let dur = self?.player?.currentItem?.duration.seconds, !dur.isNaN {
                self?.duration = dur
            }
        }
    }
}
