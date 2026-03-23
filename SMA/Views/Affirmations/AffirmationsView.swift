import SwiftUI

private struct CardStyle {
    let imageName: String
    let bgColor: Color
}

private let cardStyles: [CardStyle] = [
    CardStyle(imageName: "card_bg_1", bgColor: Color(hex: "F0E8E0")),
    CardStyle(imageName: "card_bg_2", bgColor: Color(hex: "EDE6E8")),
    CardStyle(imageName: "card_bg_3", bgColor: Color(hex: "E8E0F0")),
    CardStyle(imageName: "card_bg_4", bgColor: Color(hex: "E8E0D8")),
    CardStyle(imageName: "card_bg_5", bgColor: Color(hex: "ECE4E0")),
    CardStyle(imageName: "card_bg_6", bgColor: Color(hex: "F0E8EC")),
    CardStyle(imageName: "card_bg_7", bgColor: Color(hex: "E8E0E8")),
    CardStyle(imageName: "card_bg_8", bgColor: Color(hex: "E8E0F0")),
    CardStyle(imageName: "card_bg_9", bgColor: Color(hex: "F0ECE8")),
    CardStyle(imageName: "card_bg_10", bgColor: Color(hex: "ECE4E8")),
]

struct AffirmationsView: View {
    @State private var currentPage = 0
    private let affirmations = AffirmationContent.feed()
    
    var body: some View {
        let currentStyle = cardStyles[currentPage % cardStyles.count]
        
        ZStack {
            // Crossfade background
            GeometryReader { geo in
                Image(currentStyle.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.5)
            }
            .ignoresSafeArea()
            
            currentStyle.bgColor.opacity(0.45)
                .ignoresSafeArea()
            
            // Vertical pager
            TabView(selection: $currentPage) {
                ForEach(Array(affirmations.enumerated()), id: \.element.id) { index, affirmation in
                    let style = cardStyles[index % cardStyles.count]
                    
                    VStack {
                        Spacer().frame(height: 80)
                        
                        ZStack {
                            Image(style.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 480)
                                .frame(maxWidth: .infinity)
                                .clipped()
                            
                            // Radial frost
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.65),
                                    Color.white.opacity(0.50),
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 300
                            )
                            
                            VStack {
                                Spacer()
                                
                                let len = affirmation.text.count
                                let fontSize: CGFloat = len < 60 ? 26 : len < 120 ? 22 : len < 200 ? 18 : 16
                                
                                Text(affirmation.text)
                                    .font(.custom("PlayfairDisplay-Regular", size: fontSize))
                                    .foregroundColor(Color(hex: "2A2A3A"))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(8)
                                    .padding(.horizontal, 28)
                                
                                Spacer()
                                
                                // Like + Share
                                HStack(spacing: 32) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "2A2A3A").opacity(0.5))
                                    
                                    ShareLink(item: affirmation.text) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "2A2A3A").opacity(0.5))
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                            .frame(height: 480)
                            .padding(.horizontal, 28)
                        }
                        .frame(height: 480)
                        .clipShape(RoundedRectangle(cornerRadius: 36))
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .animation(.easeInOut(duration: 0.6), value: currentPage)
    }
}
