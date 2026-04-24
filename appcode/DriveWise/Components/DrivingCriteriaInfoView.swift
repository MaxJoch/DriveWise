//
//  DrivingCriteriaInfoView.swift
//  DriveWise
//
//  Info modal explaining how driving quality is evaluated

import SwiftUI

struct DrivingCriteriaInfoView: View {
    @State private var showInfo = false
    
    var body: some View {
        Button(action: { showInfo = true }) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.accentFigma)
                
                Text("Wie wird meine Fahrt bewertet?")
                    .font(.caption)
                    .foregroundColor(.accentFigma)
            }
        }
        .sheet(isPresented: $showInfo) {
            CriteriaInfoSheet()
        }
    }
}

private struct CriteriaInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Bewertungskriterien")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                .background(Color.cardSecondary)
                
                Divider()
                    .background(Color.textSecondary.opacity(0.1))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Dein DriveWise Score wird basierend auf mehreren Kriterien berechnet:")
                            .font(.body)
                            .foregroundColor(.textPrimary)
                        
                        criterionCard(
                            icon: "hand.raised.fill",
                            title: "Bremsen",
                            description: "Häufige oder abrupte Bremsmanöver werden negativ bewertet. Sanfte Bremsungen sind ideal.",
                            color: .red
                        )
                        
                        criterionCard(
                            icon: "bolt.fill",
                            title: "Beschleunigung",
                            description: "Aggressive Beschleunigungen erhöhen das Unfallrisiko. Ruhige und gleichmäßige Beschleunigung ist besser.",
                            color: .yellow
                        )
                        
                        criterionCard(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Kurvenverhalten",
                            description: "Scharfe Kurven und hohes Tempo in Kurven werden geahndet. Sanfte Fahrweise in Kurven ist sicherer.",
                            color: .orange
                        )
                        
                        criterionCard(
                            icon: "speedometer",
                            title: "Geschwindigkeit",
                            description: "Fahren über der Geschwindigkeitsbegrenzung wird als Punkt registriert.",
                            color: .blue
                        )
                        
                        criterionCard(
                            icon: "tachometer",
                            title: "Fahrverhalten allgemein",
                            description: "Je weniger Fehler und je gleichmäßiger dein Fahrverhalten, desto höher ist dein Score.",
                            color: .green
                        )
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Wie der Score berechnet wird:")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            scoreInfoRow(number: "1", text: "Basispunkte: Du startest mit 100 Punkten")
                            scoreInfoRow(number: "2", text: "Fehler-Abzüge: Jeder Fehler (Bremsen, Beschleunigung, Kurven) reduziert deinen Score")
                            scoreInfoRow(number: "3", text: "Schweregrad: Stärkere Fehler haben größere Auswirkungen")
                            scoreInfoRow(number: "4", text: "Fahrzeit: Längere Fahrten mit weniger Fehlern belohnen perfektes Fahren")
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Score-Bewertung:")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            scoreRatingRow(range: "100+", description: "Ausgezeichnet", color: .green)
                            scoreRatingRow(range: "80-99", description: "Gut", color: .yellow)
                            scoreRatingRow(range: "60-79", description: "Akzeptabel", color: .orange)
                            scoreRatingRow(range: "< 60", description: "Verbesserung nötig", color: .red)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Tipps für besseres Fahren:")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            tipsRow("Beschleunige langsam und gleichmäßig")
                            tipsRow("Bremse frühzeitig und sanft ab")
                            tipsRow("Passe deine Geschwindigkeit in Kurven an")
                            tipsRow("Fahre defensiv und vorausschauend")
                            tipsRow("Behalte Sicherheitsabstände bei")
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
    }
    
    private func criterionCard(icon: String, title: String, description: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func scoreInfoRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.accentFigma)
                .frame(width: 24, height: 24)
                .overlay(
                    Text(number)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
        }
    }
    
    private func scoreRatingRow(range: String, description: String, color: Color) -> some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(range)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Text(description)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(8)
        .background(Color.cardSecondary)
        .cornerRadius(6)
    }
    
    private func tipsRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .foregroundColor(.accentFigma)
                .font(.headline)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    DrivingCriteriaInfoView()
}
