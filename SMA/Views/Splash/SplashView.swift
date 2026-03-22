import SwiftUI

struct SplashView: View {
    @State private var logoVisible = false
    @State private var nameVisible = false
    @State private var taglineVisible = false
    
    var body: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image("logo_ageev")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .opacity(logoVisible ? 1 : 0)
                    .scaleEffect(logoVisible ? 1 : 0.85)
                
                Spacer().frame(height: 28)
                
                Text("Школа Михаила Агеева")
                    .font(AppTypography.headingLarge)
                    .foregroundColor(.white)
                    .opacity(nameVisible ? 1 : 0)
                
                Spacer().frame(height: 12)
                
                Text(Translations.ui("splashTagline"))
                    .font(AppTypography.bodySmall)
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(taglineVisible ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8).delay(0.2)) { logoVisible = true }
            withAnimation(.easeIn(duration: 0.7).delay(0.6)) { nameVisible = true }
            withAnimation(.easeIn(duration: 0.6).delay(0.9)) { taglineVisible = true }
        }
    }
}
