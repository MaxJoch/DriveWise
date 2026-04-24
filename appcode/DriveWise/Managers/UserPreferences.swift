import Foundation

enum AppSettingKeys {
    static let preferredUnitSystem = "preferredUnitSystem"
    static let notificationsEnabled = "settings.notificationsEnabled"
    static let acousticWarningEnabled = "settings.acousticWarningEnabled"
    static let keepDisplayAwakeWhileTracking = "settings.keepDisplayAwakeWhileTracking"
    static let autoTrackDrives = "settings.autoTrackDrives"
    static let autoTrackStartSpeedKmh = "settings.autoTrackStartSpeedKmh"
    static let autoTrackStopSpeedKmh = "settings.autoTrackStopSpeedKmh"
    static let autoTrackStartStableSeconds = "settings.autoTrackStartStableSeconds"
    static let autoTrackStopStableSeconds = "settings.autoTrackStopStableSeconds"
    static let cloudSyncEnabled = "settings.cloudSyncEnabled"
    static let routeCloudSyncEnabled = "settings.routeCloudSyncEnabled"
    static let showMotionDebugDetails = "settings.showMotionDebugDetails"
}

enum SessionUserContext {
    private static let activeUserIdentifierKey = "session.activeUserIdentifier"

    static var activeUserIdentifier: String? {
        UserDefaults.standard.string(forKey: activeUserIdentifierKey)
    }

    static func setActiveUserIdentifier(_ identifier: String?) {
        if let identifier {
            UserDefaults.standard.set(identifier, forKey: activeUserIdentifierKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeUserIdentifierKey)
        }
    }
}

enum AppUserDefaults {
    static let didChangeNotification = Notification.Name("AppUserDefaultsDidChange")
    private static let settingsMutationTimestampKey = "settings.lastLocalMutationAt"

    enum WriteSource {
        case localUser
        case remoteSync
    }

    static func scopedKey(_ baseKey: String) -> String {
        guard let userIdentifier = SessionUserContext.activeUserIdentifier, !userIdentifier.isEmpty else {
            return baseKey
        }
        return "\(baseKey).\(userIdentifier)"
    }

    static func bool(for baseKey: String, default defaultValue: Bool) -> Bool {
        let scoped = scopedKey(baseKey)
        if UserDefaults.standard.object(forKey: scoped) != nil {
            return UserDefaults.standard.bool(forKey: scoped)
        }
        if UserDefaults.standard.object(forKey: baseKey) != nil {
            return UserDefaults.standard.bool(forKey: baseKey)
        }
        return defaultValue
    }

    static func set(_ value: Bool, for baseKey: String, source: WriteSource = .localUser) {
        UserDefaults.standard.set(value, forKey: scopedKey(baseKey))
        if source == .localUser {
            markLocalSettingsMutationNow()
        }
        NotificationCenter.default.post(name: didChangeNotification, object: baseKey)
    }

    static func double(for baseKey: String, default defaultValue: Double) -> Double {
        let scoped = scopedKey(baseKey)
        if UserDefaults.standard.object(forKey: scoped) != nil {
            return UserDefaults.standard.double(forKey: scoped)
        }
        if UserDefaults.standard.object(forKey: baseKey) != nil {
            return UserDefaults.standard.double(forKey: baseKey)
        }
        return defaultValue
    }

    static func set(_ value: Double, for baseKey: String, source: WriteSource = .localUser) {
        UserDefaults.standard.set(value, forKey: scopedKey(baseKey))
        if source == .localUser {
            markLocalSettingsMutationNow()
        }
        NotificationCenter.default.post(name: didChangeNotification, object: baseKey)
    }

    static func lastLocalSettingsMutationDate() -> Date? {
        let key = scopedKey(settingsMutationTimestampKey)
        guard let timestamp = UserDefaults.standard.object(forKey: key) as? Double else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    private static func markLocalSettingsMutationNow() {
        let key = scopedKey(settingsMutationTimestampKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
    }
}

enum AppSettingDefaults {
    static let notificationsEnabled = true
    static let acousticWarningEnabled = true
    static let keepDisplayAwakeWhileTracking = false
    static let autoTrackDrives = false
    static let autoTrackStartSpeedKmh = 15.0
    static let autoTrackStopSpeedKmh = 4.0
    static let autoTrackStartStableSeconds = 12.0
    static let autoTrackStopStableSeconds = 120.0
    static let cloudSyncEnabled = true
    static let routeCloudSyncEnabled = true
    static let showMotionDebugDetails = false
}

enum UnitSystem: String, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .metric:
            return "Metrisch (km, km/h)"
        case .imperial:
            return "Imperial (mi, mph)"
        }
    }
}

enum UnitFormatter {
    private static let kmToMilesFactor: Double = 0.621371

    static func distance(_ kilometers: Double, unitSystem: UnitSystem, fractionDigits: Int = 1) -> String {
        let value: Double
        let unit: String

        switch unitSystem {
        case .metric:
            value = kilometers
            unit = "km"
        case .imperial:
            value = kilometers * kmToMilesFactor
            unit = "mi"
        }

        return String(format: "%.\(fractionDigits)f %@", value, unit)
    }

    static func speed(_ kmh: Double, unitSystem: UnitSystem, fractionDigits: Int = 0) -> String {
        let value: Double
        let unit: String

        switch unitSystem {
        case .metric:
            value = kmh
            unit = "km/h"
        case .imperial:
            value = kmh * kmToMilesFactor
            unit = "mph"
        }

        return String(format: "%.\(fractionDigits)f %@", value, unit)
    }
}