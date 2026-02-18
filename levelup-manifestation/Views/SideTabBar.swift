import SwiftUI

enum AppTab {
    case meditate
    case chat
}

struct SideTabBar: View {
    @Binding var selectedTab: AppTab

    private var isDarkTab: Bool { selectedTab == .meditate }

    var body: some View {
        VStack(spacing: 8) {
            tabButton(tab: .meditate, icon: "sparkles")
            tabButton(tab: .chat, icon: "message")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDarkTab
                    ? Color(red: 0.18, green: 0.18, blue: 0.20).opacity(0.85)
                    : Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.85)
                )
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
        )
        .animation(.easeInOut(duration: 0.3), value: isDarkTab)
    }

    @ViewBuilder
    private func tabButton(tab: AppTab, icon: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: selectedTab == tab ? "\(icon).fill" : icon)
                .font(.system(size: 22))
                .foregroundStyle(selectedTab == tab ? .purple : (isDarkTab ? .white.opacity(0.5) : .black.opacity(0.3)))
                .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selectedTab == tab)
                .frame(width: 44, height: 44)
        }
    }
}
