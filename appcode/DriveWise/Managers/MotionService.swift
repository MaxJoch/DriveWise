//
//  MotionService.swift
//  DriveWise
//
//  CoreMotion tracking and event detection
//

import Foundation
import Combine
import CoreMotion
import simd

private enum EventSeverity {
    case none
    case hard
    case veryHard
}

struct MotionSample {
    let timestamp: Date
    let accelMS2: Double
    let lateralMS2: Double
    let yawRate: Double
    let speedKmh: Double
}

enum MotionEventKind {
    case started
    case upgraded
}

struct MotionEvent {
    let id: UUID
    let kind: MotionEventKind
    let timestamp: Date
    let type: DriveErrorEventType
    let severity: DriveErrorEventSeverity
    let speedKmh: Double
    let accelerationG: Double
}

struct MotionClassificationDebugSnapshot {
    let timestamp: Date
    let speedKmh: Double
    let longAccelMS2: Double
    let latAccelMS2: Double
    let yawRate: Double
    let turnEvidence: Double
    let accelEvidence: Double
    let brakeEvidence: Double
    let longitudinalEvidence: Double
    let decision: String
    let isCalibrating: Bool

    static let empty = MotionClassificationDebugSnapshot(
        timestamp: Date(),
        speedKmh: 0,
        longAccelMS2: 0,
        latAccelMS2: 0,
        yawRate: 0,
        turnEvidence: 0,
        accelEvidence: 0,
        brakeEvidence: 0,
        longitudinalEvidence: 0,
        decision: "none",
        isCalibrating: false
    )
}

final class MotionService: ObservableObject {
    @Published var hardBrakeCount: Int = 0
    @Published var hardAccelCount: Int = 0
    @Published var sharpTurnCount: Int = 0

    @Published var veryHardBrakeCount: Int = 0
    @Published var veryHardAccelCount: Int = 0
    @Published var verySharpTurnCount: Int = 0

    @Published private(set) var events: [MotionEvent] = []

    @Published var speedingKm: Double = 0.0
    @Published var maxAccelMS2: Double = 0
    @Published var maxBrakeMS2: Double = 0
    @Published var maxLateralAccelMS2: Double = 0
    @Published var smoothedSpeedKmh: Double = 0

    @Published var currentForwardAccelG: Double = 0
    @Published var currentLateralAccelG: Double = 0
    @Published private(set) var currentForwardAxis: SIMD3<Double> = SIMD3<Double>(1, 0, 0)

    @Published private(set) var liveErrorSeverity: DriveErrorEventSeverity?
    @Published private(set) var latestMotionEvent: MotionEvent?
    @Published private(set) var isCalibrating: Bool = false
    @Published private(set) var classificationDebug: MotionClassificationDebugSnapshot = .empty
    @Published var lastError: DriveWiseError?
    @Published var settings: MotionSettings

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var lastSampleTime: TimeInterval?
    private var lastBrakeEventTime: TimeInterval = 0
    private var lastAccelEventTime: TimeInterval = 0
    private var lastTurnEventTime: TimeInterval = 0
    private var motionSpeedMS: Double = 0
    private var filteredLongitudinalMS2: Double = 0
    private var filteredLateralMS2: Double = 0
    private var filteredYawRate: Double = 0

    private var forwardAxis = SIMD3<Double>(1, 0, 0)
    private var lateralAxis = SIMD3<Double>(0, 1, 0)
    private var gravityAxis = SIMD3<Double>(0, 0, -1)

    private var calibrationGravityEMA = SIMD3<Double>(0, 0, -1)
    private var calibrationForwardEMA = SIMD3<Double>(repeating: 0)
    private var calibrationValidSampleCount: Int = 0
    private var calibrationPositiveSampleCount: Int = 0
    private var calibrationNegativeSampleCount: Int = 0
    private var latestGpsAccelerationMS2: Double = 0
    private var lastGpsSpeedSampleAt: TimeInterval?
    private var lastGpsSpeedMSForCalibration: Double?
    private var isAxisCalibrationReady: Bool = false
    private var settingsDidChangeCancellable: AnyCancellable?

