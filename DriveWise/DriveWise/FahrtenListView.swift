import SwiftUI

struct DriveSection: Identifiable {
    let id: String
    let title: String
    let drives: [Drive]
}

struct FahrtenListView: View {
    @EnvironmentObject var manager: DriveManager

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    Text("Alle Fahrten")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top)

                    ForEach(groupedDrives()) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal)

                            ForEach(section.drives) { drive in
                                NavigationLink(value: drive) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "mappin.and.ellipse")
                                                    .foregroundColor(.textPrimary)
                                                Text("\(drive.from)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.textPrimary)
                                            }
                                            HStack(spacing: 8) {
                                                Image(systemName: "flag.checkered")
                                                    .foregroundColor(.textSecondary)
                                                Text("\(drive.to)")
                                                    .font(.caption)
                                                    .foregroundColor(.textSecondary)
                                            }
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(String(format: "%.1f km", drive.distanceKm))
                                                .bold()
                                                .foregroundColor(.white)
                                            Text(timeShort(drive.duration))
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    .padding()
                                    .background(Color.cardSecondary)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .navigationDestination(for: Drive.self) { drive in
                                    FahrtDetailView(drive: drive)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        manager.removeDrives(at: offsets)
    }

    private func groupedDrives() -> [DriveSection] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM.yy"

        var dict: [String: [Drive]] = [:]
        for d in manager.drives {
            let key = formatter.string(from: d.startDate)
            dict[key, default: []].append(d)
        }
        // preserve order by date descending
        let sorted = dict.keys.sorted { k1, k2 in
            guard let d1 = dict[k1]?.first?.startDate, let d2 = dict[k2]?.first?.startDate else { return false }
            return d1 > d2
        }
        return sorted.map { key in
            DriveSection(id: key, title: key, drives: dict[key] ?? [])
        }
    }

    private func timeShort(_ interval: TimeInterval) -> String {
        let m = Int(interval) / 60
        let s = Int(interval) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    FahrtenListView().environmentObject(DriveManager())
}
