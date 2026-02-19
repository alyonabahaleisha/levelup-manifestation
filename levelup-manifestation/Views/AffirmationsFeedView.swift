import SwiftUI

struct AffirmationsFeedView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var affirmations: [Affirmation] = Affirmation.feed()
    @State private var selectedArea: LifeArea? = nil
    @State private var likedIds: Set<UUID> = []

    var body: some View {
        ZStack(alignment: .top) {
            // Paging feed
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(affirmations) { affirmation in
                        AffirmationCard(
                            affirmation: affirmation,
                            isLiked: likedIds.contains(affirmation.id),
                            onLike: { toggleLike(affirmation) }
                        )
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
        .onChange(of: selectedArea) { _, area in
            withAnimation(.easeInOut(duration: 0.3)) {
                affirmations = Affirmation.feed(for: area.map { [$0] } ?? [])
            }
        }
        .onChange(of: theme.tone) { _, _ in
            // Re-shuffle when tone changes for fresh feel
            affirmations = Affirmation.feed(for: selectedArea.map { [$0] } ?? [])
        }
    }

    private func toggleLike(_ affirmation: Affirmation) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            if likedIds.contains(affirmation.id) {
                likedIds.remove(affirmation.id)
            } else {
                likedIds.insert(affirmation.id)
            }
        }
    }
}

// MARK: - Affirmation Card

struct AffirmationCard: View {
    @EnvironmentObject var theme: ThemeManager
    let affirmation: Affirmation
    let isLiked: Bool
    let onLike: () -> Void

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

                // Area pill — top center
                Text("\(affirmation.area.emoji)  \(affirmation.area.rawValue)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .glassChip()
                    .padding(.bottom, 28)

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
                    .shadow(color: theme.tone.glowColor, radius: 30, x: 0, y: 0)

                Spacer()

                // Like button
                HStack {
                    Spacer()
                    Button(action: onLike) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(isLiked ? Color.pink : .white.opacity(0.55))
                            .scaleEffect(isLiked ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.45), value: isLiked)
                    }
                    .padding(.trailing, 32)
                }
                .padding(.bottom, 140)
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
