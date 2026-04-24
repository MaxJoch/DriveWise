import SwiftUI
import CoreData
import Combine

enum StatisticsPeriod: String, CaseIterable {
    case day = "Tag"
    case week = "Woche"
    case month = "Monat"
}

// Datenstruktur für Zeitreihen-Daten
struct TimeSeriesDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ErrorBreakdownDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let brakes: Int
    let accelerations: Int
    let turns: Int
}

struct DriveStatistics {
    var totalDrives: Int = 0
    var totalDistance: Double = 0
    var averageDistance: Double = 0
    var totalDuration: TimeInterval = 0
    var averageDuration: TimeInterval = 0
    var averageSpeed: Double = 0
    var maxSpeed: Double = 0
    var averageScore: Double = 0
    
    // Fehlerstatistiken
    var totalErrors: Int = 0
    var hardBrakes: Int = 0
    var hardAccelerations: Int = 0
    var sharpTurns: Int = 0
    var veryHardBrakes: Int = 0
    var veryHardAccelerations: Int = 0
    var verySharpTurns: Int = 0
    
    // Distanz nach Wochentag (für Charts)
    var distanceByWeekday: [Int: Double] = [:]
    
    // Fehler nach Tag (für Charts)
    var errorsByDay: [Date: Int] = [:]
    
    var speedingKm: Double = 0
    
    // Verlaufsdaten für Charts
    var scoreOverTime: [TimeSeriesDataPoint] = []
    var errorsOverTime: [TimeSeriesDataPoint] = []
    var errorBreakdownOverTime: [ErrorBreakdownDataPoint] = []
    
    // Trend-Analyse
    var scoreTrend: TrendDirection = .stable
    var errorTrend: TrendDirection = .stable

    // Reflexionsmetriken
    var errorsPer100Km: Double = 0
    var cleanDriveRatePercent: Double = 0
    var brakeToAccelerationRatio: Double = 0
    var improvementStreak: Int = 0
    var severeEventRatioPercent: Double = 0
}

enum TrendDirection {
    case improving  // Verbesserung
    case stable     // Stabil
    case declining  // Verschlechterung
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "equal.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .orange
        case .declining: return .red
        }
    }
    
    var text: String {
        switch self {
        case .improving: return "Verbesserung"
        case .stable: return "Stabil"
        case .declining: return "Verschlechterung"
        }
    }
}

class StatisticsViewModel: ObservableObject {
    @Published var selectedPeriod: StatisticsPeriod = .week
    @Published var statistics: DriveStatistics = DriveStatistics()
    @Published var drives: [DriveEntity] = []
    @Published var allTimeErrorBreakdownOverTime: [ErrorBreakdownDataPoint] = []
    
