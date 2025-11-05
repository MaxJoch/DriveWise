import SwiftUI

struct AchievementsView: View {
    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Level")
                            .font(.title)
                            .foregroundColor(.textPrimary)
                        Text("1")
                            .font(.largeTitle)
                            .foregroundColor(.textPrimary)

                        // xp bar placeholder
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.12)).frame(height: 18)
                            RoundedRectangle(cornerRadius: 12).fill(Color.green).frame(width: 140, height: 18)
                        }
                        .padding(.horizontal)
                    }

                    // info card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wie steige ich im Level auf?")
                            .foregroundColor(.textPrimary)
                            .font(.headline)
                        Text("• Pro gefahrenem Kilometer erhältst du 1xp\n• Jeder Fahrfehler zieht dir 5 xp ab\n→ Es lohnt sich also fehlerfrei zu fahren ;)")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Quests list placeholders
                    VStack(spacing: 10) {
                        ForEach(0..<8) { i in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Erreiche \(i*5000 + 5000) km").foregroundColor(.textPrimary)
                                    ProgressView(value: Double(i+1)/10.0)
                                        .progressViewStyle(.linear)
                                }
                                Spacer()
                                Text("+100 xp").foregroundColor(.textPrimary)
                            }
                            .padding()
                            .background(Color.cardSecondary)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Erfolge")
    }
}

#Preview {
    AchievementsView()
}
