import AVFoundation
import Combine

enum PlaybackState {
    case idle, buffering, playing, paused
}

class AudioPlayerManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioPlayerManager()

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var downloadTask: URLSessionDownloadTask?

    @Published var playbackState: PlaybackState = .idle
    @Published var currentPosition: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentMeditationId: String?

    private let cacheDir: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("meditations", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(meditationId: String, url: String) {
        guard let audioURL = URL(string: url) else { return }
        stop()
        currentMeditationId = meditationId
        playbackState = .buffering

        let cachedFile = cacheDir.appendingPathComponent(audioURL.lastPathComponent)

        if FileManager.default.fileExists(atPath: cachedFile.path) {
            startPlayback(url: cachedFile, meditationId: meditationId)
        } else {
            downloadTask = URLSession.shared.downloadTask(with: audioURL) { [weak self] tempURL, _, error in
                guard let self, let tempURL, error == nil else {
                    DispatchQueue.main.async { self?.playbackState = .idle }
                    return
                }
                try? FileManager.default.moveItem(at: tempURL, to: cachedFile)
                DispatchQueue.main.async {
                    guard self.currentMeditationId == meditationId else { return }
                    self.startPlayback(url: cachedFile, meditationId: meditationId)
                }
            }
            downloadTask?.resume()
        }
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
        downloadTask?.cancel()
        downloadTask = nil
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
