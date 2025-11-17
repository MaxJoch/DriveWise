import SwiftUI
import UIKit

struct StartseiteView: View {
    @EnvironmentObject var manager: DriveManager
    @State private var fromText: String = "Malsch"
    @State private var toText: String = "Durmersheim"
    
    enum CardColor {
        case green, beige, red
        func color() -> Color {
            switch self {
            case .green: return Color(hex: "259833").opacity(0.5)
            case .beige: return Color(hex: "D8CC87")
            case .red: return Color(hex: "FF4747")
            }
        }
        func label() -> String {
            switch self {
            case .green: return "Grün"
            case .beige: return "Beige"
            case .red: return "Rot"
            }
        }
    }

    @State private var selectedCard: CardColor = .green

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // title
                    VStack(spacing: 2) {
                        Text("Drive Wise")
                            .font(.largeTitle)
                            .foregroundColor(.textPrimary)
                            .bold()
                    }
                    .padding(.top)

                    // Score card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mein DriveWise Score")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardSecondary)
                                .frame(height: 150)

                            VStack {
                                Text("100")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                Text("0                          100")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Track button (use asset if exists)
                    Button(action: {
                        if manager.isDriving {
                            manager.stopDrive(from: fromText, to: toText)
                        } else {
                            manager.startDrive(from: fromText, to: toText)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text(manager.isDriving ? "Fahrt beenden" : "Fahrt tracken")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentFigma)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }

                    // Current drive summary card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Aktuelle Fahrt")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            Spacer()
                        }

                        HStack(spacing: 16) {
                            HStack { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red); Text("Fehler: \(manager.errorCount)").foregroundColor(.textSecondary) }
                            Spacer()
                            HStack { Image(systemName: "location.fill").foregroundColor(.textPrimary); Text(String(format: "%.2f km", manager.distanceKm)).foregroundColor(.textSecondary) }
                            Spacer()
                            HStack { Image(systemName: "clock").foregroundColor(.textPrimary); Text(timeString(seconds: manager.elapsedSeconds)).foregroundColor(.textSecondary) }
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // selectable bottom card color
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        Picker("Karte Farbe", selection: $selectedCard) {
                            Text("Grün") .tag(CardColor.green)
                            Text("Geld") .tag(CardColor.beige)
                            Text("Rot") .tag(CardColor.red)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedCard.color())
                            .frame(height: 180)
                            .overlay(Text(selectedCard.label()).foregroundColor(.white).bold())
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            if manager.drives.isEmpty { manager.addSampleDrives() }
        }
    }

    private func timeString(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    StartseiteView().environmentObject(DriveManager())
}
