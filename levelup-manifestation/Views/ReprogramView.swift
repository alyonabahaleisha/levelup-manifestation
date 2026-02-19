import SwiftUI

struct ReprogramView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedArea: LifeArea? = nil

    // Areas that have programs
    let availableAreas: [LifeArea] = [.money, .relationships, .selfWorth, .fear, .body, .career]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: theme.tone.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ParticlesView()

            if let area = selectedArea {
                HiddenProgramsListView(area: area, onBack: { selectedArea = nil })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                areaSelectionGrid
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedArea)
    }

    private var areaSelectionGrid: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Rewrite Your Programs")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(.white)
                Text("What area of life feels blocked?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(.top, 80)
            .padding(.bottom, 36)

            // Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(availableAreas) { area in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        selectedArea = area
                    } label: {
                        AreaCard(area: area)
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

// MARK: - Area Card

struct AreaCard: View {
    @EnvironmentObject var theme: ThemeManager
    let area: LifeArea

    var body: some View {
        VStack(spacing: 10) {
            Text(area.emoji)
                .font(.system(size: 36))
            Text(area.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassCard(cornerRadius: 20)
        .shadow(color: theme.tone.glowColor, radius: 16, x: 0, y: 0)
    }
}
