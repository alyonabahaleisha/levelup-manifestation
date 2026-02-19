import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // Immediate dark background — prevents white flash between system launch screen and first SwiftUI render
            Color(red: 0.14, green: 0.05, blue: 0.14)
                .ignoresSafeArea()

            MainTabView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.7), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
