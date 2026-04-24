import SwiftUI

struct DriveSection: Identifiable {
    let id: String
    let title: String
    let drives: [Drive]
}

struct FahrtenListView: View {
    @EnvironmentObject var manager: DriveManager
    @State private var pullOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pull-to-Refresh indicator
                if manager.isSyncing || pullOffset > 0 {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .opacity(pullOffset > 0 || manager.isSyncing ? 1 : 0)
                        Text(pullOffset > 50 ? "Loslassen zum Aktualisieren..." : "Nach unten ziehen...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .opacity(pullOffset > 0 ? 1 : 0)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: max(0, pullOffset))
                    .clipped()
                }
                
                // title
                VStack(spacing: 2) {
                    Text("Alle Fahrten")
                        .appPageTitleStyle()
                }
                .padding(.top)
                .padding(.bottom, 20)
                
                // Sync Error Banner
                SyncErrorBanner()
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                if manager.drives.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.textSecondary)
                        
                        Text("Keine Fahrten vorhanden")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text("Starten Sie eine Fahrt, um sie hier zu sehen")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(groupedDrives()) { section in
                            Section(header: Text(section.title)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))) {
                                ForEach(section.drives) { drive in
                                    NavigationLink(destination: FahrtDetailView(drive: drive)) {
                                        HStack(spacing: 12) {
                                            VStack(spacing: 0) {
                                                HStack(spacing: 12) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        HStack(spacing: 8) {
                                                            Image(systemName: "mappin.and.ellipse")
                                                                .foregroundColor(.accentFigma)
                                                                .font(.system(size: 14))
                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text("\(drive.fromCity ?? drive.from)")
                                                                    .font(.subheadline)
                                                                    .bold()
                                                                    .foregroundColor(.textPrimary)
                                                                Text(formatTime(drive.startDate))
                                                                    .font(.caption2)
                                                                    .foregroundColor(.textSecondary)
                                                            }
                                                        }
                                                    }
                                                    Spacer()
                                                }

                                                Divider()
                                                    .background(Color.textSecondary.opacity(0.2))
                                                    .padding(.vertical, 8)

                                                HStack(spacing: 12) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        HStack(spacing: 8) {
                                                            Image(systemName: "flag.checkered")
                                                                .foregroundColor(.accentFigma)
                                                                .font(.system(size: 14))
                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text("\(drive.toCity ?? drive.to)")
                                                                    .font(.subheadline)
                                                                    .bold()
                                                                    .foregroundColor(.textPrimary)
                                                                Text(formatTime(drive.endDate))
                                                                    .font(.caption2)
                                                                    .foregroundColor(.textSecondary)
                                                            }
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text(UnitFormatter.distance(drive.distanceKm, unitSystem: .metric, fractionDigits: 1))
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundColor(.textPrimary)
                                                Text(timeShort(drive.duration))
                                                    .font(.caption)
                                                    .foregroundColor(.textSecondary)
                                            }
                                        }
                                    }
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.cardSecondary)
                                            .padding(EdgeInsets(top: AppLayout.listRowVerticalPadding, leading: AppLayout.horizontalPadding, bottom: AppLayout.listRowVerticalPadding, trailing: AppLayout.horizontalPadding))
                                            .frame(minHeight: 110)
                                    )
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: AppLayout.listRowVerticalPadding, leading: AppLayout.horizontalPadding, bottom: AppLayout.listRowVerticalPadding, trailing: AppLayout.horizontalPadding))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            manager.removeDrive(byId: drive.id)
                                        } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .background(Color.bgFigma)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 && pullOffset == 0 {
                            pullOffset = min(value.translation.height, 100)
                        }
                    }
                    .onEnded { value in
                        if pullOffset > 50 && !manager.isSyncing {
                            withAnimation {
                                manager.synchronizeFromPullToRefresh()
                            }
                        }
                        withAnimation(.easeOut) {
                            pullOffset = 0
                        }
                    }
            )
            .overlay(alignment: .top) {
                if let error = manager.lastError {
                    ErrorToastView(error: error)
                        .padding()
                }
            }
            .onChange(of: manager.isSyncing) { _, syncing in
                if !syncing {
                    withAnimation {
                        pullOffset = 0
                    }
                }
            }
        }
    }

    private func groupedDrives() -> [DriveSection] {
        var dict: [String: [Drive]] = [:]
        for d in manager.drives {
            let key = AppDateTimeFormatter.daySection(d.startDate)
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
        AppDateTimeFormatter.durationClock(interval)
    }

    private func formatTime(_ date: Date) -> String {
        AppDateTimeFormatter.shortTime(date)
    }
}

#Preview {
    FahrtenListView().environmentObject(DriveManager())
}
