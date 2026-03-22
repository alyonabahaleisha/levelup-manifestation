import SwiftUI

private let bgColor = Color(hex: "154C6C")
private let textPrimary = Color.white
private let textOnCard = Color(hex: "0A0A14")
private let textSecondary = Color(hex: "AAC8D8")

struct HomeView: View {
    @ObservedObject var savedProgramsVM: SavedProgramsViewModel
    @ObservedObject var meditationVM: MeditationViewModel
    var onNavigateToAffirmations: () -> Void
    var onNavigateToReprogram: () -> Void
    var onNavigateToMeditations: () -> Void
    
    private let cardImages = ["card_bg_1", "card_bg_2", "card_bg_3", "card_bg_4", "card_bg_5",
                               "card_bg_6", "card_bg_7", "card_bg_8", "card_bg_9", "card_bg_10"]
    
    var body: some View {
        let topAffirmations = AffirmationContent.feed().prefix(10).map { $0 }
        let allMeditations = meditationVM.allMeditations()
        let totalPerArea = Dictionary(uniqueKeysWithValues: LifeArea.allCases.map { ($0, ProgramContent.programs($0).count) })
        
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image
                    ZStack(alignment: .bottomLeading) {
                        Image("bg_home_top")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 340)
                            .clipped()
                        
                        LinearGradient(colors: [.clear, bgColor], startPoint: .top, endPoint: .bottom)
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Translations.ui("homeGreeting"))
                                .font(AppTypography.headingLarge)
                                .foregroundColor(.white)
                            Text("Школа Михаила Агеева")
                                .font(AppTypography.bodySmall)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .frame(height: 340)
                    
                    // Affirmation pager
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Провозглашение дня")
                            .font(AppTypography.headingSmall)
                            .foregroundColor(textPrimary)
                            .padding(.horizontal, 24)
                        
                        TabView {
                            ForEach(Array(topAffirmations.enumerated()), id: \.element.id) { index, affirmation in
                                ZStack {
                                    Image(cardImages[index % cardImages.count])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 280)
                                        .clipped()
                                    
                                    Color.white.opacity(0.55)
                                    
                                    Text(affirmation.text)
                                        .font(.custom("PlayfairDisplay-Medium", size: 16))
                                        .foregroundColor(textOnCard)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(8)
                                        .padding(24)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                                .padding(.horizontal, 32)
                                .onTapGesture { onNavigateToAffirmations() }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 300)
                    }
                    .padding(.top, 16)
                    
                    // Reprogram section
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
                    .padding(.top, 56)
                    
                    // Meditations section
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
                    .padding(.top, 56)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
