import SwiftUI

private let bgColor = Color(hex: "154C6C")
private let textPrimary = Color.white
private let textOnCard = Color(hex: "0A0A14")
private let textSecondary = Color(hex: "AAC8D8")

struct HomeView: View {
    @ObservedObject var savedProgramsVM: SavedProgramsViewModel
    @ObservedObject var meditationVM: MeditationViewModel
    var onNavigateToReprogram: () -> Void
    var onNavigateToMeditations: () -> Void
    var onMeditationTapped: (Meditation) -> Void = { _ in }
    var onMoodBubbleTapped: (String) -> Void = { _ in }

    @State private var showAffirmations = false
    @State private var affirmationStartText: String? = nil
    @State private var currentAffirmationPage: Int? = 0
    @State private var showClubsMap = false
    @State private var clubsVM = ClubsViewModel()
    @State private var randomAffirmation: Affirmation? = nil

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

    @ViewBuilder
    private func localMeditationImage(_ id: String, index: Int) -> some View {
        if let gif = meditationGifName(id) {
            GIFView(gifName: gif)
                .frame(width: 200, height: 160)
                .clipped()
        } else {
            Image(meditationCardImage(id, index: index))
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 160)
                .clipped()
        }
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return Translations.ui("greetingMorning")
        } else if hour < 18 {
            return Translations.ui("greetingDay")
        } else {
            return Translations.ui("greetingEvening")
        }
    }

    var body: some View {
        let popularMeditations = meditationVM.allMeditations().filter { med in
            Translations.popularMeditations().contains { $0.id == med.id }
        }

        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ── Compact header: portrait + school name + greeting ─────
                    HStack(spacing: 12) {
                        Image("mikhail_portrait")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Школа Михаила Агеева")
                                .font(AppTypography.bodySmall)
                                .foregroundColor(.white.opacity(0.7))

                            Text(timeGreeting)
                                .font(AppTypography.headingMedium)
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                    // ── Affirmation hero card (single random) ────────────────
                    if let affirmation = randomAffirmation {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Translations.ui("homeDailyAffirmation"))
                                .font(AppTypography.headingSmall)
                                .foregroundColor(textPrimary)
                                .padding(.horizontal, 24)

                            ZStack {
                                GIFView(gifName: "bg_affirmation_card")
                                Color.black.opacity(0.35)
                                Text(affirmation.text)
                                    .font(.custom("PlayfairDisplay-Medium", size: 22))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 24)
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.44)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .padding(.horizontal, 24)
                            .onTapGesture {
                                affirmationStartText = affirmation.text
                                showAffirmations = true
                            }
                        }
                        .padding(.top, 24)
                    }

                    // ── Popular meditations ──────────────────────────────────
                    if !popularMeditations.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Translations.ui("homeMeditations"))
                                .font(AppTypography.headingSmall)
                                .foregroundColor(textPrimary)
                                .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(popularMeditations.enumerated()), id: \.element.id) { index, meditation in
                                        PopularMeditationCard(meditation: meditation, index: index)
                                            .onTapGesture { onMeditationTapped(meditation) }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.top, 32)
                    }

                    // ── Clubs map section ────────────────────────────────────
                    Group {
                        switch clubsVM.uiState {
                        case .loading:
                            ClubsMapSectionSkeleton()
                        case .success(let clubs, _):
                            if clubs.isEmpty {
                                ClubsMapSectionEmpty()
                            } else {
                                ClubsMapSection(
                                    clubs: clubs,
                                    onExpandMap: { showClubsMap = true }
                                )
                            }
                        case .error:
                            ClubsMapSectionError(onRetry: { clubsVM.fetch() })
                        }
                    }
                    .padding(.top, 32)

                    Spacer().frame(height: 140)
                }
            }
        }
        .fullScreenCover(isPresented: $showClubsMap) {
            ClubsMapScreen(
                clubs: clubsVM.clubs,
                isLoading: clubsVM.isLoading,
                onDismiss: { showClubsMap = false }
            )
        }
        .fullScreenCover(isPresented: $showAffirmations) {
            ZStack(alignment: .topLeading) {
                AffirmationsView(startText: affirmationStartText)
                Button {
                    showAffirmations = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.top, 56)
                .padding(.leading, 20)
            }
        }
        .onAppear {
            if randomAffirmation == nil {
                randomAffirmation = AffirmationContent.feed().randomElement()
            }
        }
    }
}

// MARK: - Home Mood Bubbles

private struct HomeMoodBubbleData {
    let translationKey: String
    let color: Color
}

private let homeMoodBubbles: [HomeMoodBubbleData] = [
    HomeMoodBubbleData(translationKey: "moodCalm", color: Color(hex: "A8D8EA")),
    HomeMoodBubbleData(translationKey: "moodEnergy", color: Color(hex: "E0C8A0")),
    HomeMoodBubbleData(translationKey: "moodLove", color: Color(hex: "D4A0BE")),
    HomeMoodBubbleData(translationKey: "moodRelease", color: Color(hex: "8EC8DC")),
    HomeMoodBubbleData(translationKey: "moodTransform", color: Color(hex: "B8A8D8")),
    HomeMoodBubbleData(translationKey: "moodProtection", color: Color(hex: "A0D4C4")),
    HomeMoodBubbleData(translationKey: "moodShowAll", color: Color(hex: "B0C8D8"))
]

