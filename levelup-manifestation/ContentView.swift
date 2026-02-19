import SwiftUI

// ANDROID: RootScreen.kt
//   var showSplash by remember { mutableStateOf(true) }
//   Box(Modifier.fillMaxSize().background(Color(0xFF240D24))) {
//       if (!showSplash) MainTabScreen()
//       AnimatedVisibility(showSplash) { SplashScreen() }
//   }
//   LaunchedEffect(Unit) { delay(2400); showSplash = false }

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // Immediate dark background — prevents white flash between system launch screen and first SwiftUI render
            // ANDROID: Modifier.background(Color(0xFF240D24)) on root Box
            Color(red: 0.14, green: 0.05, blue: 0.14)
                .ignoresSafeArea()

            // ANDROID: if (!showSplash) MainTabScreen() with fadeIn/fadeOut animation
            MainTabView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                // ANDROID: AnimatedVisibility(visible = showSplash, enter = fadeIn(), exit = fadeOut())
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        // ANDROID: animate state change with animateFloatAsState for opacity
        .animation(.easeInOut(duration: 0.7), value: showSplash)
        .onAppear {
            // ANDROID: LaunchedEffect(Unit) { delay(2400L); showSplash = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
