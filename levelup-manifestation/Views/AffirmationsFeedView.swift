import SwiftUI

// ANDROID: AffirmationsScreen.kt
//   val pagerState = rememberPagerState { affirmations.size }
//   VerticalPager(state = pagerState, modifier = Modifier.fillMaxSize()) { page ->
//       AffirmationCard(affirmation = affirmations[page])
//   }
//   LaunchedEffect(pagerState.currentPage) { haptics.performHapticFeedback(TextHandleMove) }
//   Floating filter bar: LazyRow at top of Box — same chip style as GlassChip
//   buildFeed() → same logic, observe savedPrograms.saved from SavedProgramsViewModel

struct AffirmationsFeedView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var savedPrograms: SavedProgramsStore
    @State private var affirmations: [Affirmation] = []
    @State private var selectedArea: LifeArea? = nil
    @State private var currentPage: UUID?

    var body: some View {
        ZStack(alignment: .top) {
            // Paging feed
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(affirmations) { affirmation in
                        AffirmationCard(affirmation: affirmation)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .id(affirmation.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentPage)
            .onChange(of: currentPage) { _, _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .ignoresSafeArea()

            // Floating filter bar
            LifeAreaFilterBar(selected: $selectedArea)
                .padding(.top, 60)
                .padding(.horizontal, 16)
        }
        .onAppear {
            affirmations = buildFeed(for: selectedArea)
        }
        .onChange(of: selectedArea) { _, area in
            withAnimation(.easeInOut(duration: 0.3)) {
                affirmations = buildFeed(for: area)
            }
        }
        .onChange(of: savedPrograms.saved.count) { _, _ in
            affirmations = buildFeed(for: selectedArea)
        }
        .onChange(of: theme.tone) { _, _ in
            affirmations = buildFeed(for: selectedArea)
        }
    }

    private func buildFeed(for area: LifeArea?) -> [Affirmation] {
        let areas = area.map { [$0] } ?? []
        let personal = areas.isEmpty
            ? savedPrograms.saved
            : savedPrograms.saved.filter { areas.contains($0.area) }
        let regular = Affirmation.feed(for: areas)
        return personal + regular
    }
}

// MARK: - Affirmation Card

struct AffirmationCard: View {
    @EnvironmentObject var theme: ThemeManager
    let affirmation: Affirmation
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: theme.tone.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Stars
            ParticlesView()

            VStack(spacing: 0) {
                Spacer()

                // Area / identity pill
                Group {
                    if affirmation.isPersonal {
                        Text("✦  Your Identity")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.tone.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .glassChip(isSelected: true, accentColor: theme.tone.accent)
                    } else {
                        Text("\(affirmation.area.emoji)  \(affirmation.area.rawValue)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .glassChip()
                    }
                }
                .padding(.bottom, 28)
                .offset(y: appeared ? 0 : 16)
                .opacity(appeared ? 1 : 0)

                // Glass affirmation card
                Text(affirmation.text)
                    .font(.system(size: 32, weight: .light))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 40)
                    .glassCard(cornerRadius: 28)
                    .padding(.horizontal, 24)
                    .shadow(
                        color: affirmation.isPersonal ? theme.tone.accent.opacity(0.4) : theme.tone.glowColor,
                        radius: affirmation.isPersonal ? 40 : 30,
                        x: 0, y: 0
                    )
                    .offset(y: appeared ? 0 : 24)
                    .opacity(appeared ? 1 : 0)

                Spacer()
            }
            .onAppear {
                appeared = false
                withAnimation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.05)) {
                    appeared = true
                }
            }
            .onDisappear { appeared = false }
        }
    }
}

// MARK: - Life Area Filter Bar

struct LifeAreaFilterBar: View {
    @EnvironmentObject var theme: ThemeManager
    @Binding var selected: LifeArea?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = nil
                    }
                } label: {
                    Text("✦  All")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glassChip(isSelected: selected == nil, accentColor: theme.tone.accent)
                }
                .pressable()

                ForEach(LifeArea.allCases) { area in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = selected == area ? nil : area
                        }
                    } label: {
                        Text("\(area.emoji)  \(area.rawValue)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassChip(isSelected: selected == area, accentColor: theme.tone.accent)
                    }
                    .pressable()
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
