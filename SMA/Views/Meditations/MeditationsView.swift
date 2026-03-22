import SwiftUI

struct MeditationsView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @State private var selectedArea: LifeArea?
    @State private var selectedMeditation: Meditation?
    
    var body: some View {
        if let meditation = selectedMeditation {
            MeditationPlayerView(meditation: meditation, viewModel: viewModel) {
                selectedMeditation = nil
            }
        } else {
            meditationBrowse
        }
    }
    
    private var meditationBrowse: some View {
        let meditations = selectedArea == nil ? viewModel.allMeditations() : viewModel.meditationsForArea(selectedArea!)
        
        return ZStack {
            Image("bg_meditations")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(Translations.ui("meditationsTitle"))
                        .font(AppTypography.headingLarge)
                        .foregroundColor(.white)
                    Text(Translations.ui("meditationsSubtitle"))
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white.opacity(0.55))
                }
                .padding(.top, 60)
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        GlassChip(isSelected: selectedArea == nil) {
                            Text(Translations.ui("allAreas"))
                                .font(AppTypography.labelMedium)
                                .foregroundColor(selectedArea == nil ? ToneTheme.default.accent : .white.opacity(0.6))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                        }
                        .onTapGesture { selectedArea = nil }
                        
                        ForEach(LifeArea.allCases, id: \.self) { area in
                            GlassChip(isSelected: selectedArea == area, accentColor: ToneTheme.default.accent) {
                                Text("\(area.emoji) \(Translations.lifeAreaLabel(area))")
                                    .font(AppTypography.labelMedium)
                                    .foregroundColor(selectedArea == area ? ToneTheme.default.accent : .white.opacity(0.6))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                            }
                            .onTapGesture { selectedArea = area }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                
                // Meditation list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(meditations) { meditation in
                            let isActive = viewModel.currentMeditationId == meditation.id
                            let isPlaying = isActive && viewModel.playbackState == .playing
                            
                            GlassCard(cornerRadius: 18) {
                                HStack(spacing: 14) {
                                    // Play button
                                    Circle()
                                        .fill(isActive ? ToneTheme.default.accent.opacity(0.2) : Color(hex: "2A2A3A").opacity(0.08))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                                .foregroundColor(isActive ? ToneTheme.default.accent : Color(hex: "5A5070"))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(meditation.title)
                                            .font(AppTypography.bodyLarge)
                                            .foregroundColor(Color(hex: "2A2A3A"))
                                        
                                        HStack(spacing: 4) {
                                            Text(Translations.lifeAreaLabel(meditation.area))
                                                .font(AppTypography.caption)
                                                .foregroundColor(Color(hex: "5A5070"))
                                            Text("·")
                                                .foregroundColor(Color(hex: "5A5070"))
                                            Text("\(meditation.durationSeconds / 60) \(Translations.ui("minutesShort"))")
                                                .font(AppTypography.caption)
                                                .foregroundColor(Color(hex: "5A5070").opacity(0.8))
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            .onTapGesture { selectedMeditation = meditation }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
