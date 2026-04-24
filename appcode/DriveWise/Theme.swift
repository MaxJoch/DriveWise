import SwiftUI
import UIKit

enum AppLayout {
    static let pageSpacing: CGFloat = 20
    static let horizontalPadding: CGFloat = 16
    static let listRowVerticalPadding: CGFloat = 8
}

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

    // App-wide semantic colors with automatic light/dark adaptation.
    static let bgFigma = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 21/255, green: 51/255, blue: 76/255, alpha: 1)
            : UIColor(red: 244/255, green: 248/255, blue: 253/255, alpha: 1)
    })

    static let accentFigma = Color(hex: "498AFB")

    static let cardSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 59/255, green: 94/255, blue: 158/255, alpha: 1)
            : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    })

    static let textPrimary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : UIColor(red: 23/255, green: 29/255, blue: 38/255, alpha: 1)
    })

    static let textSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 214/255, green: 211/255, blue: 211/255, alpha: 1)
            : UIColor(red: 97/255, green: 107/255, blue: 122/255, alpha: 1)
    })

    static let cardBorder = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.08)
    })

    static let iconChipBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor(red: 226/255, green: 233/255, blue: 243/255, alpha: 1)
    })

    static let iconChipForeground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? .white
            : UIColor(red: 49/255, green: 67/255, blue: 93/255, alpha: 1)
    })

    static let progressTrack = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.12)
            : UIColor(red: 220/255, green: 226/255, blue: 236/255, alpha: 1)
    })
}

struct AppPageTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.textPrimary)
            .bold()
    }
}

struct AppSectionCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .background(Color.cardSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .cornerRadius(cornerRadius)
    }
}

struct AppPrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.accentFigma)
            .cornerRadius(12)
    }
}

extension View {
    func appPageTitleStyle() -> some View { modifier(AppPageTitleStyle()) }
    func appSectionCardStyle(cornerRadius: CGFloat = 12) -> some View {
        modifier(AppSectionCardStyle(cornerRadius: cornerRadius))
    }
    func appPrimaryButtonStyle() -> some View { modifier(AppPrimaryButtonStyle()) }
}
