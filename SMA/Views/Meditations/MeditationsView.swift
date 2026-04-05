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
        } else {
            meditationListView
                .onChange(of: pendingMeditation) { _, meditation in
                    if let meditation {
                        selectedMeditation = meditation
                        openedFromHome = true
                        pendingMeditation = nil
                    }
                }
                .onAppear {
                    if let meditation = pendingMeditation {
                        selectedMeditation = meditation
                        openedFromHome = true
                        pendingMeditation = nil
                    }
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
                Text(headerTitle)
                    .font(AppTypography.headingLarge)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 4)

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
                                cardImage: meditationCardImage(meditation.id, index: index),
                                gifName: meditationGifName(meditation.id),
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
    let cardImage: String
    var gifName: String? = nil
    var coverUrl: String? = nil
    let areaColor: Color

    @State private var dominantColor: Color = Color(hex: "0E3448")

    private var coverColorFromFirestore: Color? {
        guard let hex = MeditationContent.coverColor(meditation), !hex.isEmpty else { return nil }
        return Color(hex: String(hex.dropFirst())) // remove #
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image: prefer remote coverUrl, fall back to local asset/GIF
            if let urlString = coverUrl, let url = URL(string: urlString) {
                GeometryReader { geo in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(width: geo.size.width, height: 260)
                                .clipped()
                        case .failure:
                            localImage
                        case .empty:
                            dominantColor
                        @unknown default:
                            dominantColor
                        }
                    }
                }
                .frame(height: 260)
                .clipped()
            } else {
                localImage
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
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isActive ? areaColor.opacity(0.6) : .clear, lineWidth: 1.5)
        )
        .onAppear {
            if let color = coverColorFromFirestore {
                dominantColor = color
            } else if let uiImage = UIImage(named: cardImage) {
                extractDominantColor(from: uiImage) { color in
                    dominantColor = color
                }
            }
        }
    }

    private func extractRemoteColor(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url),
                  let uiImage = UIImage(data: data),
                  let cgImage = uiImage.cgImage else { return }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var pixel: [UInt8] = [0, 0, 0, 0]
            guard let context = CGContext(
                data: &pixel, width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return }
            let h = cgImage.height
            let cropRect = CGRect(x: 0, y: h * 2 / 3, width: cgImage.width, height: h / 3)
            guard let cropped = cgImage.cropping(to: cropRect) else { return }
            context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            let r = CGFloat(pixel[0]) / 255.0 * 0.55
            let g = CGFloat(pixel[1]) / 255.0 * 0.55
            let b = CGFloat(pixel[2]) / 255.0 * 0.55
            DispatchQueue.main.async { dominantColor = Color(red: r, green: g, blue: b) }
        }
    }

    @ViewBuilder
    private var localImage: some View {
        if let gif = gifName {
            GIFView(gifName: gif)
                .frame(height: 260)
                .clipped()
        } else {
            Image(cardImage)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()
        }
    }
}

private func extractDominantColor(from uiImage: UIImage, completion: @escaping (Color) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let ciImage = CIImage(image: uiImage) else { return }
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ])
        guard let outputImage = filter?.outputImage else { return }
        var bitmap = [UInt8](repeating: 0, count: 4)
        CIContext().render(outputImage, toBitmap: &bitmap, rowBytes: 4,
                           bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                           format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        let r = CGFloat(bitmap[0]) / 255.0 * 0.55
        let g = CGFloat(bitmap[1]) / 255.0 * 0.55
        let b = CGFloat(bitmap[2]) / 255.0 * 0.55
        DispatchQueue.main.async {
            completion(Color(red: r, green: g, blue: b))
        }
    }
}
