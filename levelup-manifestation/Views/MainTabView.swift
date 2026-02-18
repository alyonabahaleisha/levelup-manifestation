import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .meditate

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Full screen content
            ZStack {
                switch selectedTab {
                case .meditate:
                    MeditationCardsView()
                        .transition(.opacity)
                case .chat:
                    ChatView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // Floating pill at bottom-left
            SideTabBar(selectedTab: $selectedTab)
                .padding(.leading, 20)
                .padding(.bottom, 40)
        }
        .ignoresSafeArea()
        .statusBarStyle(selectedTab == .meditate ? .lightContent : .darkContent)
    }
}
