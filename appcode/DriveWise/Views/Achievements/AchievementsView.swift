import SwiftUI

enum AchievementStatusFilter: String, CaseIterable, Identifiable {
    case all = "Alle"
    case open = "Offen"
    case completed = "Erreicht"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:
            return "line.3.horizontal.decrease.circle"
        case .open:
            return "circle.dashed"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}

enum AchievementCategoryFilter: String, CaseIterable, Identifiable {
    case all = "Alle"
    case distance = "Kilometer"
    case xp = "XP"
    case cleanDrives = "Fehlerfrei"
    case score = "Score"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:
            return "square.grid.2x2"
        case .distance:
            return "car.fill"
        case .xp:
            return "star.fill"
        case .cleanDrives:
            return "shield.fill"
        case .score:
            return "gauge.high"
        }
    }
}

struct AchievementsView: View {
    @EnvironmentObject var driveManager: DriveManager
    @StateObject private var viewModel = AchievementsViewModel()
    @State private var statusFilter: AchievementStatusFilter = .all
    @State private var categoryFilter: AchievementCategoryFilter = .all
    @State private var pullOffset: CGFloat = 0
    
    private func matchesStatus(_ achievement: Achievement) -> Bool {
        switch statusFilter {
        case .all:
            return true
        case .open:
            return !achievement.isCompleted
        case .completed:
            return achievement.isCompleted
        }
    }
    
    private func matchesCategory(_ achievement: Achievement) -> Bool {
        switch categoryFilter {
        case .all:
            return true
        case .distance:
            if case .totalDistance = achievement.type { return true }
            return false
        case .xp:
            if case .totalXP = achievement.type { return true }
            return false
        case .cleanDrives:
            if case .errorFreeDistance = achievement.type { return true }
            if case .errorFreeDrives = achievement.type { return true }
            return false
        case .score:
            if case .weeklyScoreAboveThreshold = achievement.type { return true }
            return false
        }
    }
    
