import SwiftUI

struct MeditationCardsView: View {
    @State private var messages = MeditationMessage.sampleMessages

    var body: some View {
        ZStack {
            // Background color for status bar area
            Color(red: 0.25, green: 0.25, blue: 0.28)
                .ignoresSafeArea()

            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(messages) { message in
                        ZStack {
                            // Darker gradient background
                            LinearGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.25, blue: 0.28),
                                    Color(red: 0.18, green: 0.18, blue: 0.20),
                                    Color(red: 0.12, green: 0.12, blue: 0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()

                            ParticlesView()

                            // Centered text
                            MeditationCard(message: message)
                        }
                        .containerRelativeFrame([.horizontal, .vertical])
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct MeditationCard: View {
    let message: MeditationMessage

    var body: some View {
        Text(message.text)
            .font(.system(size: 36, weight: .regular))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
    }
}
