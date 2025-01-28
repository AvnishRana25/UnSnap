import SwiftUI

extension Color {
    static let customBackground = Color(.systemBackground)
    static let customPrimary = Color("AccentColor")
    static let customSecondary = Color(.systemGray5)
    static let customText = Color(.label)
    
    // Modern gradient colors
    static let gradientStart = Color(hex: "FF6B6B")
    static let gradientEnd = Color(hex: "4ECDC4")
    
    // Tab bar colors
    static let tabBarBackground = Color(hex: "2C3E50")
    static let tabBarSelected = Color(hex: "3498DB")
    static let tabBarUnselected = Color.white.opacity(0.7)
    
    // Initialize with hex code
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 