    private var filteredAchievements: [Achievement] {
        viewModel.achievements.filter { achievement in
            matchesStatus(achievement) && matchesCategory(achievement)
        }
    }
    
    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pull-to-Refresh indicator
                if driveManager.isSyncing || pullOffset > 0 {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .opacity(pullOffset > 0 || driveManager.isSyncing ? 1 : 0)
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
                
                ScrollView {
                    VStack(spacing: AppLayout.pageSpacing) {
                        // Sync Error Banner
                        SyncErrorBanner()
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        VStack(spacing: 2) {
                            Text("Erfolge")
                                .appPageTitleStyle()
                        }
                        .padding(.top)
                        
                        // Level und XP Card
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Level")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                    Text("\(viewModel.level)")
                                        .font(.title2)
                                        .foregroundColor(.textPrimary)
                                        .bold()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Gesamt XP")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                    Text("\(viewModel.totalXP)")
                                        .font(.title3)
                                        .foregroundColor(.textPrimary)
                                        .bold()
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                            }
                            
                            HStack {
                                Text("\(viewModel.completionPercentage())% abgeschlossen")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    Text("\(viewModel.completedAchievementsCount())/\(viewModel.achievements.count)")
                                        .font(.caption)
                                        .foregroundColor(.textPrimary)
                                        .bold()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(999)
                            }
                            
                            // XP Progress Bar
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Fortschritt")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    Text("\(viewModel.currentLevelXP) / \(viewModel.xpForNextLevel) XP")
                                        .font(.caption2)
                                        .foregroundColor(.textSecondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.12))
                                            .frame(height: 16)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.green, .yellow]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(
                                                width: max(0, geometry.size.width * min(1, viewModel.levelProgress)),
                                                height: 16
                                            )
                                    }
                                }
                                .frame(height: 16)
                                
                                Text("Noch \(max(0, viewModel.xpForNextLevel - viewModel.currentLevelXP)) XP bis zum nächsten Level")
                                    .font(.caption2)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding()
                        .appSectionCardStyle(cornerRadius: 12)
                        .padding(.horizontal, AppLayout.horizontalPadding)
                        
                        // Info Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Achievement-XP")
                                    .foregroundColor(.textPrimary)
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Text("Getrennt vom DriveWise-Score")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Label("+1 XP pro gefahrenem Kilometer", systemImage: "location.fill")
                                Label("+10 XP pro abgeschlossener Fahrt", systemImage: "flag.checkered")
                                Label("+25 XP bei Score ≥ 90", systemImage: "star.leadinghalf.filled")
                                Label("+50 XP bei Score ≥ 95", systemImage: "star.fill")
                            }
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        }
                        .padding()
                        .appSectionCardStyle(cornerRadius: 12)
                        .padding(.horizontal, AppLayout.horizontalPadding)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Filter")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(filteredAchievements.count) / \(viewModel.achievements.count)")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(AchievementStatusFilter.allCases) { filter in
                                        FilterChip(
                                            title: filter.rawValue,
                                            icon: filter.icon,
                                            isSelected: statusFilter == filter
                                        ) {
                                            statusFilter = filter
                                        }
                                    }
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.14))
                                        .frame(width: 1, height: 20)
                                        .padding(.horizontal, 2)
                                    
                                    ForEach(AchievementCategoryFilter.allCases) { filter in
                                        FilterChip(
                                            title: filter.rawValue,
                                            icon: filter.icon,
                                            isSelected: categoryFilter == filter
                                        ) {
                                            categoryFilter = filter
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)

                        if filteredAchievements.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.title3)
                                    .foregroundColor(.textSecondary)
                                Text("Keine Achievements für diesen Filter")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .padding(.horizontal, AppLayout.horizontalPadding)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAchievements, id: \.type.id) { achievement in
                                    AchievementCard(achievement: achievement)
                                }
                            }
                            .padding(.horizontal, AppLayout.horizontalPadding)
                            .padding(.bottom, 20)
                        }
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
                            if pullOffset > 50 && !driveManager.isSyncing {
                                withAnimation {
                                    viewModel.refreshAchievements()
                                }
                            }
                            withAnimation(.easeOut) {
                                pullOffset = 0
                            }
                        }
                )
            }
            .onAppear {
                viewModel.updateForDriveManager(driveManager)
            }
            .onChange(of: driveManager.drives) { _, _ in
                viewModel.updateForDriveManager(driveManager)
            }
            .onChange(of: driveManager.isSyncing) { _, syncing in
                if !syncing {
                    withAnimation {
                        pullOffset = 0
                    }
                }
            }
        }
    }
    
    private struct FilterChip: View {
        let title: String
        let icon: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption2)
                    Text(title)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.16) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(isSelected ? 0.0 : 0.16), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Achievement Card
    struct AchievementCard: View {
        let achievement: Achievement
        
        var body: some View {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(achievement.type.color.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: achievement.type.icon)
                            .font(.title2)
                            .foregroundColor(achievement.type.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.type.title)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text(achievement.type.description)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if achievement.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                Text("✓")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        } else {
                            Text("+\(achievement.type.rewardXP)")
                                .font(.caption)
                                .foregroundColor(achievement.type.color)
                            Text("XP")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.cardBorder.opacity(0.7))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(achievement.type.color)
                                    .frame(
                                        width: max(0, geometry.size.width * min(1, achievement.progress)),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)
                        
                        Text("\(achievement.progressPercentage)%")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("\(Int(achievement.currentValue))")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text("/ \(Int(achievement.type.targetValue))")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding()
            .background(
                achievement.isCompleted ?
                Color.green.opacity(0.1) :
                    Color.cardSecondary
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        achievement.isCompleted ? Color.green.opacity(0.3) : Color.clear,
                        lineWidth: achievement.isCompleted ? 1.5 : 0
                    )
            )
        }
    }
    
}

#Preview {
    AchievementsView()
        .environmentObject(DriveManager())
}
