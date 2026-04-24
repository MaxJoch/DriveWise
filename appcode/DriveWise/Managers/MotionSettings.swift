//
//  MotionSettings.swift
//  DriveWise
//
//  Configurable threshold settings for motion event detection
//

import Foundation

struct MotionSettings: Codable {
    static let didChangeNotification = Notification.Name("MotionSettingsDidChange")

    // Normal braking/acceleration thresholds (m/s²)
    var hardAccelThresholdMS2: Double = 2.9
    var hardBrakeThresholdMS2: Double = 2.9
    
    // Very hard braking/acceleration thresholds (m/s²)
    var veryHardAccelThresholdMS2: Double = 3.5
    var veryHardBrakeThresholdMS2: Double = 4.0
    
    // Turn/Rotation thresholds
    var sharpTurnYawRateThreshold: Double = 1.3
    var sharpTurnLateralThresholdMS2: Double = 2.7
    
    // Very sharp turns
    var verySharpTurnYawRateThreshold: Double = 2.0
    
    // Speeding threshold (km/h)
    var speedingThresholdKmh: Double = 130.0
    
    // Event cooldown (seconds between same-type events)
    var eventCooldownSeconds: Double = 1.5

    // Signal filtering and event stability
    var signalSmoothingAlpha: Double = 0.2
    var minEventDurationSeconds: Double = 0.20
    var hysteresisReleaseFactor: Double = 0.50
    var minEventSpeedKmh: Double = 10.0
    
    // GPS/Motion blending
    var gpsBlendAlpha: Double = 0.25
    
    static let `default` = MotionSettings()
    
    var key: String { "MotionSettings" }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: key)
            NotificationCenter.default.post(name: MotionSettings.didChangeNotification, object: nil)
        }
    }
    
    static func load() -> MotionSettings {
        guard let data = UserDefaults.standard.data(forKey: MotionSettings.default.key),
              let decoded = try? JSONDecoder().decode(MotionSettings.self, from: data) else {
            return .default
        }
        return decoded
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
        NotificationCenter.default.post(name: MotionSettings.didChangeNotification, object: nil)
    }
}
