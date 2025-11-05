import SwiftUI

struct StatisticsView: View {
    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Statistiken")
                        .font(.largeTitle)
                        .foregroundColor(.textPrimary)
                        .padding(.top)

                    // week/month picker
                    HStack {
                        Text("Woche")
                            .padding(8)
                            .background(Color.cardSecondary)
                            .cornerRadius(12)
                        Text("Monat")
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // average speed card with chart placeholder
                    VStack(alignment: .leading) {
                        HStack { Image(systemName: "speedometer").foregroundColor(.textPrimary); Text("Ø-km/h: 125").foregroundColor(.textPrimary).font(.headline) }
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 90)
                            .cornerRadius(12)
                            .overlay(Text("Balkendiagramm (Platzhalter)").foregroundColor(.textSecondary))
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // summary card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Image(systemName: "map") ; Text("Fahrten: 9").foregroundColor(.textPrimary) }
                        HStack { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red); Text("Fehler Gesamt: 12").foregroundColor(.textPrimary) }
                        Divider().background(Color.white.opacity(0.15))
                        Text("Fehleraufteilung").foregroundColor(.textPrimary).font(.subheadline)
                        HStack(spacing: 20) {
                            VStack { Image(systemName: "arrow.down.to.line.alt"); Text("6"); Text("Bremsen").font(.caption) }
                            VStack { Image(systemName: "steeringwheel"); Text("3"); Text("Lenken").font(.caption) }
                            VStack { Image(systemName: "rocket.fill"); Text("3"); Text("Beschleunigungen").font(.caption) }
                        }
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // total distance chart card
                    VStack(alignment: .leading) {
                        HStack { Image(systemName: "location.north.line").foregroundColor(.textPrimary); Text("Gesamtdistanz: 430km").foregroundColor(.textPrimary).font(.headline) }
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 90)
                            .cornerRadius(12)
                            .overlay(Text("Balkendiagramm (Platzhalter)").foregroundColor(.textSecondary))
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Spacer(minLength: 80)
                }
            }
        }
        .navigationTitle("Statistiken")
    }
}

#Preview {
    StatisticsView()
}
