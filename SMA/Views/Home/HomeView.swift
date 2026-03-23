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

    @State private var showAffirmations = false
    @State private var currentAffirmationPage: Int? = 0

    private let cardImages = ["card_bg_1", "card_bg_2", "card_bg_3", "card_bg_4", "card_bg_5",
                               "card_bg_6", "card_bg_7", "card_bg_8", "card_bg_9", "card_bg_10"]

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
        let topAffirmations = AffirmationContent.feed().prefix(10).map { $0 }
        let allMeditations = meditationVM.allMeditations()
        let totalPerArea = Dictionary(uniqueKeysWithValues: LifeArea.allCases.map { ($0, ProgramContent.programs($0).count) })

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
                    .padding(.top, 16)

                    // ── Affirmation hero card ─────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Провозглашение дня")
                            .font(AppTypography.headingSmall)
                            .foregroundColor(textPrimary)
                            .padding(.horizontal, 24)

                        GeometryReader { geo in
                            let cardWidth = geo.size.width - 48
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 14) {
                                    ForEach(Array(topAffirmations.enumerated()), id: \.element.id) { index, affirmation in
                                        ZStack {
                                            GIFView(gifName: "bg_affirmation_card")
                                            Color.black.opacity(0.35)
                                            Text(affirmation.text)
                                                .font(.custom("PlayfairDisplay-Medium", size: 18))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .lineSpacing(6)
                                                .lineLimit(5)
                                                .padding(.horizontal, 28)
                                                .padding(.vertical, 24)
                                        }
                                        .frame(width: cardWidth, height: 260)
                                        .clipShape(RoundedRectangle(cornerRadius: 28))
                                        .onTapGesture { showAffirmations = true }
                                    }
                                }
                                .scrollTargetLayout()
                                .padding(.horizontal, 24)
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollPosition(id: $currentAffirmationPage)
                        }
                        .frame(height: 260)

                        // Page indicator dots below card
                        HStack(spacing: 6) {
                            ForEach(0..<topAffirmations.count, id: \.self) { i in
                                Circle()
                                    .fill(i == (currentAffirmationPage ?? 0) ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: i == (currentAffirmationPage ?? 0) ? 8 : 6,
                                           height: i == (currentAffirmationPage ?? 0) ? 8 : 6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 24)

                    // ── Meditations section ──────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Медитации")
                            .font(AppTypography.headingSmall)
                            .foregroundColor(textPrimary)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(allMeditations.enumerated()), id: \.element.id) { index, meditation in
                                    ZStack(alignment: .bottomLeading) {
                                        Image(cardImages[(index + 3) % cardImages.count])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 160)
                                            .clipped()

                                        LinearGradient(colors: [.clear, .black.opacity(0.45)], startPoint: .top, endPoint: .bottom)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(meditation.title)
                                                .font(AppTypography.bodyMedium)
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
                                    .onTapGesture { onNavigateToMeditations() }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 32)

                    // ── Reprogram section ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Программы для работы")
                            .font(AppTypography.headingSmall)
                            .foregroundColor(textPrimary)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(LifeArea.allCases, id: \.self) { area in
                                    let savedCount = savedProgramsVM.saved.filter { $0.area == area }.count
                                    let totalCount = totalPerArea[area] ?? 0

                                    VStack(spacing: 10) {
                                        Spacer()
                                        Text(Translations.lifeAreaLabel(area))
                                            .font(AppTypography.labelLarge)
                                            .foregroundColor(textOnCard)
                                        Text(savedCount > 0 ? "\(savedCount) / \(totalCount)" : "\(totalCount) программ")
                                            .font(AppTypography.caption)
                                            .foregroundColor(textSecondary)
                                        Spacer()
                                    }
                                    .frame(width: 120, height: 140)
                                    .background(
                                        LinearGradient(
                                            colors: [areaColor(area).opacity(0.25), areaColor(area).opacity(0.10)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                                    .onTapGesture { onNavigateToReprogram() }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showAffirmations) {
            ZStack(alignment: .topLeading) {
                AffirmationsView()
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
    }
}
