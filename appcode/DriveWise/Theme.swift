import SwiftUI

extension Color {
    // helper to create Color from hex
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let bgFigma = Color(hex: "15334C") // background for each view
    static let accentFigma = Color(hex: "498AFB") // button highlight
    static let cardSecondary = Color(red: 59/255, green: 94/255, blue: 158/255) // R:59 G:94 B:158
    static let textPrimary = Color(hex: "FFFFFF")
    static let textSecondary = Color(hex: "D6D3D3")
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cardSecondary)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}
