import SwiftUI
import Combine

class MeditationViewModel: ObservableObject {
    private let audioManager = AudioPlayerManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var playbackState: PlaybackState = .idle
    @Published var currentPosition: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentMeditationId: String?
    @AppStorage("last_meditation_id") var lastMeditationId: String = ""
    
    init() {
        audioManager.$playbackState.assign(to: &$playbackState)
        audioManager.$currentPosition.assign(to: &$currentPosition)
        audioManager.$duration.assign(to: &$duration)
        audioManager.$currentMeditationId.assign(to: &$currentMeditationId)
    }
    
    func meditationsForArea(_ area: LifeArea) -> [Meditation] {
        MeditationContent.meditations(area)
    }
    
    func allMeditations() -> [Meditation] {
        MeditationContent.allMeditations()
    }
    
    func play(_ meditation: Meditation) {
        let url = MeditationContent.audioURL(meditation)
        audioManager.play(meditationId: meditation.id, url: url)
        lastMeditationId = meditation.id
    }
    
    func togglePlayPause() { audioManager.togglePlayPause() }
    func seekTo(_ seconds: TimeInterval) { audioManager.seekTo(seconds) }
    func stop() { audioManager.stop() }
}
