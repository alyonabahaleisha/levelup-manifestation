import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedTab: AppTab = .affirmations

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full screen content
            ZStack {
                switch selectedTab {
                case .affirmations:
                    AffirmationsFeedView()
                        .transition(.opacity)
                case .reprogram:
                    ReprogramView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // Glass tab bar — bottom center
            SideTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 36)
        }
        .ignoresSafeArea()
        .statusBarStyle(.lightContent)
    }
}
