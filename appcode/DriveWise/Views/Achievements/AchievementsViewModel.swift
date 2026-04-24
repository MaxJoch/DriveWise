import SwiftUI
import Combine

@MainActor
class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var totalXP: Int = 0
    @Published var level: Int = 1
    @Published var currentLevelXP: Int = 0
    @Published var xpForNextLevel: Int = 1000
    @Published var levelProgress: Double = 0
    
    private var driveManager: DriveManager?
    private var cancellables = Set<AnyCancellable>()
    private let kmPenaltyPerError: Double = 1.0
    
    init(driveManager: DriveManager? = nil) {
        self.driveManager = driveManager
        setupBindings()
        updateAchievements()
    }
    
    func refreshAchievements() {
        updateAchievements()
    }
    
    private func setupBindings() {
        cancellables.removeAll()

        guard let driveManager else { return }

        driveManager.$drives
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAchievements()
            }
            .store(in: &cancellables)
    }
    
    private func updateAchievements() {
        // Initialisiere achievements wenn noch nicht geschehen
        if achievements.isEmpty {
            achievements = predefinedAchievements.map { Achievement(type: $0) }
        }
        
        // Berechne alle Werte
        let totalDistance = calculateTotalDistance()
        let totalXPValue = calculateTotalXP()
        let errorFreeDistance = calculateErrorFreeDistance()
        let errorFreeDrivesCount = calculateErrorFreeDrives()
        let weeklyScoreStats = calculateWeeklyScoreStats()
        
        // Update achievements
        for i in 0..<achievements.count {
            let achievement = achievements[i]
            
            switch achievement.type {
            case .totalDistance:
                achievements[i].currentValue = totalDistance
                
            case .totalXP:
                achievements[i].currentValue = Double(totalXPValue)
                
            case .errorFreeDistance:
                achievements[i].currentValue = errorFreeDistance
                
            case .errorFreeDrives:
                achievements[i].currentValue = Double(errorFreeDrivesCount)
                
            case .weeklyScoreAboveThreshold(let threshold, _):
                let weekCount = weeklyScoreStats.filter { $0.averageScore >= threshold }.count
                achievements[i].currentValue = Double(weekCount)
            }
            
            // Prüfe ob achievement completed ist
            if achievements[i].progress >= 1.0 && !achievement.isCompleted {
                achievements[i].isCompleted = true
                achievements[i].completedDate = Date()
            }
        }
        
        // Update Level und XP
        updateLevelAndXP(totalXP: totalXPValue)
    }
    
    private func calculateTotalDistance() -> Double {
        (driveManager?.drives ?? []).reduce(0) { $0 + $1.distanceKm }
    }
    
    private func calculateTotalXP() -> Int {
        var xp = 0
        for drive in (driveManager?.drives ?? []) {
            // Eigenständiges Achievement-XP System (unabhängig vom Fahrscore)
            // Punkte gibt es immer pro gefahrenem km und pro abgeschlossener Fahrt.
            xp += max(1, Int(drive.distanceKm))
            xp += 10

            // Bonus bei gutem DriveWise-Score
            if drive.score >= 95 {
                xp += 50
            } else if drive.score >= 90 {
                xp += 25
            }
        }
        return xp
    }
    
    private func calculateErrorFreeDistance() -> Double {
        (driveManager?.drives ?? []).reduce(0) { total, drive in
            // Kumulierte fehlerfreie Kilometer: pro Fehler wird 1 km abgezogen.
            let creditedKm = max(0, drive.distanceKm - (Double(drive.errorCount) * kmPenaltyPerError))
            return total + creditedKm
        }
    }
    
    private func calculateErrorFreeDrives() -> Int {
        (driveManager?.drives ?? []).filter { $0.errorCount == 0 }.count
    }
    
    private func calculateWeeklyScoreStats() -> [(week: Date, averageScore: Int)] {
        var weeklyStats: [Date: [Int]] = [:]
        
        for drive in (driveManager?.drives ?? []) {
            let weekStarts = drive.startDate.startOfWeek
            if weeklyStats[weekStarts] != nil {
                weeklyStats[weekStarts]?.append(drive.score)
            } else {
                weeklyStats[weekStarts] = [drive.score]
            }
        }
        
        return weeklyStats.map { week, scores in
            let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
            return (week: week, averageScore: averageScore)
        }
    }
    
    private func updateLevelAndXP(totalXP: Int) {
        self.totalXP = totalXP
        
        // Berechne Level: Jedes Level benötigt 1000 * Level XP
        var xpAccumulated = 0
        var currentLevel = 1
        
        while true {
            let xpForThisLevel = 1000 * currentLevel
            if xpAccumulated + xpForThisLevel <= totalXP {
                xpAccumulated += xpForThisLevel
                currentLevel += 1
            } else {
                break
            }
        }
        
        self.level = currentLevel
        self.currentLevelXP = totalXP - xpAccumulated
        self.xpForNextLevel = 1000 * currentLevel
        self.levelProgress = Double(currentLevelXP) / Double(xpForNextLevel)
    }
    
    func completedAchievementsCount() -> Int {
        achievements.filter { $0.isCompleted }.count
    }
    
    func completionPercentage() -> Int {
        guard !achievements.isEmpty else { return 0 }
        return (completedAchievementsCount() * 100) / achievements.count
    }
    
    func updateForDriveManager(_ driveManager: DriveManager) {
        if let current = self.driveManager, current === driveManager {
            return
        }
        self.driveManager = driveManager
        setupBindings()
        updateAchievements()
    }
}
