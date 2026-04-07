import SwiftUI

// MARK: - Main View

private let moodAreaMapping: [String: [LifeArea]] = [
    "moodCalm": [.calm, .body],
    "moodEnergy": [.confidence, .career],
    "moodLove": [.love, .feminineEnergy],
    "moodRelease": [.fear, .relationships],
    "moodTransform": [.money, .career],
    "moodProtection": [.selfWorth, .body]
]

struct MeditationsView: View {
    @ObservedObject var viewModel: MeditationViewModel
    var initialMoodKey: String? = nil
    @Binding var pendingMeditation: Meditation?
    var onNavigateToHome: (() -> Void)? = nil
    @Binding var isMeditationPlayerOpen: Bool
    @State private var selectedMeditation: Meditation?
    @State private var openedFromHome = false

    private let cardImages = ["card_bg_1", "card_bg_2", "card_bg_3", "card_bg_4", "card_bg_5",
                               "card_bg_6", "card_bg_7", "card_bg_8", "card_bg_9", "card_bg_10"]

    private let meditationImageOverrides: [String: String] = [
        "abundance": "med_abundance",
        "karmic_release": "med_karmic_release",
        "return_to_self": "med_return_to_self",
        "return_to_self_2": "med_return_to_self",
        "chakra_harmony": "med_chakra_harmony",
        "chakra_harmony_2": "med_chakra_harmony",
        "harmonize_life": "med_harmonize_life",
        "create_reality": "med_create_reality",
        "angel_activation": "med_angel_activation",
        "subtle_bodies": "med_subtle_bodies",
        "cleansing": "med_cleansing"
    ]

    private let meditationGifOverrides: Set<String> = []

    private func meditationCardImage(_ id: String, index: Int) -> String {
        meditationImageOverrides[id] ?? cardImages[index % cardImages.count]
    }

    private func meditationGifName(_ id: String) -> String? {
        meditationGifOverrides.contains(id) ? "med_\(id)" : nil
    }

    var body: some View {
        ZStack {
            meditationListView
                .onChange(of: pendingMeditation) { _, meditation in
                    if let meditation {
                        selectedMeditation = meditation
                        openedFromHome = true
                        pendingMeditation = nil
                    }
                }
                .onChange(of: selectedMeditation) { _, newValue in
                    isMeditationPlayerOpen = newValue != nil
                }
                .onAppear {
                    if let meditation = pendingMeditation {
                        selectedMeditation = meditation
                        openedFromHome = true
                        pendingMeditation = nil
                    }
                }

            if let meditation = selectedMeditation {
                MeditationPlayerView(
                    meditation: meditation,
                    viewModel: viewModel,
                    cardImage: meditationCardImage(meditation.id, index: 0),
                    gifName: meditationGifName(meditation.id),
                    coverUrl: MeditationContent.coverURL(meditation),
                    onBack: {
                        selectedMeditation = nil
                        if openedFromHome {
                            openedFromHome = false
                            onNavigateToHome?()
                        }
                    }
                )
                .toolbar(.hidden, for: .tabBar)
            }
        }
    }

    private var allMeditations: [Meditation] {
        let raw = viewModel.allMeditations()
        var seen = Set<String>()
        return raw.filter { seen.insert($0.fileName).inserted }
    }

    private var filteredMeditations: [Meditation] {
        guard let key = initialMoodKey, let areas = moodAreaMapping[key] else {
            return allMeditations
        }
        return allMeditations.filter { areas.contains($0.area) }
    }

    private var headerTitle: String {
        if let key = initialMoodKey, moodAreaMapping[key] != nil {
            return Translations.ui(key)
        }
        return Translations.ui("meditationsTitle")
    }

    // MARK: - Meditation List

    private var meditationListView: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(headerTitle)
                        .font(AppTypography.headingLarge)
                        .foregroundColor(.white)

                    Text("\(filteredMeditations.count) \(Translations.ui("meditationsCountLabel"))")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 4)

                // Meditation list
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(Array(filteredMeditations.enumerated()), id: \.element.id) { index, meditation in
                            let isActive = viewModel.currentMeditationId == meditation.id
                            let isPlaying = isActive && viewModel.playbackState == .playing

                            MeditationVisualCard(
                                meditation: meditation,
                                isActive: isActive,
                                isPlaying: isPlaying,
                                coverUrl: MeditationContent.coverURL(meditation),
                                areaColor: areaColor(meditation.area)
                            )
                            .onTapGesture { selectedMeditation = meditation }
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

// MARK: - Visual Card

private struct MeditationVisualCard: View {
    let meditation: Meditation
    let isActive: Bool
    let isPlaying: Bool
    var coverUrl: String? = nil
    let areaColor: Color

    @State private var dominantColor: Color = Color(hex: "0E3448")

    private var coverColorFromFirestore: Color? {
        guard let hex = MeditationContent.coverColor(meditation), !hex.isEmpty else { return nil }
        return Color(hex: String(hex.dropFirst())) // remove #
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image: remote coverUrl with color placeholder
            if let urlString = coverUrl, let url = URL(string: urlString) {
                GeometryReader { geo in
                    CachedAsyncImage(url: url)
                        .frame(width: geo.size.width, height: 260)
                        .clipped()
                }
                .frame(height: 260)
                .clipped()
            } else {
                dominantColor
            }

            // Color gradient overlay — intense bottom third
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .clear, location: 0.55),
                    .init(color: dominantColor.opacity(0.7), location: 0.7),
                    .init(color: dominantColor.opacity(0.95), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Top row: duration badge (right)
            VStack {
                HStack {
                    Spacer()

                    Text("\(meditation.durationSeconds / 60) \(Translations.ui("minutesShort"))")
                        .font(AppTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.4))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()
            }

            // Bottom content
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meditation.title)
                        .font(AppTypography.headingMedium)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                        .lineLimit(2)

                    if !meditation.description.isEmpty {
                        Text(meditation.description)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            .lineLimit(2)
                    }
                }

            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isActive ? areaColor.opacity(0.6) : .clear, lineWidth: 1.5)
        )
        .onAppear {
            if let color = coverColorFromFirestore {
                dominantColor = color
            }
        }
    }

}

