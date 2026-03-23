import SwiftUI

// MARK: - Mood → LifeArea mapping

private enum MeditationMood: String, CaseIterable {
    case calm, energy, love, release, transform, protection

    var translationKey: String {
        switch self {
        case .calm: return "moodCalm"
        case .energy: return "moodEnergy"
        case .love: return "moodLove"
        case .release: return "moodRelease"
        case .transform: return "moodTransform"
        case .protection: return "moodProtection"
        }
    }

    var areas: [LifeArea] {
        switch self {
        case .calm:      return [.calm, .body]
        case .energy:    return [.confidence, .career]
        case .love:      return [.love, .feminineEnergy]
        case .release:   return [.fear, .relationships]
        case .transform: return [.money, .career]
        case .protection: return [.selfWorth, .body]
        }
    }

    var color: Color {
        switch self {
        case .calm:       return Color(hex: "7EC8E3")
        case .energy:     return Color(hex: "FFB347")
        case .love:       return Color(hex: "FF7A9A")
        case .release:    return Color(hex: "80D4FF")
        case .transform:  return Color(hex: "B39DFF")
        case .protection: return Color(hex: "7FFFD4")
        }
    }
}

// Bubble layout data: relative x, y position (0..1) and diameter
private struct BubbleLayout {
    let relX: CGFloat
    let relY: CGFloat
    let size: CGFloat
}

private let moodBubbleLayouts: [BubbleLayout] = [
    BubbleLayout(relX: 0.22, relY: 0.06, size: 120),  // Calm
    BubbleLayout(relX: 0.68, relY: 0.02, size: 135),   // Energy
    BubbleLayout(relX: 0.12, relY: 0.28, size: 130),   // Love
    BubbleLayout(relX: 0.58, relY: 0.24, size: 115),   // Release
    BubbleLayout(relX: 0.35, relY: 0.50, size: 140),   // Transform
    BubbleLayout(relX: 0.75, relY: 0.48, size: 110),   // Protection
]

private let showAllBubbleLayout = BubbleLayout(relX: 0.20, relY: 0.72, size: 130)

// MARK: - Main View

struct MeditationsView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @State private var selectedMood: MeditationMood?
    @State private var selectedMeditation: Meditation?
    @State private var showList = false

    private let cardImages = ["card_bg_1", "card_bg_2", "card_bg_3", "card_bg_4", "card_bg_5",
                               "card_bg_6", "card_bg_7", "card_bg_8", "card_bg_9", "card_bg_10"]

    var body: some View {
        if let meditation = selectedMeditation {
            MeditationPlayerView(meditation: meditation, viewModel: viewModel) {
                selectedMeditation = nil
            }
        } else if showList {
            meditationListView
        } else {
            bubbleDiscoveryView
        }
    }

    private var filteredMeditations: [Meditation] {
        guard let mood = selectedMood else {
            return viewModel.allMeditations()
        }
        return mood.areas.flatMap { viewModel.meditationsForArea($0) }
    }

    // MARK: - Bubble Discovery

    private var bubbleDiscoveryView: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(Translations.ui("meditationsTitle"))
                        .font(AppTypography.headingLarge)
                        .foregroundColor(.white)
                    Text(Translations.ui("moodQuestion"))
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white.opacity(0.55))
                }
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Bubbles area
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    ZStack {
                        // Mood bubbles
                        ForEach(Array(MeditationMood.allCases.enumerated()), id: \.element) { index, mood in
                            let layout = moodBubbleLayouts[index]
                            let count = mood.areas.flatMap { viewModel.meditationsForArea($0) }.count

                            MoodCircleBubble(
                                label: Translations.ui(mood.translationKey),
                                count: count,
                                color: mood.color,
                                size: layout.size,
                                index: index
                            ) {
                                selectedMood = mood
                                withAnimation(.easeInOut(duration: 0.3)) { showList = true }
                            }
                            .position(
                                x: layout.relX * w,
                                y: layout.relY * h
                            )
                        }

                        // Show All bubble
                        let allCount = viewModel.allMeditations().count
                        MoodCircleBubble(
                            label: Translations.ui("moodShowAll"),
                            count: allCount,
                            color: .white,
                            size: showAllBubbleLayout.size,
                            index: MeditationMood.allCases.count
                        ) {
                            selectedMood = nil
                            withAnimation(.easeInOut(duration: 0.3)) { showList = true }
                        }
                        .position(
                            x: showAllBubbleLayout.relX * w,
                            y: showAllBubbleLayout.relY * h
                        )
                    }
                }
            }
        }
    }

    // MARK: - Meditation List

    private var meditationListView: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { showList = false }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text(selectedMood.map { Translations.ui($0.translationKey) } ?? Translations.ui("moodShowAll"))
                        .font(AppTypography.headingMedium)
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 54)

                // Meditation count
                Text("\(filteredMeditations.count) \(Translations.ui("meditationsCountLabel"))")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 4)

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
                                cardImage: cardImages[index % cardImages.count],
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

// MARK: - Mood Circle Bubble

private struct MoodCircleBubble: View {
    let label: String
    let count: Int
    let color: Color
    let size: CGFloat
    let index: Int
    let onTap: () -> Void

    @State private var appeared = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer circle with color border
                Circle()
                    .fill(color.opacity(0.08))
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.35), lineWidth: 1.5)
                    )

                // Content
                VStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: size > 130 ? 18 : 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("\(count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 12)
            }
            .frame(width: size, height: size)
        }
        .scaleEffect(appeared ? 1 : 0.3)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.08)) {
                appeared = true
            }
        }
    }
}

// MARK: - Visual Card

private struct MeditationVisualCard: View {
    let meditation: Meditation
    let isActive: Bool
    let isPlaying: Bool
    let cardImage: String
    let areaColor: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image
            Image(cardImage)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            // Color tint + dark gradient overlay
            LinearGradient(
                colors: [areaColor.opacity(0.25), areaColor.opacity(0.1), .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Top badges
            VStack {
                HStack {
                    // Area badge
                    Text(Translations.lifeAreaLabel(meditation.area))
                        .font(AppTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.4))
                        .clipShape(Capsule())

                    Spacer()

                    // Duration badge
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
                        .font(.system(size: 18, weight: .bold))
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

                Spacer()

                // Play button
                Circle()
                    .fill(.white.opacity(isActive ? 0.35 : 0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isActive ? areaColor.opacity(0.6) : .clear, lineWidth: 1.5)
        )
    }
}