    private let minInitialCalibrationSpeedKmh: Double = 15.0
    private let minCalibrationYawRate: Double = 0.15
    private let minCalibrationHorizontalAccelG: Double = 0.08
    private let minCalibrationGpsAccelMS2: Double = 0.12
    private let calibrationGravityAlpha: Double = 0.05
    private let calibrationForwardAlpha: Double = 0.08
    private let calibrationReadySampleCount: Int = 8
    private let calibrationMinSamplesPerDirection: Int = 2
    private let calibrationForwardConsistencyMinDot: Double = 0.2

    private var accelAboveThresholdDuration: TimeInterval = 0
    private var brakeAboveThresholdDuration: TimeInterval = 0
    private var turnAboveThresholdDuration: TimeInterval = 0

    private var activeAccelSeverity: EventSeverity = .none
    private var activeBrakeSeverity: EventSeverity = .none
    private var activeTurnSeverity: EventSeverity = .none

    private var activeAccelEventId: UUID?
    private var activeBrakeEventId: UUID?
    private var activeTurnEventId: UUID?

    private var wasSpeedingPreviously: Bool = false
    private var speedingStartDistance: Double = 0
    private var currentDistance: Double = 0

    var isTracking: Bool = false

    private var testOverrideLong: Double?
    private var testOverrideLat: Double?

    init(settings: MotionSettings = MotionSettings.load()) {
        self.settings = settings
        observeMotionSettingsChanges()
    }

