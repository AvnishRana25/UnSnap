import SwiftUI

struct HeaderView: View {
    let title: String
    let showRefreshButton: Bool
    let isLoading: Bool
    var onRefresh: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundStyle(.linearGradient(
                    colors: [.gradientStart, .gradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            
            Spacer()
            
            if showRefreshButton {
                Button(action: onRefresh ?? {}) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isLoading ? .gray : .tabBarSelected)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .tabBarSelected.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                }
                .disabled(isLoading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Color.customBackground)
    }
} 