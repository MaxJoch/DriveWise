import Foundation
import UserNotifications

final class DriveNotificationService {
    static let shared = DriveNotificationService()

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard

    private let hasRequestedPermissionKey = "notifications.hasRequestedPermission"
    private let notifiedAchievementIDsKey = "notifications.notifiedAchievementIDs"
    private let lastDriveFeedbackDateKey = "notifications.lastDriveFeedbackDate"
    private let weeklyRecapRequestID = "drivewise.weeklyRecap"

    private init() {}

    private var isNotificationsEnabled: Bool {
        AppUserDefaults.bool(for: AppSettingKeys.notificationsEnabled, default: AppSettingDefaults.notificationsEnabled)
    }

    private func scopedKey(_ baseKey: String) -> String {
        AppUserDefaults.scopedKey(baseKey)
    }

    func requestAuthorizationIfNeeded(force: Bool = false) {
        guard isNotificationsEnabled || force else { return }
        guard force || !defaults.bool(forKey: scopedKey(hasRequestedPermissionKey)) else { return }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            guard let self else { return }
            self.defaults.set(true, forKey: self.scopedKey(self.hasRequestedPermissionKey))
        }
    }

    func handleDriveCompleted(drive: Drive, allDrives: [Drive]) {
        guard isNotificationsEnabled else { return }
        notifyAchievementsIfNeeded(allDrives: allDrives)
        notifyDriveFeedbackIfEligible(for: drive)
        scheduleWeeklyRecap(allDrives: allDrives)
    }

    func refreshWeeklyRecap(allDrives: [Drive]) {
        guard isNotificationsEnabled else {
            center.removePendingNotificationRequests(withIdentifiers: [weeklyRecapRequestID])
            return
        }
        scheduleWeeklyRecap(allDrives: allDrives)
    }

    func notifyAutoTrackingStarted() {
        guard isNotificationsEnabled else { return }
        scheduleImmediateNotification(
            title: "Automatisches Tracking gestartet",
            body: "Eine Fahrt wurde erkannt. DriveWise hat das Tracking automatisch gestartet."
        )
    }

    func notifyAutoTrackingStopped(score: Int) {
        guard isNotificationsEnabled else { return }
        scheduleImmediateNotification(
            title: "Automatisches Tracking beendet",
            body: "Die Fahrt wurde automatisch beendet. Dein Score: \(score)."
        )
    }

    private func notifyAchievementsIfNeeded(allDrives: [Drive]) {
        let unlockedIDs = currentUnlockedAchievementIDs(allDrives: allDrives)
        let alreadyNotifiedIDs = Set(defaults.stringArray(forKey: scopedKey(notifiedAchievementIDsKey)) ?? [])
        let newlyUnlockedIDs = unlockedIDs.subtracting(alreadyNotifiedIDs)

        guard !newlyUnlockedIDs.isEmpty else { return }

        let typesByID = Dictionary(predefinedAchievements.map { ($0.id, $0) }, uniquingKeysWith: { existing, _ in existing })

        for id in newlyUnlockedIDs.sorted() {
            guard let type = typesByID[id] else { continue }
            scheduleImmediateNotification(
                title: "Achievement erreicht",
                body: "\(type.title): \(type.description)"
            )
        }

        let mergedIDs = alreadyNotifiedIDs.union(newlyUnlockedIDs)
        defaults.set(Array(mergedIDs), forKey: scopedKey(notifiedAchievementIDsKey))
    }

    private func notifyDriveFeedbackIfEligible(for drive: Drive) {
        guard shouldSendDriveFeedback() else { return }

        scheduleImmediateNotification(
            title: "Fahrt-Feedback",
            body: driveFeedbackMessage(for: drive)
        )
        defaults.set(Date(), forKey: scopedKey(lastDriveFeedbackDateKey))
    }

    private func shouldSendDriveFeedback() -> Bool {
        if let lastDate = defaults.object(forKey: scopedKey(lastDriveFeedbackDateKey)) as? Date {
            let minInterval: TimeInterval = 36 * 60 * 60
            if Date().timeIntervalSince(lastDate) < minInterval {
                return false
            }
        }

        return Int.random(in: 0..<100) < 35
    }

    private func driveFeedbackMessage(for drive: Drive) -> String {
        if drive.score >= 105 {
            return "Heute bist du sehr sauber gefahren. Weiter so!"
        }

        if drive.score >= 90 {
            return "Starke Fahrt heute. Du bist auf einem sehr guten Weg."
        }

        let accelIssues = drive.hardAccelCount + drive.veryHardAccelCount
        let brakeIssues = drive.hardBrakeCount + drive.veryHardBrakeCount

        if accelIssues >= max(2, brakeIssues) {
            return "Heute warst du etwas zu stark auf dem Gas. Achte naechstes Mal auf sanftere Beschleunigungen."
        }

        if brakeIssues >= 2 {
            return "Heute gab es einige harte Bremsungen. Versuche vorausschauender zu fahren."
        }

        if drive.sharpTurnCount + drive.verySharpTurnCount >= 2 {
            return "Heute waren ein paar scharfe Kurven dabei. Ruhigere Lenkbewegungen helfen fuer einen besseren Score."
        }

        return "Heute war noch Luft nach oben. Schau in deine Statistik und optimiere die naechste Fahrt."
    }

    private func scheduleWeeklyRecap(allDrives: [Drive]) {
        center.removePendingNotificationRequests(withIdentifiers: [weeklyRecapRequestID])

        let content = UNMutableNotificationContent()
        content.title = "Dein Wochenrueckblick"
        content.body = weeklyRecapMessage(allDrives: allDrives)
        content.sound = .default

        let triggerDate = nextWeeklyRecapDate()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: weeklyRecapRequestID, content: content, trigger: trigger)
        enqueueIfAuthorized(request)
    }

    private func weeklyRecapMessage(allDrives: [Drive]) -> String {
        let trend = weeklyScoreTrend(allDrives: allDrives)

        switch trend {
        case .improving(let current, let previous):
            return "Stark: Dein Wochenscore ist von \(previous) auf \(current) gestiegen. Schau in die Statistik, um deine Fortschritte zu festigen."
        case .declining(let current, let previous):
            return "Achtung: Dein Wochenscore ist von \(previous) auf \(current) gesunken. Ein Blick in die Statistik hilft dir beim Reflektieren."
        case .stable(let current):
            return "Konstant gefahren: Dein Wochenscore liegt bei \(current). Schau in die Statistik fuer den Feinschliff."
        case .insufficientData:
            return "Zeit fuer deinen Wochencheck. Schau in die Statistik, um dein Fahrverhalten konstruktiv zu reflektieren."
        }
    }

    private func nextWeeklyRecapDate() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let now = Date()
        var components = DateComponents()
        components.weekday = 1
        components.hour = 19
        components.minute = 0

        return calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(7 * 24 * 60 * 60)
    }

    private func scheduleImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "drivewise.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        enqueueIfAuthorized(request)
    }

    private func enqueueIfAuthorized(_ request: UNNotificationRequest) {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.center.add(request) { error in
                    if let error {
                        print("[DriveNotificationService] Notification enqueue failed: \(error.localizedDescription)")
                    }
                }
            case .notDetermined:
                self.requestAuthorizationIfNeeded(force: true)
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    private func currentUnlockedAchievementIDs(allDrives: [Drive]) -> Set<String> {
        let totalDistance = allDrives.reduce(0) { $0 + $1.distanceKm }
        let totalXP = calculateTotalXP(allDrives: allDrives)
        let errorFreeDistance = allDrives.filter { $0.errorCount == 0 }.reduce(0) { $0 + $1.distanceKm }
        let errorFreeDrives = allDrives.filter { $0.errorCount == 0 }.count
        let weeklyScoreStats = calculateWeeklyScoreStats(allDrives: allDrives)

        var unlockedIDs = Set<String>()

        for type in predefinedAchievements {
            switch type {
            case .totalDistance:
                if totalDistance >= type.targetValue { unlockedIDs.insert(type.id) }
            case .totalXP:
                if Double(totalXP) >= type.targetValue { unlockedIDs.insert(type.id) }
            case .errorFreeDistance:
                if errorFreeDistance >= type.targetValue { unlockedIDs.insert(type.id) }
            case .errorFreeDrives:
                if Double(errorFreeDrives) >= type.targetValue { unlockedIDs.insert(type.id) }
            case .weeklyScoreAboveThreshold(let threshold, _):
                let weekCount = weeklyScoreStats.filter { $0.averageScore >= threshold }.count
                if Double(weekCount) >= type.targetValue { unlockedIDs.insert(type.id) }
            }
        }

        return unlockedIDs
    }

    private func calculateTotalXP(allDrives: [Drive]) -> Int {
        var xp = 0
        for drive in allDrives {
            xp += max(1, Int(drive.distanceKm))
            xp += 10

            if drive.score >= 95 {
                xp += 50
            } else if drive.score >= 90 {
                xp += 25
            }
        }
        return xp
    }

    private func calculateWeeklyScoreStats(allDrives: [Drive]) -> [(week: Date, averageScore: Int)] {
        var weeklyStats: [Date: [Int]] = [:]

        for drive in allDrives {
            let weekStart = startOfWeek(for: drive.startDate)
            weeklyStats[weekStart, default: []].append(drive.score)
        }

        return weeklyStats.map { week, scores in
            let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
            return (week: week, averageScore: averageScore)
        }
    }

    private enum WeeklyTrend {
        case improving(current: Int, previous: Int)
        case declining(current: Int, previous: Int)
        case stable(current: Int)
        case insufficientData
    }

    private func weeklyScoreTrend(allDrives: [Drive]) -> WeeklyTrend {
        let grouped = Dictionary(grouping: allDrives) { startOfWeek(for: $0.startDate) }
        guard !grouped.isEmpty else { return .insufficientData }

        let currentWeekStart = startOfWeek(for: Date())
        guard let lastCompletedWeekStart = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart),
              let previousWeekStart = Calendar.current.date(byAdding: .day, value: -14, to: currentWeekStart) else {
            return .insufficientData
        }

        guard let lastWeekDrives = grouped[lastCompletedWeekStart], !lastWeekDrives.isEmpty else {
            return .insufficientData
        }

        let currentAverage = lastWeekDrives.reduce(0) { $0 + $1.score } / lastWeekDrives.count

        guard let previousWeekDrives = grouped[previousWeekStart], !previousWeekDrives.isEmpty else {
            return .stable(current: currentAverage)
        }

        let previousAverage = previousWeekDrives.reduce(0) { $0 + $1.score } / previousWeekDrives.count
        let delta = currentAverage - previousAverage

        if delta >= 4 {
            return .improving(current: currentAverage, previous: previousAverage)
        }

        if delta <= -4 {
            return .declining(current: currentAverage, previous: previousAverage)
        }

        return .stable(current: currentAverage)
    }

    private func startOfWeek(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}
