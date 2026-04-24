//
//  AvatarPickerView.swift
//  DriveWise
//
//  Avatar Auswahlmenü mit vordefinierten SVG/Emoji-Styles

import SwiftUI

struct AvatarStyle: Identifiable {
    let id: String
    let name: String
    let emoji: String? // Optional: Emoji-Icon
    let colorOverride: Color? // Optional: Farbe statt automatische Berechnung
    
    static let presets: [AvatarStyle] = [
        AvatarStyle(id: "auto", name: "Automatisch", emoji: nil, colorOverride: nil),
        AvatarStyle(id: "blue", name: "Blau", emoji: "🔵", colorOverride: Color(red: 0.2, green: 0.6, blue: 1.0)),
        AvatarStyle(id: "green", name: "Grün", emoji: "🟢", colorOverride: Color(red: 0.3, green: 0.9, blue: 0.6)),
        AvatarStyle(id: "orange", name: "Orange", emoji: "🟠", colorOverride: Color(red: 1.0, green: 0.4, blue: 0.2)),
        AvatarStyle(id: "pink", name: "Rosa", emoji: "🌸", colorOverride: Color(red: 1.0, green: 0.2, blue: 0.5)),
        AvatarStyle(id: "purple", name: "Lila", emoji: "🟣", colorOverride: Color(red: 0.7, green: 0.4, blue: 1.0)),
        AvatarStyle(id: "yellow", name: "Gelb", emoji: "⭐", colorOverride: Color(red: 1.0, green: 0.8, blue: 0.2)),
        AvatarStyle(id: "cyan", name: "Cyan", emoji: "💎", colorOverride: Color(red: 0.2, green: 0.8, blue: 0.9)),
    ]
}

struct AvatarPickerView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @AppStorage("AvatarStyleKey") private var selectedStyle: String = "auto"
    @Environment(\.dismiss) var dismiss
    
    var displayName: String { authVM.userDisplayName ?? "Benutzer" }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgFigma.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Wähle einen Avatar-Stil")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    // Grid mit Avatar-Optionen
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(AvatarStyle.presets) { style in
                                Button(action: {
                                    selectedStyle = style.id
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(style.colorOverride ?? Color.blue)
                                                .frame(width: 60, height: 60)
                                            
                                            if let emoji = style.emoji {
                                                Text(emoji)
                                                    .font(.title)
                                            } else {
                                                let initials = displayName.split(separator: " ").count >= 2 ?
                                                    String(displayName.split(separator: " ")[0].first ?? "?") +
                                                    String(displayName.split(separator: " ")[1].first ?? "?") :
                                                    String(displayName.prefix(2))
                                                Text(initials)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(style.name)
                                                .font(.headline)
                                                .foregroundColor(.textPrimary)
                                            if selectedStyle == style.id {
                                                Text("✓ Ausgewählt")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedStyle == style.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Avatar-Stil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AvatarPickerView()
        .environmentObject(AuthenticationViewModel())
}
