import Foundation
import SwiftUI

enum AchievementType: Identifiable {
    var id: String {
        switch self {
        case .totalDistance(let km):
            return "totalDistance_\(km)"
        case .totalXP(let xp):
            return "totalXP_\(xp)"
        case .errorFreeDistance(let km):
            return "errorFreeDistance_\(km)"
        case .errorFreeDrives(let count):
            return "errorFreeDrives_\(count)"
        case .weeklyScoreAboveThreshold(let threshold, let weeks):
            return "weeklyScore_\(threshold)_weeks_\(weeks)"
        }
    }
    
    case totalDistance(km: Int)
    case totalXP(xp: Int)
    case errorFreeDistance(km: Int)
    case errorFreeDrives(count: Int)
    case weeklyScoreAboveThreshold(threshold: Int, weeks: Int)
    
    var title: String {
        switch self {
        case .totalDistance:
            return "Fernweh"
        case .totalXP:
            return "Erfahrung sammeln"
        case .errorFreeDistance:
            return "Meisterfahrer"
        case .errorFreeDrives:
            return "Perfekt beherrscht"
        case .weeklyScoreAboveThreshold:
            return "Konsistent exzellent"
        }
    }
    
    var description: String {
        switch self {
        case .totalDistance(let km):
            return "Fahre insgesamt \(km) km"
        case .totalXP(let xp):
            return "Sammle \(xp) XP Punkte"
        case .errorFreeDistance(let km):
            return "Fahre \(km) km ohne Fehler"
        case .errorFreeDrives(let count):
            return "Fahre \(count) Fahrten ohne Fehler"
        case .weeklyScoreAboveThreshold(let threshold, let weeks):
            return "Halte deinen Drive-Wise Score für \(weeks) Woche(n) über \(threshold)"
        }
    }
    
    var targetValue: Double {
        switch self {
        case .totalDistance(let km):
            return Double(km)
        case .totalXP(let xp):
            return Double(xp)
        case .errorFreeDistance(let km):
            return Double(km)
        case .errorFreeDrives(let count):
            return Double(count)
        case .weeklyScoreAboveThreshold(_, let weeks):
            return Double(weeks)
        }
    }
    
    var icon: String {
        switch self {
        case .totalDistance:
            return "car.fill"
        case .totalXP:
            return "star.fill"
        case .errorFreeDistance:
            return "checkmark.circle.fill"
        case .errorFreeDrives:
            return "shield.fill"
        case .weeklyScoreAboveThreshold:
            return "calendar.badge.clock"
        }
    }
    
    var color: Color {
        switch self {
        case .totalDistance:
            return Color.blue
        case .totalXP:
            return Color.yellow
        case .errorFreeDistance:
            return Color.green
        case .errorFreeDrives:
            return Color.purple
        case .weeklyScoreAboveThreshold:
            return Color.orange
        }
    }

    var rewardXP: Int {
        switch self {
        case .totalDistance:
            return 100
        case .totalXP:
            return 50
        case .errorFreeDistance:
            return 75
        case .errorFreeDrives:
            return 60
        case .weeklyScoreAboveThreshold:
            return 150
        }
    }
}

struct Achievement {
    let type: AchievementType
    var currentValue: Double = 0
    var isCompleted: Bool = false
    var completedDate: Date? = nil
    
    var progress: Double {
        min(1.0, currentValue / type.targetValue)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
}

// Vordefinierte Achievements
let predefinedAchievements: [AchievementType] = [
    .totalDistance(km: 100),
    .totalDistance(km: 500),
    .totalDistance(km: 1000),
    .totalDistance(km: 5000),
    .totalDistance(km: 10000),
    
    .totalXP(xp: 500),
    .totalXP(xp: 2000),
    .totalXP(xp: 5000),
    .totalXP(xp: 10000),
    
    .errorFreeDistance(km: 50),
    .errorFreeDistance(km: 100),
    .errorFreeDistance(km: 500),
    
    .errorFreeDrives(count: 5),
    .errorFreeDrives(count: 10),
    .errorFreeDrives(count: 25),
    
    .weeklyScoreAboveThreshold(threshold: 80, weeks: 1),
    .weeklyScoreAboveThreshold(threshold: 80, weeks: 4),
]
