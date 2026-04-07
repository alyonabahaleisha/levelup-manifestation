import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var savedProgramsVM = SavedProgramsViewModel()
    @StateObject private var meditationVM = MeditationViewModel()
    @StateObject private var musicVM = MusicViewModel()
    @State private var selectedTab = 0
    @State private var pendingMoodKey: String? = nil
    @State private var pendingMeditation: Meditation? = nil
    @State private var isMeditationPlayerOpen = false
    @State private var miniPlayerAtTop = false
    @State private var miniPlayerDragOffset: CGFloat = 0

    private var showMiniPlayer: Bool {
        let state = meditationVM.playbackState
        guard meditationVM.currentTitle != nil else { return false }
        guard state == .playing || state == .paused || state == .buffering else { return false }
        return !isMeditationPlayerOpen
    }

    private func handleMiniPlayerTap() {
        switch meditationVM.contentType {
        case .music:
            selectedTab = 3
        case .meditation:
            if let id = meditationVM.currentMeditationId,
               let meditation = meditationVM.allMeditations().first(where: { $0.id == id }) {
                pendingMeditation = meditation
                selectedTab = 2
            }
        case .none:
            if let id = meditationVM.currentMeditationId,
               let meditation = meditationVM.allMeditations().first(where: { $0.id == id }) {
                pendingMeditation = meditation
                selectedTab = 2
            }
        }
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(
                    savedProgramsVM: savedProgramsVM,
                    meditationVM: meditationVM,
                    onNavigateToReprogram: { selectedTab = 4 },
                    onNavigateToMeditations: { selectedTab = 2 },
                    onMeditationTapped: { meditation in
                        pendingMeditation = meditation
                        selectedTab = 2
                    },
                    onMoodBubbleTapped: { moodKey in
                        pendingMoodKey = moodKey
                        selectedTab = 2
                    },
                    themeViewModel: themeViewModel
                )
                .tabItem {
                    Image(systemName: "sun.max")
                    Text(Translations.ui("homeTab"))
                }
                .tag(0)

                AffirmationsView()
                    .tabItem {
                        Image(systemName: "quote.bubble")
                        Text(Translations.ui("affirmationsTab"))
                    }
                    .tag(1)

                MeditationsView(
                    viewModel: meditationVM,
                    initialMoodKey: pendingMoodKey,
                    pendingMeditation: $pendingMeditation,
                    onNavigateToHome: { selectedTab = 0 },
                    isMeditationPlayerOpen: $isMeditationPlayerOpen
                )
                .tabItem {
                    Image(systemName: "moon.stars")
                    Text(Translations.ui("meditationsTab"))
                }
                .tag(2)

                MusicView(viewModel: musicVM)
                    .tabItem {
                        Image(systemName: "music.note")
                        Text(Translations.ui("musicTab"))
                    }
                    .tag(3)

                ReprogramView(savedProgramsVM: savedProgramsVM)
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text(Translations.ui("reprogramTab"))
                    }
                    .tag(4)

            }
            .tint(.white.opacity(0.9))
            .statusBarHidden(true)
            .onChange(of: selectedTab) { _, newTab in
                if newTab != 2 {
                    pendingMoodKey = nil
                    pendingMeditation = nil
                }
            }

            if showMiniPlayer {
                VStack {
                    if !miniPlayerAtTop { Spacer() }

                    MiniPlayerView(
                        title: meditationVM.currentTitle ?? "",
                        contentType: meditationVM.contentType ?? .meditation,
                        isPlaying: meditationVM.playbackState == .playing,
                        isBuffering: meditationVM.playbackState == .buffering,
                        progress: meditationVM.duration > 0 ? meditationVM.currentPosition / meditationVM.duration : 0,
                        coverUrl: meditationVM.currentCoverUrl,
                        onTogglePlayPause: { meditationVM.togglePlayPause() },
                        onDismiss: { meditationVM.stop() },
                        onClick: { handleMiniPlayerTap() }
                    )
                    .offset(y: miniPlayerDragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                miniPlayerDragOffset = value.translation.height
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 100
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    if miniPlayerAtTop && value.translation.height > threshold {
                                        miniPlayerAtTop = false
                                    } else if !miniPlayerAtTop && value.translation.height < -threshold {
                                        miniPlayerAtTop = true
                                    }
                                    miniPlayerDragOffset = 0
                                }
                            }
                    )
                    .padding(.bottom, miniPlayerAtTop ? 0 : 49)
                    .padding(.top, miniPlayerAtTop ? 4 : 0)

                    if miniPlayerAtTop { Spacer() }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showMiniPlayer)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: miniPlayerAtTop)
    }
}
