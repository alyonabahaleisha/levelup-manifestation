import SwiftUI

private let cardBlue = Color(hex: "154C6C")

struct AffirmationsView: View {
    var startText: String? = nil
    @State private var currentPage = 0
    @State private var affirmations: [Affirmation] = []
    
    var body: some View {
        ZStack {
            cardBlue.ignoresSafeArea()

            // Vertical pager
            TabView(selection: $currentPage) {
                ForEach(Array(affirmations.enumerated()), id: \.element.id) { index, affirmation in
                    VStack {
                        Spacer().frame(height: 80)

                        ZStack {
                            VStack {
                                Spacer()

                                let len = affirmation.text.count
                                let fontSize: CGFloat = len < 60 ? 26 : len < 120 ? 22 : len < 200 ? 18 : 16

                                Text(affirmation.text)
                                    .font(.custom("PlayfairDisplay-Regular", size: fontSize))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(8)
                                    .padding(.horizontal, 28)

                                Spacer()

                                // Like + Share
                                HStack(spacing: 32) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.5))

                                    ShareLink(item: affirmation.text) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                            .frame(height: 480)
                            .padding(.horizontal, 28)
                        }
                        .frame(height: 480)
                        .background(cardBlue.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 36))
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear {
            if affirmations.isEmpty {
                affirmations = AffirmationContent.feed()
            }
            if let text = startText,
               let idx = affirmations.firstIndex(where: { $0.text == text }) {
                currentPage = idx
            }
        }
    }
}
