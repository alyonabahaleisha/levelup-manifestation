import SwiftUI

struct AffirmationsFeedView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var savedPrograms: SavedProgramsStore
    @State private var affirmations: [Affirmation] = []
    @State private var selectedArea: LifeArea? = nil

    var body: some View {
        ZStack(alignment: .top) {
            // Paging feed
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(affirmations) { affirmation in
                        AffirmationCard(affirmation: affirmation)
                            .containerRelativeFrame([.horizontal, .vertical])
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
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
                if affirmation.isPersonal {
                    Text("✦  Your Identity")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.tone.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .glassChip(isSelected: true, accentColor: theme.tone.accent)
                        .padding(.bottom, 28)
                } else {
                    Text("\(affirmation.area.emoji)  \(affirmation.area.rawValue)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .glassChip()
                        .padding(.bottom, 28)
                }

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

                Spacer()
            }
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

                ForEach(LifeArea.allCases) { area in
                    Button {
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
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