    private func observeMotionSettingsChanges() {
        settingsDidChangeCancellable = NotificationCenter.default.publisher(for: MotionSettings.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.settings = MotionSettings.load()
            }
    }

    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            lastError = .motionUnavailable
            return
        }

        reset()
        isTracking = true
        prepareRollingCalibration(resetAxes: true)
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] motion, error in
            guard let self else { return }
            if error != nil {
                DispatchQueue.main.async {
                    self.lastError = .motionUnavailable
                }
                return
            }
            guard let motion else { return }
            self.handleMotionUpdate(motion)
        }
    }

    func stopTracking() {
        finalizeSpeedingSegmentIfNeeded(currentDistanceKm: currentDistance)
        isTracking = false
        motionManager.stopDeviceMotionUpdates()
    }

    func reset() {
        DispatchQueue.main.async {
            self.events = []
            self.updateCounters()
            self.speedingKm = 0.0
            self.maxAccelMS2 = 0
            self.maxBrakeMS2 = 0
            self.maxLateralAccelMS2 = 0
            self.smoothedSpeedKmh = 0
            self.liveErrorSeverity = nil
            self.latestMotionEvent = nil
            self.isCalibrating = false
            self.classificationDebug = .empty
            self.lastError = nil
            self.currentForwardAccelG = 0
            self.currentLateralAccelG = 0
            self.currentForwardAxis = SIMD3<Double>(1, 0, 0)
        }

        lastSampleTime = nil
        lastBrakeEventTime = 0
        lastAccelEventTime = 0
        lastTurnEventTime = 0
        motionSpeedMS = 0
        filteredLongitudinalMS2 = 0
        filteredLateralMS2 = 0
        filteredYawRate = 0
        forwardAxis = SIMD3<Double>(1, 0, 0)
        lateralAxis = SIMD3<Double>(0, 1, 0)
        gravityAxis = SIMD3<Double>(0, 0, -1)
        currentForwardAxis = SIMD3<Double>(1, 0, 0)
        calibrationGravityEMA = SIMD3<Double>(0, 0, -1)
        calibrationForwardEMA = SIMD3<Double>(repeating: 0)
        calibrationValidSampleCount = 0
        calibrationPositiveSampleCount = 0
        calibrationNegativeSampleCount = 0
        latestGpsAccelerationMS2 = 0
        lastGpsSpeedSampleAt = nil
        lastGpsSpeedMSForCalibration = nil
        isAxisCalibrationReady = false
        accelAboveThresholdDuration = 0
        brakeAboveThresholdDuration = 0
        turnAboveThresholdDuration = 0
        activeAccelSeverity = .none
        activeBrakeSeverity = .none
        activeTurnSeverity = .none
        activeAccelEventId = nil
        activeBrakeEventId = nil
        activeTurnEventId = nil
        wasSpeedingPreviously = false
        speedingStartDistance = 0
        currentDistance = 0
        testOverrideLong = nil
        testOverrideLat = nil
    }

    @MainActor
    private func updateCounters() {
        hardBrakeCount = events.filter { $0.type == .brake && $0.severity == .hard }.count
        veryHardBrakeCount = events.filter { $0.type == .brake && $0.severity == .veryHard }.count
        hardAccelCount = events.filter { $0.type == .acceleration && $0.severity == .hard }.count
        veryHardAccelCount = events.filter { $0.type == .acceleration && $0.severity == .veryHard }.count
        sharpTurnCount = events.filter { $0.type == .turn && $0.severity == .hard }.count
        verySharpTurnCount = events.filter { $0.type == .turn && $0.severity == .veryHard }.count
    }

    func recalibrate() {
        guard isTracking else { return }
        prepareRollingCalibration(resetAxes: true)
        DispatchQueue.main.async {
            self.liveErrorSeverity = nil
            self.latestMotionEvent = nil
        }
    }

    func updateSpeedFromGPS(speedKmh: Double) {
        let gpsSpeedMS = max(0, speedKmh / 3.6)
        let now = Date().timeIntervalSince1970

        if let lastGpsSpeedSampleAt, let lastGpsSpeedMSForCalibration, now > lastGpsSpeedSampleAt {
            latestGpsAccelerationMS2 = (gpsSpeedMS - lastGpsSpeedMSForCalibration) / (now - lastGpsSpeedSampleAt)
            if abs(latestGpsAccelerationMS2) < 0.05 {
                latestGpsAccelerationMS2 = 0
            }
        }

        lastGpsSpeedSampleAt = now
        lastGpsSpeedMSForCalibration = gpsSpeedMS
        motionSpeedMS = settings.gpsBlendAlpha * gpsSpeedMS + (1 - settings.gpsBlendAlpha) * motionSpeedMS

        DispatchQueue.main.async {
            self.smoothedSpeedKmh = self.motionSpeedMS * 3.6
        }
    }

    func updateDistance(distanceKm: Double) {
        currentDistance = distanceKm
        let isSpeeding = smoothedSpeedKmh > settings.speedingThresholdKmh
        if isSpeeding && !wasSpeedingPreviously {
            speedingStartDistance = distanceKm
            wasSpeedingPreviously = true
        } else if !isSpeeding && wasSpeedingPreviously {
            finalizeSpeedingSegmentIfNeeded(currentDistanceKm: distanceKm)
        }
    }

    private func finalizeSpeedingSegmentIfNeeded(currentDistanceKm: Double) {
        guard wasSpeedingPreviously else { return }
        let speedingDistance = max(0, currentDistanceKm - speedingStartDistance)
        speedingKm += speedingDistance
        wasSpeedingPreviously = false
    }

    func summary() -> (hardBrakeCount: Int, hardAccelCount: Int, sharpTurnCount: Int, maxAccelMS2: Double, maxBrakeMS2: Double, maxLateralAccelMS2: Double) {
        (hardBrakeCount, hardAccelCount, sharpTurnCount, maxAccelMS2, maxBrakeMS2, maxLateralAccelMS2)
    }

    private func handleMotionUpdate(_ motion: CMDeviceMotion) {
        let now = motion.timestamp
        let dt = (lastSampleTime == nil) ? 0 : now - (lastSampleTime ?? now)
        lastSampleTime = now

        let userAccelerationVector = SIMD3<Double>(motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z)
        let gravityVector = SIMD3<Double>(motion.gravity.x, motion.gravity.y, motion.gravity.z)
        let rotationRateVector = SIMD3<Double>(motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z)

        let verticalAxis = -normalizedOrDefault(gravityVector, defaultValue: SIMD3<Double>(0, 0, -1))
        let yawRate = simd_dot(rotationRateVector, verticalAxis)

        updateRollingCalibrationIfNeeded(userAcceleration: userAccelerationVector, gravity: gravityVector, yawRate: yawRate)

        let accelMS2 = simd_dot(userAccelerationVector, forwardAxis) * 9.81
        let lateralMS2 = simd_dot(userAccelerationVector, lateralAxis) * 9.81

        Task { @MainActor in
            self.processInternal(accelMS2: accelMS2, lateralMS2: lateralMS2, yawRate: yawRate, dt: dt)
        }
    }

    @MainActor
    func processInternal(accelMS2: Double, lateralMS2: Double, yawRate: Double, dt: Double) {
        func decisionLabel(accel: EventSeverity, brake: EventSeverity, turn: EventSeverity, isCalibrating: Bool) -> String {
            if isCalibrating {
                return "calibrating"
            }
            if turn != .none {
                return "turn"
            }
            if accel != .none && brake == .none {
                return "acceleration"
            }
            if brake != .none && accel == .none {
                return "brake"
            }
            if accel != .none && brake != .none {
                return "mixed-long"
            }
            return "none"
        }

        let speedKmh = motionSpeedMS * 3.6
        let speedMS = speedKmh / 3.6

        filteredLongitudinalMS2 = settings.signalSmoothingAlpha * accelMS2 + (1 - settings.signalSmoothingAlpha) * filteredLongitudinalMS2
        filteredLateralMS2 = settings.signalSmoothingAlpha * lateralMS2 + (1 - settings.signalSmoothingAlpha) * filteredLateralMS2
        filteredYawRate = settings.signalSmoothingAlpha * yawRate + (1 - settings.signalSmoothingAlpha) * filteredYawRate

        if accelMS2 > maxAccelMS2 { maxAccelMS2 = accelMS2 }
        if -accelMS2 > maxBrakeMS2 { maxBrakeMS2 = -accelMS2 }
        if abs(lateralMS2) > maxLateralAccelMS2 { maxLateralAccelMS2 = abs(lateralMS2) }

        smoothedSpeedKmh = speedKmh
        currentForwardAccelG = filteredLongitudinalMS2 / 9.81
        currentLateralAccelG = filteredLateralMS2 / 9.81

        if isCalibrating {
            classificationDebug = MotionClassificationDebugSnapshot(
                timestamp: Date(),
                speedKmh: speedKmh,
                longAccelMS2: filteredLongitudinalMS2,
                latAccelMS2: filteredLateralMS2,
                yawRate: filteredYawRate,
                turnEvidence: 0,
                accelEvidence: 0,
                brakeEvidence: 0,
                longitudinalEvidence: 0,
                decision: "calibrating",
                isCalibrating: true
            )
            return
        }

        let nowTime = Date().timeIntervalSince1970
        let effectiveDt = max(0, dt)
        let filteredLongAccel = filteredLongitudinalMS2
        let filteredLatAccel = filteredLateralMS2
        let absLatAccel = abs(filteredLatAccel)
        let absYaw = abs(filteredYawRate)
        let hardLatThreshold = settings.sharpTurnLateralThresholdMS2
        let veryHardLatThreshold = max(hardLatThreshold * 1.4, 5.0)

        // Real turns can have moderate yaw but clear centripetal acceleration at higher speed.
        // v * yaw estimates expected lateral acceleration and improves curve recall.
        let expectedLatFromYaw = speedMS * absYaw
        let hardYawThreshold = max(settings.sharpTurnYawRateThreshold * 0.6, 0.35)
        let veryHardYawThreshold = max(settings.verySharpTurnYawRateThreshold * 0.7, 0.9)
        let turnEvidence = max(
            absLatAccel / max(hardLatThreshold, 0.1),
            expectedLatFromYaw / max(hardLatThreshold, 0.1),
            absYaw / max(hardYawThreshold, 0.1)
        )

        // During turns with slight phone misalignment, projected longitudinal force can spike.
        // Raise accel/brake thresholds in strong turning context to avoid wrong labels.
        let strongTurningContext = turnEvidence >= 0.9
        let longThresholdFactor = strongTurningContext ? 1.25 : 1.0
        let hardAccelThreshold = settings.hardAccelThresholdMS2 * longThresholdFactor
        let veryHardAccelThreshold = settings.veryHardAccelThresholdMS2 * longThresholdFactor
        let hardBrakeThreshold = settings.hardBrakeThresholdMS2 * longThresholdFactor
        let veryHardBrakeThreshold = settings.veryHardBrakeThresholdMS2 * longThresholdFactor

        var accelCandidate: EventSeverity = {
            guard speedKmh >= settings.minEventSpeedKmh else { return .none }
            if filteredLongAccel >= veryHardAccelThreshold { return .veryHard }
            if filteredLongAccel >= hardAccelThreshold { return .hard }
            return .none
        }()

        var brakeCandidate: EventSeverity = {
            guard speedKmh >= settings.minEventSpeedKmh else { return .none }
            if filteredLongAccel <= -veryHardBrakeThreshold { return .veryHard }
            if filteredLongAccel <= -hardBrakeThreshold { return .hard }
            return .none
        }()

        let turnCandidate: EventSeverity = {
            guard speedKmh >= settings.minEventSpeedKmh else { return .none }
            if turnEvidence >= 1.85 ||
                (absLatAccel >= veryHardLatThreshold && absYaw >= hardYawThreshold * 0.65) ||
                absYaw >= veryHardYawThreshold {
                return .veryHard
            }
            if turnEvidence >= 1.0 ||
                (absLatAccel >= hardLatThreshold * 0.9 && absYaw >= hardYawThreshold * 0.6) {
                return .hard
            }
            return .none
        }()

        let accelEvidence = max(0, filteredLongAccel) / max(hardAccelThreshold, 0.1)
        let brakeEvidence = max(0, -filteredLongAccel) / max(hardBrakeThreshold, 0.1)
        let longitudinalEvidence = max(accelEvidence, brakeEvidence)

        // Arbitration between turn and longitudinal events.
        // Prefer the stronger normalized evidence to prevent mixed maneuvers from being mislabeled.
        if turnCandidate != .none && turnEvidence > longitudinalEvidence * 1.05 {
            accelCandidate = .none
            brakeCandidate = .none
        }

        var effectiveTurnCandidate: EventSeverity = turnCandidate
        if turnCandidate == .hard && longitudinalEvidence > turnEvidence * 1.3 {
            effectiveTurnCandidate = .none
        }

        classificationDebug = MotionClassificationDebugSnapshot(
            timestamp: Date(),
            speedKmh: speedKmh,
            longAccelMS2: filteredLongAccel,
            latAccelMS2: filteredLatAccel,
            yawRate: filteredYawRate,
            turnEvidence: turnEvidence,
            accelEvidence: accelEvidence,
            brakeEvidence: brakeEvidence,
            longitudinalEvidence: longitudinalEvidence,
            decision: decisionLabel(accel: accelCandidate, brake: brakeCandidate, turn: effectiveTurnCandidate, isCalibrating: false),
            isCalibrating: false
        )

        accelAboveThresholdDuration = accelCandidate == .none ? 0 : accelAboveThresholdDuration + effectiveDt
        brakeAboveThresholdDuration = brakeCandidate == .none ? 0 : brakeAboveThresholdDuration + effectiveDt
        turnAboveThresholdDuration = effectiveTurnCandidate == .none ? 0 : turnAboveThresholdDuration + effectiveDt

        if activeAccelSeverity == .none, accelCandidate != .none, accelAboveThresholdDuration >= settings.minEventDurationSeconds, nowTime - lastAccelEventTime >= settings.eventCooldownSeconds {
            let id = UUID()
            activeAccelEventId = id
            activeAccelSeverity = accelCandidate
            lastAccelEventTime = nowTime
            emitEvent(id: id, type: .acceleration, severity: accelCandidate, speedKmh: speedKmh, g: abs(filteredLongAccel) / 9.81)
        } else if activeAccelSeverity == .hard, accelCandidate == .veryHard, let id = activeAccelEventId {
            activeAccelSeverity = .veryHard
            emitEvent(id: id, type: .acceleration, severity: .veryHard, speedKmh: speedKmh, g: abs(filteredLongAccel) / 9.81, isUpgrade: true)
        }

        if activeBrakeSeverity == .none, brakeCandidate != .none, brakeAboveThresholdDuration >= settings.minEventDurationSeconds, nowTime - lastBrakeEventTime >= settings.eventCooldownSeconds {
            let id = UUID()
            activeBrakeEventId = id
            activeBrakeSeverity = brakeCandidate
            lastBrakeEventTime = nowTime
            emitEvent(id: id, type: .brake, severity: brakeCandidate, speedKmh: speedKmh, g: abs(filteredLongAccel) / 9.81)
        } else if activeBrakeSeverity == .hard, brakeCandidate == .veryHard, let id = activeBrakeEventId {
            activeBrakeSeverity = .veryHard
            emitEvent(id: id, type: .brake, severity: .veryHard, speedKmh: speedKmh, g: abs(filteredLongAccel) / 9.81, isUpgrade: true)
        }

        if activeTurnSeverity == .none, effectiveTurnCandidate != .none, turnAboveThresholdDuration >= settings.minEventDurationSeconds, nowTime - lastTurnEventTime >= settings.eventCooldownSeconds {
            let id = UUID()
            activeTurnEventId = id
            activeTurnSeverity = effectiveTurnCandidate
            lastTurnEventTime = nowTime
            emitEvent(id: id, type: .turn, severity: effectiveTurnCandidate, speedKmh: speedKmh, g: abs(filteredLatAccel) / 9.81)
        } else if activeTurnSeverity == .hard, effectiveTurnCandidate == .veryHard, let id = activeTurnEventId {
            activeTurnSeverity = .veryHard
            emitEvent(id: id, type: .turn, severity: .veryHard, speedKmh: speedKmh, g: abs(filteredLatAccel) / 9.81, isUpgrade: true)
        }

        if activeAccelSeverity != .none && filteredLongAccel < settings.hardAccelThresholdMS2 * settings.hysteresisReleaseFactor { activeAccelSeverity = .none; activeAccelEventId = nil }
        if activeBrakeSeverity != .none && filteredLongAccel > -settings.hardBrakeThresholdMS2 * settings.hysteresisReleaseFactor { activeBrakeSeverity = .none; activeBrakeEventId = nil }
        if activeTurnSeverity != .none && abs(filteredYawRate) < settings.sharpTurnYawRateThreshold * settings.hysteresisReleaseFactor && abs(filteredLatAccel) < settings.sharpTurnLateralThresholdMS2 * settings.hysteresisReleaseFactor { activeTurnSeverity = .none; activeTurnEventId = nil }

        let activeSeverities = [activeAccelSeverity, activeBrakeSeverity, activeTurnSeverity]
        if activeSeverities.contains(.veryHard) {
            liveErrorSeverity = .veryHard
        } else if activeSeverities.contains(.hard) {
            liveErrorSeverity = .hard
        } else {
            liveErrorSeverity = nil
        }
    }

    @MainActor
    private func emitEvent(id: UUID, type: DriveErrorEventType, severity: EventSeverity, speedKmh: Double, g: Double, isUpgrade: Bool = false) {
        let driveSeverity: DriveErrorEventSeverity = severity == .veryHard ? .veryHard : .hard
        let event = MotionEvent(
            id: id,
            kind: isUpgrade ? .upgraded : .started,
            timestamp: Date(),
            type: type,
            severity: driveSeverity,
            speedKmh: speedKmh,
            accelerationG: g
        )

        if isUpgrade {
            if let index = events.firstIndex(where: { $0.id == id }) {
                events[index] = event
            }
        } else {
            events.append(event)
        }

        latestMotionEvent = event
        updateCounters()
    }

    private func prepareRollingCalibration(resetAxes: Bool) {
        calibrationGravityEMA = SIMD3<Double>(0, 0, -1)
        calibrationForwardEMA = SIMD3<Double>(repeating: 0)
        calibrationValidSampleCount = 0
        calibrationPositiveSampleCount = 0
        calibrationNegativeSampleCount = 0
        latestGpsAccelerationMS2 = 0
        lastGpsSpeedSampleAt = nil
        lastGpsSpeedMSForCalibration = nil
        isAxisCalibrationReady = false

        if resetAxes {
            forwardAxis = SIMD3<Double>(1, 0, 0)
            lateralAxis = SIMD3<Double>(0, 1, 0)
            gravityAxis = SIMD3<Double>(0, 0, -1)
        }

        DispatchQueue.main.async {
            self.isCalibrating = true
        }
    }

    private func updateRollingCalibrationIfNeeded(userAcceleration: SIMD3<Double>, gravity: SIMD3<Double>, yawRate: Double) {
        guard !isAxisCalibrationReady else { return }
        guard motionSpeedMS * 3.6 >= minInitialCalibrationSpeedKmh else { return }

        let normalizedGravity = normalizedOrDefault(gravity, defaultValue: gravityAxis)
        calibrationGravityEMA = normalizedOrDefault(
            calibrationGravityEMA * (1 - calibrationGravityAlpha) + normalizedGravity * calibrationGravityAlpha,
            defaultValue: normalizedGravity
        )

        let stabilizedGravity = normalizedOrDefault(calibrationGravityEMA, defaultValue: normalizedGravity)
        let horizontalAccel = userAcceleration - simd_dot(userAcceleration, stabilizedGravity) * stabilizedGravity
        guard simd_length(horizontalAccel) >= minCalibrationHorizontalAccelG else { return }
        guard abs(yawRate) <= minCalibrationYawRate else { return }
        guard abs(latestGpsAccelerationMS2) >= minCalibrationGpsAccelMS2 else { return }

        let accelerationSign = latestGpsAccelerationMS2 >= 0 ? 1.0 : -1.0
        let signedForwardObservation = horizontalAccel * accelerationSign
        let forwardProjected = signedForwardObservation - simd_dot(signedForwardObservation, stabilizedGravity) * stabilizedGravity
        guard simd_length(forwardProjected) >= minCalibrationHorizontalAccelG else { return }

        // Reject samples that suddenly point opposite to the current forward estimate.
        if simd_length(calibrationForwardEMA) >= 0.0001 {
            let candidateForward = normalizedOrDefault(forwardProjected, defaultValue: calibrationForwardEMA)
            let emaForward = normalizedOrDefault(calibrationForwardEMA, defaultValue: candidateForward)
            guard simd_dot(candidateForward, emaForward) >= calibrationForwardConsistencyMinDot else { return }
        }

        if simd_length(calibrationForwardEMA) < 0.0001 {
            calibrationForwardEMA = forwardProjected
        } else {
            calibrationForwardEMA = calibrationForwardEMA * (1 - calibrationForwardAlpha) + forwardProjected * calibrationForwardAlpha
        }

        let normalizedForward = normalizedOrDefault(calibrationForwardEMA, defaultValue: forwardAxis)
        let forwardOrtho = normalizedForward - simd_dot(normalizedForward, stabilizedGravity) * stabilizedGravity
        let stabilizedForward = normalizedOrDefault(forwardOrtho, defaultValue: forwardAxis)
        let stabilizedLateral = normalizedOrDefault(simd_cross(stabilizedGravity, stabilizedForward), defaultValue: lateralAxis)

        gravityAxis = stabilizedGravity
        forwardAxis = stabilizedForward
        lateralAxis = stabilizedLateral
        currentForwardAxis = stabilizedForward

        calibrationValidSampleCount += 1
        if accelerationSign >= 0 {
            calibrationPositiveSampleCount += 1
        } else {
            calibrationNegativeSampleCount += 1
        }

        if calibrationValidSampleCount >= calibrationReadySampleCount,
           calibrationPositiveSampleCount >= calibrationMinSamplesPerDirection,
           calibrationNegativeSampleCount >= calibrationMinSamplesPerDirection {
            isAxisCalibrationReady = true
            DispatchQueue.main.async {
                self.isCalibrating = false
            }
        }
    }

    private func normalizedOrDefault(_ vector: SIMD3<Double>, defaultValue: SIMD3<Double>) -> SIMD3<Double> {
        let length = simd_length(vector)
        return length < 0.0001 ? defaultValue : vector / length
    }

    @MainActor
    func injectTestForces(longMS2: Double, latMS2: Double) {
        if longMS2 == 0 && latMS2 == 0 {
            testOverrideLong = nil
            testOverrideLat = nil
            motionSpeedMS = 0
            return
        }

        testOverrideLong = longMS2
        testOverrideLat = latMS2
        motionSpeedMS = 40.0 / 3.6

        let wasCalibrating = isCalibrating
        isCalibrating = false
        processInternal(accelMS2: longMS2, lateralMS2: latMS2, yawRate: 0, dt: 0.02)
        isCalibrating = wasCalibrating
    }
}