private struct HomeMoodBubblesRow: View {
    let onMoodTapped: (String) -> Void

    private let bubbleDp: CGFloat = 130
    private var radius: CGFloat { bubbleDp / 2 }
    private var stepX: CGFloat { bubbleDp }
    private var stepY: CGFloat { bubbleDp * 0.86 }

    private var topRow: [HomeMoodBubbleData] {
        homeMoodBubbles.enumerated().filter { $0.offset % 2 == 0 }.map(\.element)
    }
    private var bottomRow: [HomeMoodBubbleData] {
        homeMoodBubbles.enumerated().filter { $0.offset % 2 != 0 }.map(\.element)
    }

    private var totalWidth: CGFloat {
        CGFloat(topRow.count) * stepX + radius + 16
    }
    private var totalHeight: CGFloat {
        bubbleDp + stepY
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                // Invisible spacer to define the scrollable size
                Color.clear
                    .frame(width: totalWidth, height: totalHeight)

                // Top row — position() uses center point
                ForEach(Array(topRow.enumerated()), id: \.offset) { col, mood in
                    HomeMoodBubble(
                        label: Translations.ui(mood.translationKey),
                        color: mood.color,
                        size: bubbleDp,
                        index: col * 2,
                        onTap: { onMoodTapped(mood.translationKey) }
                    )
                    .position(
                        x: CGFloat(col) * stepX + radius,
                        y: radius
                    )
                }
                // Bottom row — shifted right by half step
                ForEach(Array(bottomRow.enumerated()), id: \.offset) { col, mood in
                    HomeMoodBubble(
                        label: Translations.ui(mood.translationKey),
                        color: mood.color,
                        size: bubbleDp,
                        index: col * 2 + 1,
                        onTap: { onMoodTapped(mood.translationKey) }
                    )
                    .position(
                        x: CGFloat(col) * stepX + bubbleDp,
                        y: stepY + radius
                    )
                }
            }
            .frame(width: totalWidth, height: totalHeight)
            .padding(.horizontal, 8)
        }
    }
}

private struct HomeMoodBubble: View {
    let label: String
    let color: Color
    let size: CGFloat
    let index: Int
    let onTap: () -> Void

    @State private var appeared = false
    @State private var drifting = false
    @State private var glowing = false

    private var glowSize: CGFloat { size * 1.25 }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.35), Color.white.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: glowSize / 2
                    )
                )
                .frame(width: glowSize, height: glowSize)
                .opacity(glowing ? 0.6 : 0.3)

            // Main bubble
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    color.opacity(0.2),
                                    Color.white.opacity(0.12)
                                ],
                                center: UnitPoint(x: 0.35, y: 0.3),
                                startRadius: 0,
                                endRadius: size / 2
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )

                    Text(label)
                        .font(.system(size: size * 0.14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(appeared ? (drifting ? 1.02 : 0.98) : 0.3)
        .opacity(appeared ? 1 : 0)
        .offset(
            x: drifting ? CGFloat(4 - (index % 3) * 3) : CGFloat(-4 + (index % 3) * 3),
            y: drifting ? CGFloat(3 - (index % 2) * 4) : CGFloat(-3 + (index % 2) * 4)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(Double(index) * 0.08)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.4 + Double(index) * 0.6).repeatForever(autoreverses: true)) {
                drifting = true
            }
            withAnimation(.easeInOut(duration: 2.2 + Double(index) * 0.4).repeatForever(autoreverses: true)) {
                glowing = true
            }
        }
    }
}

// MARK: - Popular Meditation Card with dominant color

private struct PopularMeditationCard: View {
    let meditation: Meditation
    let index: Int

    private var coverUrl: String? { MeditationContent.coverURL(meditation) }

    private var dominantColor: Color {
        if let hex = MeditationContent.coverColor(meditation), !hex.isEmpty {
            return Color(hex: String(hex.dropFirst()))
        }
        return areaColor(meditation.area)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let urlString = coverUrl, let url = URL(string: urlString) {
                CachedAsyncImage(url: url)
                    .frame(width: 200, height: 160)
                    .clipped()
            } else {
                dominantColor
            }

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .clear, location: 0.55),
                    .init(color: gradientColor.opacity(0.7), location: 0.7),
                    .init(color: gradientColor.opacity(0.95), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(meditation.title)
                    .font(AppTypography.headingSmall)
                    .foregroundColor(.white)
                    .lineLimit(2)
                Text("\(meditation.durationSeconds / 60) \(Translations.ui("minutesShort"))")
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
        }
        .frame(width: 200, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var gradientColor: Color { dominantColor }

    @ViewBuilder
    private var fallbackImage: some View {
        Image(meditationImageOverrides[meditation.id] ?? "card_bg_\((index % 10) + 1)")
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 160)
            .clipped()
    }

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

}
