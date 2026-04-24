//
//  DriveWiseTests.swift
//  DriveWiseTests
//

import Testing
import Foundation
@testable import DriveWise

@Suite("DriveWise Motion Logic Tests")
@MainActor
struct DriveWiseMotionTests {
    
    func setupMotionService() -> (MotionService, MotionSettings) {
        var testSettings = MotionSettings()
        // Wir fixieren die Standardwerte fuer die Tests
        testSettings.hardAccelThresholdMS2 = 4.0
        testSettings.veryHardAccelThresholdMS2 = 5.0
        testSettings.hardBrakeThresholdMS2 = 4.5
        testSettings.veryHardBrakeThresholdMS2 = 6.0
        testSettings.sharpTurnLateralThresholdMS2 = 3.5
        testSettings.sharpTurnYawRateThreshold = 1.5
        testSettings.verySharpTurnYawRateThreshold = 2.5
        
        testSettings.minEventDurationSeconds = 0.1
        testSettings.minEventSpeedKmh = 5.0
        
        let service = MotionService(settings: testSettings)
        return (service, testSettings)
    }

    // MARK: - Beschleunigungs-Tests
    
    @Test("Erkennung: Harte Beschleunigung")
    func testHardAcceleration() {
        let (motionService, _) = setupMotionService()
        motionService.updateSpeedFromGPS(speedKmh: 30.0)
        
        // 4.2 m/s2 liegt ueber 4.0 (Hard), aber unter 5.0 (Very Hard)
        for _ in 0..<50 {
            motionService.processInternal(accelMS2: 4.2, lateralMS2: 0, yawRate: 0, dt: 0.02)
        }
        
        #expect(motionService.hardAccelCount == 1)
        #expect(motionService.veryHardAccelCount == 0)
    }

    @Test("Erkennung: Sehr harte Beschleunigung")
    func testVeryHardAcceleration() {
        let (motionService, _) = setupMotionService()
        motionService.updateSpeedFromGPS(speedKmh: 30.0)
        
        // 5.5 m/s2 liegt ueber 5.0 (Very Hard)
        for _ in 0..<50 {
            motionService.processInternal(accelMS2: 5.5, lateralMS2: 0, yawRate: 0, dt: 0.02)
        }
        
        #expect(motionService.veryHardAccelCount == 1)
    }

    // MARK: - Brems-Tests
    
    @Test("Erkennung: Harte Bremsung")
    func testHardBrake() {
        let (motionService, _) = setupMotionService()
        motionService.updateSpeedFromGPS(speedKmh: 50.0)
        
        // -4.8 m/s2 liegt ueber 4.5 (Hard), aber unter 6.0 (Very Hard)
        for _ in 0..<50 {
            motionService.processInternal(accelMS2: -4.8, lateralMS2: 0, yawRate: 0, dt: 0.02)
        }
        
        #expect(motionService.hardBrakeCount == 1)
        #expect(motionService.veryHardBrakeCount == 0)
    }

    @Test("Erkennung: Sehr harte Bremsung")
    func testVeryHardBrake() {
        let (motionService, _) = setupMotionService()
        motionService.updateSpeedFromGPS(speedKmh: 50.0)
        
        // -7.0 m/s2 liegt deutlich ueber 6.0 (Very Hard)
        for _ in 0..<50 {
            motionService.processInternal(accelMS2: -7.0, lateralMS2: 0, yawRate: 0, dt: 0.02)
        }
        
        #expect(motionService.veryHardBrakeCount == 1)
    }

    // MARK: - Kurven-Tests
    
    @Test("Erkennung: Scharfe Kurve")
    func testSharpTurn() {
        let (motionService, _) = setupMotionService()
        motionService.updateSpeedFromGPS(speedKmh: 40.0)
        
        // Seitbeschleunigung 3.8 m/s2 (ueber 3.5) und Yaw 1.6 (ueber 1.5)
        for _ in 0..<50 {
            motionService.processInternal(accelMS2: 0, lateralMS2: 3.8, yawRate: 1.6, dt: 0.02)
        }
        
        #expect(motionService.sharpTurnCount == 1)
        #expect(motionService.verySharpTurnCount == 0)
    }

    @Test("Erkennung: Sehr scharfe Kurve")
    func testVerySharpTurn() {
        let (motionService, _) = setupMotionService()
        motionService.updateSpeedFromGPS(speedKmh: 40.0)
        
        // Deutlich hoehere Werte fuer Very Sharp
        for _ in 0..<50 {
            motionService.processInternal(accelMS2: 0, lateralMS2: 6.0, yawRate: 3.0, dt: 0.02)
        }
        
        #expect(motionService.verySharpTurnCount == 1)
    }
}
