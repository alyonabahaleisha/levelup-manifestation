import SwiftUI
import Combine

class MusicViewModel: ObservableObject {
    private let audioManager = AudioPlayerManager.shared
    private let downloadManager = AudioDownloadManager.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var playbackState: PlaybackState = .idle
    @Published var currentPosition: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentTrackId: String?
    @Published var currentTitle: String?
    @Published var contentType: ContentType?
    @Published var currentCoverUrl: String?
    @Published var downloads: [String: DownloadState] = [:]
    @AppStorage("last_music_track_id") var lastTrackId: String = ""

    init() {
        audioManager.$playbackState.assign(to: &$playbackState)
        audioManager.$currentPosition.assign(to: &$currentPosition)
        audioManager.$duration.assign(to: &$duration)
        audioManager.$currentMeditationId.assign(to: &$currentTrackId)
        audioManager.$currentTitle.assign(to: &$currentTitle)
        audioManager.$contentType.assign(to: &$contentType)
        audioManager.$currentCoverUrl.assign(to: &$currentCoverUrl)
        downloadManager.$downloads.assign(to: &$downloads)
    }

    func downloadState(for id: String) -> DownloadState {
        downloadManager.downloadState(for: id)
    }

    func allTracks() -> [MusicTrack] {
        MusicContent.allTracks()
    }

    func play(_ track: MusicTrack) {
        let url = MusicContent.audioURL(track)
        audioManager.play(meditationId: track.id, url: url, title: track.title, contentType: .music)
        lastTrackId = track.id
    }

    func togglePlayPause() { audioManager.togglePlayPause() }
    func seekTo(_ seconds: TimeInterval) { audioManager.seekTo(seconds) }
    func stop() { audioManager.stop() }
}
