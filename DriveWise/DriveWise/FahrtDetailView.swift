import SwiftUI

struct FahrtDetailView: View {
    let drive: Drive

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // title
                    VStack(spacing: 2) {
                        Text("Fahrtdetails")
                            .font(.largeTitle)
                            .foregroundColor(.textPrimary)
                            .bold()
                    }
                    .padding(.top)
                    // header card with start / goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dateHeader(drive.startDate))
                            .font(.headline)
                            .foregroundColor(.textPrimary)

                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.textPrimary)
                                    Text(drive.from)
                                        .font(.subheadline)
                                        .foregroundColor(.textPrimary)
                                }
                                Text(timeOnly(drive.startDate))
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(String(format: "%.1f km", drive.distanceKm))
                                    .bold()
                                    .foregroundColor(.textPrimary)
                                Text(timeShort(drive.duration))
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Map placeholder with accent outline
                    Rectangle()
                        .fill(Color.white.opacity(0.02))
                        .frame(height: 220)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentFigma.opacity(0.9), lineWidth: 3)
                        )
                        .overlay(Text("Kartenansicht").foregroundColor(.textSecondary))
                        .padding(.horizontal)

                    // Fehlerübersicht card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fehlerübersicht")
                            .font(.headline)
                            .foregroundColor(.textPrimary)

                        HStack(spacing: 16) {
                            let breakdown = errorBreakdown(count: drive.errorCount)
                            VStack { Image(systemName: "exclamationmark.circle"); Text("Allg."); Text("\(drive.errorCount)") }
                                .foregroundColor(.textPrimary)
                            VStack { Image(systemName: "arrow.down.to.line.alt"); Text("Bremsen"); Text("\(breakdown.brake)") }
                                .foregroundColor(.textPrimary)
                            VStack { Image(systemName: "steeringwheel"); Text("Lenken"); Text("\(breakdown.steer)") }
                                .foregroundColor(.textPrimary)
                            VStack { Image(systemName: "rocket.fill"); Text("Beschl."); Text("\(breakdown.accel)") }
                                .foregroundColor(.textPrimary)
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Metrics
                    VStack(spacing: 12) {
                        metricRow(icon: "speedometer", title: "Durchschnittsgeschwindigkeit", value: String(format: "%.0f km/h", drive.avgSpeedKmh))
                        metricRow(icon: "hare.fill", title: "Höchstgeschwindigkeit", value: String(format: "%.0f km/h", drive.maxSpeedKmh))
                        metricRow(icon: "g.circle", title: "Max. Beschleunigung (G)", value: "~0.24 G")
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 60)
                }
                .padding(.top)
            }
        }
    }

    private func metricRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
                .background(Color(.sRGB, red: 20/255, green: 70/255, blue: 110/255, opacity: 1))
                .cornerRadius(10)
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                Text(title).font(.subheadline).foregroundColor(.textSecondary)
                Text(value).bold().foregroundColor(.textPrimary)
            }
            Spacer()
        }
        .padding()
        .background(Color.cardSecondary)
        .cornerRadius(12)
    }

    private func errorBreakdown(count: Int) -> (brake: Int, steer: Int, accel: Int) {
        if count <= 0 { return (0,0,0) }
        let brake = Int(Double(count) * 0.5)
        let steer = Int(Double(count) * 0.25)
        let accel = max(0, count - brake - steer)
        return (brake, steer, accel)
    }

    private func dateHeader(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: date)
    }

    private func timeOnly(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func timeShort(_ interval: TimeInterval) -> String {
        let m = Int(interval) / 60
        let s = Int(interval) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    FahrtDetailView(drive: Drive(id: UUID(), startDate: Date().addingTimeInterval(-400), endDate: Date(), from: "Malsch", to: "Durmersheim", distanceKm: 4.7, avgSpeedKmh: 55, maxSpeedKmh: 130, errorCount: 2))
}
