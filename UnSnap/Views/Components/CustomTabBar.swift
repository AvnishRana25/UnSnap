import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        (0, "photo.stack", "Home"),
        (1, "magnifyingglass", "Search"),
        (2, "heart.fill", "Favorites")
    ]
    
    var body: some View {
        HStack(spacing: 32) {
            ForEach(tabs, id: \.0) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.0
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.1)
                            .imageScale(.large)
                            .font(.system(size: 26, weight: selectedTab == tab.0 ? .bold : .semibold))
                        Text(tab.2)
                            .font(.caption)
                            .fontWeight(selectedTab == tab.0 ? .semibold : .medium)
                    }
                    .foregroundColor(selectedTab == tab.0 ? Color.tabBarSelected : Color.tabBarUnselected)
                    .frame(height: 50)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(Color.tabBarBackground)
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
                .overlay(
                    Capsule()
                        .stroke(Color.tabBarSelected.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 34)
    }
} 