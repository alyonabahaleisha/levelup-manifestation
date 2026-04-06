import SwiftUI

private let cardBlue = Color(hex: "154C6C")

struct AffirmationsView: View {
    @State private var affirmations: [Affirmation] = []
    
    var body: some View {
        ZStack {
            cardBlue.ignoresSafeArea()

            // Vertical pager
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(affirmations.enumerated()), id: \.element.id) { index, affirmation in
                        GeometryReader { geo in
                            let len = affirmation.text.count
                            let fontSize: CGFloat = len < 60 ? 26 : len < 120 ? 22 : len < 200 ? 18 : 16

                            VStack {
                                Spacer()

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
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(cardBlue.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 36))
                        }
                        .containerRelativeFrame(.vertical)
                        .padding(.horizontal, 24)
                        .id(index)
                    }
                }
            }
            .scrollTargetBehavior(.paging)
        }
        .onAppear {
            if affirmations.isEmpty {
                affirmations = AffirmationContent.feed()
            }
        }
    }
}
