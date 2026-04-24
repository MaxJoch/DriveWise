//
//  AvatarView.swift
//  DriveWise
//
//  Profilbild mit Initialen oder predefined Avatars

import SwiftUI

struct AvatarView: View {
    let displayName: String
    let avatarStyle: String? // "auto", "blue", "green", etc.
    let size: CGFloat
    
    static let avatarColors: [Color] = [
        Color(red: 0.2, green: 0.6, blue: 1.0),    // Blau
        Color(red: 0.3, green: 0.9, blue: 0.6),    // Grün
        Color(red: 1.0, green: 0.4, blue: 0.2),    // Orange
        Color(red: 1.0, green: 0.2, blue: 0.5),    // Rosa
        Color(red: 0.7, green: 0.4, blue: 1.0),    // Lila
        Color(red: 1.0, green: 0.8, blue: 0.2),    // Gelb
        Color(red: 0.2, green: 0.8, blue: 0.9),    // Cyan
        Color(red: 0.9, green: 0.5, blue: 0.3),    // Braun-Orange
    ]
    
    private var initials: String {
        let components = displayName.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].first ?? "?") + String(components[1].first ?? "?")
        } else if !components.isEmpty {
            return String(components[0].prefix(2))
        }
        return "?"
    }
    
    private var backgroundColor: Color {
        // If custom style selected, use that color
        if let style = avatarStyle, style != "auto" {
            switch style {
            case "blue": return Color(red: 0.2, green: 0.6, blue: 1.0)
            case "green": return Color(red: 0.3, green: 0.9, blue: 0.6)
            case "orange": return Color(red: 1.0, green: 0.4, blue: 0.2)
            case "pink": return Color(red: 1.0, green: 0.2, blue: 0.5)
            case "purple": return Color(red: 0.7, green: 0.4, blue: 1.0)
            case "yellow": return Color(red: 1.0, green: 0.8, blue: 0.2)
            case "cyan": return Color(red: 0.2, green: 0.8, blue: 0.9)
            default: return Color(red: 0.9, green: 0.5, blue: 0.3)
            }
        }
        
        // Otherwise, deterministic auto color based on name hash
        let colorIndex = abs(displayName.hashValue) % 8
        return Self.avatarColors[colorIndex]
    }
    
    private var styledEmoji: String? {
        guard let style = avatarStyle, style != "auto" else { return nil }
        
        switch style {
        case "blue": return "🔵"
        case "green": return "🟢"
        case "orange": return "🟠"
        case "pink": return "🌸"
        case "purple": return "🟣"
        case "yellow": return "⭐"
        case "cyan": return "💎"
        default: return nil
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            
            if let emoji = styledEmoji {
                Text(emoji)
                    .font(.system(size: size * 0.45))
            } else {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold, design: .default))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
    }
}


#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            AvatarView(displayName: "Max Jochum", avatarStyle: nil, size: 100)
            AvatarView(displayName: "Anna Schmidt", avatarStyle: nil, size: 100)
            AvatarView(displayName: "Bob", avatarStyle: nil, size: 100)
        }
        
        HStack(spacing: 20) {
            AvatarView(displayName: "Christoph Wagner", avatarStyle: nil, size: 100)
            AvatarView(displayName: "Diana König", avatarStyle: nil, size: 100)
            AvatarView(displayName: "Eva Mueller", avatarStyle: nil, size: 100)
        }
    }
    .padding()
    .background(Color.black)
}