    private let context: NSManagedObjectContext
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadStatistics()
    }
    
    func refreshStatistics() {
        loadStatistics()
    }
    
    func loadStatistics() {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        
        // Datum-Filter basierend auf gewähltem Zeitraum
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        
        switch selectedPeriod {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        }
        
        fetchRequest.predicate = NSPredicate(format: "startDate >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            drives = try context.fetch(fetchRequest)
            calculateStatistics()
            loadAllTimeErrorBreakdownSeries()
        } catch {
            print("Fehler beim Laden der Fahrten: \(error)")
            drives = []
            statistics = DriveStatistics()
            allTimeErrorBreakdownOverTime = []
        }
    }

    private func loadAllTimeErrorBreakdownSeries() {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

        do {
            let allDrives = try context.fetch(fetchRequest)
            let calendar = Calendar.current
            var drivesByDay: [Date: [DriveEntity]] = [:]

            for drive in allDrives {
                let day = calendar.startOfDay(for: drive.startDate)
                drivesByDay[day, default: []].append(drive)
            }

            allTimeErrorBreakdownOverTime = drivesByDay.keys.sorted().compactMap { day in
                guard let drivesOnDay = drivesByDay[day] else { return nil }
                let brakes = drivesOnDay.reduce(0) { $0 + Int($1.hardBrakeCount) + Int($1.veryHardBrakeCount) }
                let accelerations = drivesOnDay.reduce(0) { $0 + Int($1.hardAccelCount) + Int($1.veryHardAccelCount) }
                let turns = drivesOnDay.reduce(0) { $0 + Int($1.sharpTurnCount) + Int($1.verySharpTurnCount) }
                return ErrorBreakdownDataPoint(date: day, brakes: brakes, accelerations: accelerations, turns: turns)
            }
        } catch {
            print("Fehler beim Laden des gesamten Fehlerverlaufs: \(error)")
            allTimeErrorBreakdownOverTime = []
        }
    }
    
    private func calculateStatistics() {
        guard !drives.isEmpty else {
            statistics = DriveStatistics()
            return
        }
        
        var stats = DriveStatistics()
        
        stats.totalDrives = drives.count
        stats.totalDistance = drives.reduce(0) { $0 + $1.distanceKm }
        stats.averageDistance = stats.totalDistance / Double(drives.count)
        
        // Dauer berechnen
        stats.totalDuration = drives.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        stats.averageDuration = stats.totalDuration / Double(drives.count)
        
        // Geschwindigkeit
        stats.averageSpeed = drives.reduce(0) { $0 + $1.avgSpeedKmh } / Double(drives.count)
        stats.maxSpeed = drives.map { $0.maxSpeedKmh }.max() ?? 0
        
        // Score
        let scores = drives.map { Double($0.score) }
        stats.averageScore = scores.reduce(0, +) / Double(drives.count)
        
        // Fehler
        stats.totalErrors = Int(drives.reduce(0) { $0 + $1.errorCount })
        stats.hardBrakes = Int(drives.reduce(0) { $0 + Int($1.hardBrakeCount) })
        stats.hardAccelerations = Int(drives.reduce(0) { $0 + Int($1.hardAccelCount) })
        stats.sharpTurns = Int(drives.reduce(0) { $0 + Int($1.sharpTurnCount) })
        stats.veryHardBrakes = Int(drives.reduce(0) { $0 + Int($1.veryHardBrakeCount) })
        stats.veryHardAccelerations = Int(drives.reduce(0) { $0 + Int($1.veryHardAccelCount) })
        stats.verySharpTurns = Int(drives.reduce(0) { $0 + Int($1.verySharpTurnCount) })
        
        stats.speedingKm = drives.reduce(0) { $0 + $1.speedingKm }

        // Reflexionsmetriken
        let totalBrakeEvents = stats.hardBrakes + stats.veryHardBrakes
        let totalAccelerationEvents = stats.hardAccelerations + stats.veryHardAccelerations
        let totalVeryHardEvents = stats.veryHardBrakes + stats.veryHardAccelerations + stats.verySharpTurns
        let cleanDrivesCount = drives.filter { $0.isPerfectDrive }.count

        if stats.totalDistance > 0 {
            stats.errorsPer100Km = (Double(stats.totalErrors) / stats.totalDistance) * 100
        }

        if stats.totalDrives > 0 {
            stats.cleanDriveRatePercent = (Double(cleanDrivesCount) / Double(stats.totalDrives)) * 100
        }

        if totalAccelerationEvents > 0 {
            stats.brakeToAccelerationRatio = Double(totalBrakeEvents) / Double(totalAccelerationEvents)
        } else if totalBrakeEvents > 0 {
            stats.brakeToAccelerationRatio = Double(totalBrakeEvents)
        } else {
            stats.brakeToAccelerationRatio = 0
        }

        if stats.totalErrors > 0 {
            stats.severeEventRatioPercent = (Double(totalVeryHardEvents) / Double(stats.totalErrors)) * 100
        }

        stats.improvementStreak = calculateImprovementStreak(from: drives)
        
        // Verlaufsdaten berechnen
        calculateTimeSeriesData(drives: drives, stats: &stats)
        
        // Trend berechnen
        calculateTrends(drives: drives, stats: &stats)
        
        // Distanz nach Wochentag berechnen
        let calendar = Calendar.current
        for drive in drives {
            let weekday = calendar.component(.weekday, from: drive.startDate)
            stats.distanceByWeekday[weekday, default: 0] += drive.distanceKm
        }
        
        // Fehler nach Tag
        for drive in drives {
            let day = calendar.startOfDay(for: drive.startDate)
            stats.errorsByDay[day, default: 0] += Int(drive.errorCount)
        }
        
        statistics = stats
    }

    private func calculateImprovementStreak(from drives: [DriveEntity]) -> Int {
        let sortedDrives = drives.sorted { $0.startDate < $1.startDate }
        guard !sortedDrives.isEmpty else { return 0 }
        guard sortedDrives.count >= 2 else { return 1 }

        var streak = 1
        var previousScore = Int(sortedDrives[sortedDrives.count - 1].score)

        for index in stride(from: sortedDrives.count - 2, through: 0, by: -1) {
            let currentScore = Int(sortedDrives[index].score)
            if previousScore >= currentScore {
                streak += 1
                previousScore = currentScore
            } else {
                break
            }
        }

        return streak
    }

    func errorsPer100KmInterpretation(_ value: Double) -> String {
        switch value {
        case ..<5:
            return "Sehr ruhig und vorausschauend gefahren."
        case ..<12:
            return "Solide Kontrolle, mit punktuellem Verbesserungspotenzial."
        default:
            return "Viele Ereignisse pro Strecke, defensiver fahren lohnt sich."
        }
    }

    func cleanDriveRateInterpretation(_ percent: Double) -> String {
        switch percent {
        case 70...:
            return "Starke Konstanz: viele fehlerfreie Fahrten."
        case 35..<70:
            return "Gute Basis, aber noch nicht konstant fehlerfrei."
        default:
            return "Fehlerfreie Fahrten sind selten, Fokus auf ruhiges Fahren."
        }
    }

    func brakeToAccelerationRatioInterpretation(_ ratio: Double) -> String {
        switch ratio {
        case ..<0.8:
            return "Mehr Beschleunigungsereignisse als Bremsereignisse."
        case 0.8...1.2:
            return "Ausgeglichenes Brems-/Beschleunigungsprofil."
        default:
            return "Viele Bremsereignisse, oft spätes Reagieren möglich."
        }
    }

    func improvementStreakInterpretation(_ streak: Int) -> String {
        switch streak {
        case 6...:
            return "Starker positiver Trend über mehrere Fahrten."
        case 3..<6:
            return "Erkennbarer Aufwärtstrend."
        default:
            return "Noch keine stabile Verbesserungsserie."
        }
    }

    func severeEventRatioInterpretation(_ percent: Double) -> String {
        switch percent {
        case ..<15:
            return "Die meisten Fehler sind moderat."
        case ..<35:
            return "Mischbild aus moderaten und schweren Ereignissen."
        default:
            return "Hoher Anteil schwerer Ereignisse, Vorsicht erhöhen."
        }
    }
    
    private func calculateTimeSeriesData(drives: [DriveEntity], stats: inout DriveStatistics) {
        let calendar = Calendar.current
        let sortedDrives = drives.sorted { $0.startDate < $1.startDate }

        if selectedPeriod == .day {
            stats.scoreOverTime = sortedDrives.map { drive in
                TimeSeriesDataPoint(date: drive.startDate, value: Double(drive.score))
            }

            stats.errorsOverTime = sortedDrives.map { drive in
                TimeSeriesDataPoint(date: drive.startDate, value: Double(drive.errorCount))
            }

            stats.errorBreakdownOverTime = sortedDrives.map { drive in
                ErrorBreakdownDataPoint(
                    date: drive.startDate,
                    brakes: Int(drive.hardBrakeCount) + Int(drive.veryHardBrakeCount),
                    accelerations: Int(drive.hardAccelCount) + Int(drive.veryHardAccelCount),
                    turns: Int(drive.sharpTurnCount) + Int(drive.verySharpTurnCount)
                )
            }
            return
        }
    
        // Gruppiere Fahrten nach Tag
        var drivesByDay: [Date: [DriveEntity]] = [:]
        for drive in sortedDrives {
            let day = calendar.startOfDay(for: drive.startDate)
            drivesByDay[day, default: []].append(drive)
        }
    
        // Berechne durchschnittlichen Score pro Tag
        stats.scoreOverTime = drivesByDay.keys.sorted().compactMap { day in
            guard let drivesOnDay = drivesByDay[day], !drivesOnDay.isEmpty else { return nil }
            let avgScore = Double(drivesOnDay.reduce(0) { $0 + Int($1.score) }) / Double(drivesOnDay.count)
            return TimeSeriesDataPoint(date: day, value: avgScore)
        }
    
        // Berechne Gesamtfehler pro Tag
        stats.errorsOverTime = drivesByDay.keys.sorted().compactMap { day in
            guard let drivesOnDay = drivesByDay[day] else { return nil }
            let totalErrors = drivesOnDay.reduce(0) { $0 + Int($1.errorCount) }
            return TimeSeriesDataPoint(date: day, value: Double(totalErrors))
        }
    
        // Berechne Fehleraufschlüsselung pro Tag
        stats.errorBreakdownOverTime = drivesByDay.keys.sorted().compactMap { day in
            guard let drivesOnDay = drivesByDay[day] else { return nil }
            let brakes = drivesOnDay.reduce(0) { $0 + Int($1.hardBrakeCount) + Int($1.veryHardBrakeCount) }
            let accelerations = drivesOnDay.reduce(0) { $0 + Int($1.hardAccelCount) + Int($1.veryHardAccelCount) }
            let turns = drivesOnDay.reduce(0) { $0 + Int($1.sharpTurnCount) + Int($1.verySharpTurnCount) }
            return ErrorBreakdownDataPoint(date: day, brakes: brakes, accelerations: accelerations, turns: turns)
        }
    }
    
    private func calculateTrends(drives: [DriveEntity], stats: inout DriveStatistics) {
        guard drives.count >= 3 else {
            stats.scoreTrend = .stable
            stats.errorTrend = .stable
            return
        }
    
        let sortedDrives = drives.sorted { $0.startDate < $1.startDate }
        let half = sortedDrives.count / 2
    
        // Teile Fahrten in erste und zweite Hälfte
        let firstHalf = Array(sortedDrives[0..<half])
        let secondHalf = Array(sortedDrives[half..<sortedDrives.count])
    
        // Score-Trend
        let firstHalfAvgScore = Double(firstHalf.reduce(0) { $0 + Int($1.score) }) / Double(firstHalf.count)
        let secondHalfAvgScore = Double(secondHalf.reduce(0) { $0 + Int($1.score) }) / Double(secondHalf.count)
        let scoreDifference = secondHalfAvgScore - firstHalfAvgScore
        
        if scoreDifference > 5 {
            stats.scoreTrend = .improving
        } else if scoreDifference < -5 {
            stats.scoreTrend = .declining
        } else {
            stats.scoreTrend = .stable
        }
    
        // Fehler-Trend (weniger Fehler = Verbesserung)
        let firstHalfAvgErrors = Double(firstHalf.reduce(0) { $0 + Int($1.errorCount) }) / Double(firstHalf.count)
        let secondHalfAvgErrors = Double(secondHalf.reduce(0) { $0 + Int($1.errorCount) }) / Double(secondHalf.count)
        let errorDifference = secondHalfAvgErrors - firstHalfAvgErrors
    
        if errorDifference < -1 {
            stats.errorTrend = .improving  // Weniger Fehler
        } else if errorDifference > 1 {
            stats.errorTrend = .declining  // Mehr Fehler
        } else {
            stats.errorTrend = .stable
        }
    }
    
    func changePeriod(to period: StatisticsPeriod) {
        selectedPeriod = period
        loadStatistics()
    }
    
    // Hilfsfunktion zum Formatieren der Dauer
    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }
    
    // Hilfsfunktion für Wochentag-Namen
    func weekdayName(for weekday: Int) -> String {
        Self.weekdayFormatter.shortWeekdaySymbols[weekday - 1]
    }
}
