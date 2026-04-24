import Foundation
import SwiftUI
import Combine
import CoreLocation
import MapKit
import CoreData
import AudioToolbox
import AVFoundation
import UIKit

final class DriveManager: NSObject, ObservableObject {
    private let statusPersistenceSeconds: TimeInterval = 1.0
    private let minimumTrackedDriveDurationSeconds: Int = 60
    private let errorFeedbackCooldownSeconds: TimeInterval = 0.4
    private let errorToneSystemSoundID: SystemSoundID = 1052
    private var autoStartSpeedThresholdKmh: Double {
        AppUserDefaults.double(for: AppSettingKeys.autoTrackStartSpeedKmh, default: AppSettingDefaults.autoTrackStartSpeedKmh)
    }
    private var autoStopSpeedThresholdKmh: Double {
        AppUserDefaults.double(for: AppSettingKeys.autoTrackStopSpeedKmh, default: AppSettingDefaults.autoTrackStopSpeedKmh)
    }
    private var autoStartStableSeconds: TimeInterval {
        AppUserDefaults.double(for: AppSettingKeys.autoTrackStartStableSeconds, default: AppSettingDefaults.autoTrackStartStableSeconds)
    }
    private var autoStopStableSeconds: TimeInterval {
        AppUserDefaults.double(for: AppSettingKeys.autoTrackStopStableSeconds, default: AppSettingDefaults.autoTrackStopStableSeconds)
    }
#if canImport(ActivityKit)
    private let liveActivityManager = DriveLiveActivityManager.shared
#endif

    // MARK: - Published Properties
    @Published private(set) var drives: [Drive] = []
    @Published var isDriving: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var distanceKm: Double = 0
    @Published var currentSpeedKmh: Double = 0
    @Published var maxSpeedKmh: Double = 0
    @Published var errorCount: Int = 0
    
    // Normal severity events
    @Published var hardBrakeCount: Int = 0
    @Published var hardAccelCount: Int = 0
    @Published var sharpTurnCount: Int = 0
    
    // Very hard severity events
    @Published var veryHardBrakeCount: Int = 0
    @Published var veryHardAccelCount: Int = 0
    @Published var verySharpTurnCount: Int = 0
    
    // Speeding
    @Published var speedingKm: Double = 0
    
    @Published var maxAccelMS2: Double = 0
    @Published var maxBrakeMS2: Double = 0
    @Published var currentForwardAccelG: Double = 0
    @Published var currentLateralAccelG: Double = 0
    @Published var currentForwardAxis: SIMD3<Double> = SIMD3<Double>(1, 0, 0)
    @Published private(set) var motionDebugSnapshot: MotionClassificationDebugSnapshot = .empty
    @Published var currentScore: Int = 100
    @Published var overallScore: Int = 100
    @Published private(set) var liveErrorSeverity: DriveErrorEventSeverity?
    @Published private(set) var lastMotionEventSeverity: DriveErrorEventSeverity?
    @Published private(set) var lastMotionEventDate: Date?
    @Published private(set) var isCalibratingSensors: Bool = false
    @Published var lastError: DriveWiseError?
    @Published var isSyncing: Bool = false
    @Published var lastSyncError: String?
    
    // MARK: - Services
    private let locationService: LocationService
    private let storageService: DriveStorageService
    private let motionService: MotionService
    private let notificationService: DriveNotificationService
    private let firebaseSyncService: FirebaseSyncService
    private let userIdentifier: String?
    
    // MARK: - Private Properties
    private var startDate: Date?
    private var startLocation: CLLocation?
    private var startPlaceName: String?
    private var startCityName: String?
    private var currentDriveErrorEvents: [DriveErrorEvent] = []
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var lastErrorFeedbackAt: Date?
    private var lowSpeedSince: Date?
    private var highSpeedSince: Date?
    private var wasAutoStartedDrive: Bool = false
    private var hasAttemptedFirebaseBootstrap = false
    private var preferencesDidChangeCancellable: AnyCancellable?
    
    // MARK: - Initialization
    init(
        locationService: LocationService = LocationService(),
        storageService: DriveStorageService? = nil,
        motionService: MotionService = MotionService(),
        notificationService: DriveNotificationService = .shared,
        firebaseSyncService: FirebaseSyncService = .shared,
        userIdentifier: String? = SessionUserContext.activeUserIdentifier
    ) {
        self.userIdentifier = userIdentifier
        self.locationService = locationService
        self.storageService = storageService ?? DriveStorageService(persistenceController: .forUser(userIdentifier))
        self.motionService = motionService
        self.notificationService = notificationService
        self.firebaseSyncService = firebaseSyncService
        super.init()
        
        setupLocationObservers()
        setupMotionObservers()
        setupPreferenceObservers()
        locationService.requestAuthorization()
        loadDrives()
        notificationService.requestAuthorizationIfNeeded()
        
        // Only schedule settings push if cloud sync is enabled
        let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
        if cloudSyncEnabled {
            firebaseSyncService.schedulePushCurrentSettings(for: userIdentifier)
        }
        
        synchronizeFromFirebaseIfNeeded()
    }
    
    private func setupLocationObservers() {
        locationService.$currentSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                guard let self else { return }
                if self.isDriving {
                    self.motionService.updateSpeedFromGPS(speedKmh: speed)
                }
                self.evaluateAutoTracking(withSpeedKmh: speed)
            }
            .store(in: &cancellables)
        
        locationService.$distanceSinceStartKm
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                guard let self = self, self.isDriving else { return }
                self.distanceKm = distance
                self.motionService.updateDistance(distanceKm: distance)
                self.refreshLiveActivity()
            }
            .store(in: &cancellables)
        
        locationService.$authorizationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.lastError = error
            }
            .store(in: &cancellables)
    }

    private func setupMotionObservers() {
        motionService.$smoothedSpeedKmh
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                guard let self = self, self.isDriving else { return }
                self.currentSpeedKmh = speed
                if speed > self.maxSpeedKmh {
                    self.maxSpeedKmh = speed
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest4(
            motionService.$hardBrakeCount,
            motionService.$veryHardBrakeCount,
            motionService.$hardAccelCount,
            motionService.$veryHardAccelCount
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] hardBrake, veryHardBrake, hardAccel, veryHardAccel in
            guard let self else { return }
            self.hardBrakeCount = hardBrake
            self.veryHardBrakeCount = veryHardBrake
            self.hardAccelCount = hardAccel
            self.veryHardAccelCount = veryHardAccel
            self.recomputeErrorCount()
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            motionService.$sharpTurnCount,
            motionService.$verySharpTurnCount,
            motionService.$speedingKm
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] turn, veryTurn, speeding in
            guard let self else { return }
            self.sharpTurnCount = turn
            self.verySharpTurnCount = veryTurn
            self.speedingKm = speeding
            self.recomputeErrorCount()
            self.refreshLiveActivity()
        }
        .store(in: &cancellables)

        motionService.$isCalibrating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCalibrating in
                self?.isCalibratingSensors = isCalibrating
            }
            .store(in: &cancellables)

        motionService.$maxAccelMS2
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.maxAccelMS2 = value
            }
            .store(in: &cancellables)

        motionService.$maxBrakeMS2
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.maxBrakeMS2 = value
            }
            .store(in: &cancellables)

        motionService.$currentForwardAccelG
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.currentForwardAccelG = value
            }
            .store(in: &cancellables)

        motionService.$currentLateralAccelG
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.currentLateralAccelG = value
            }
            .store(in: &cancellables)

        motionService.$currentForwardAxis
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.currentForwardAxis = value
            }
            .store(in: &cancellables)

        motionService.$classificationDebug
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.motionDebugSnapshot = snapshot
            }
            .store(in: &cancellables)

        motionService.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.lastError = error
            }
            .store(in: &cancellables)

        motionService.$liveErrorSeverity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] severity in
                self?.liveErrorSeverity = severity
                self?.refreshLiveActivity()
            }
            .store(in: &cancellables)

        motionService.$latestMotionEvent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.upsertMotionEvent(event)
                self?.emitErrorFeedbackIfNeeded(for: event)
                self?.lastMotionEventSeverity = event.severity
                self?.lastMotionEventDate = event.timestamp
                self?.refreshLiveActivity()
            }
            .store(in: &cancellables)
    }

    private func setupPreferenceObservers() {
        preferencesDidChangeCancellable = NotificationCenter.default.publisher(for: AppUserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                guard let changedKey = notification.object as? String else {
                    self.updateIdleTimerPolicy()
                    return
                }

                if changedKey == AppSettingKeys.keepDisplayAwakeWhileTracking || changedKey == AppSettingKeys.cloudSyncEnabled {
                    self.updateIdleTimerPolicy()
                }
            }
    }

    private func upsertMotionEvent(_ event: MotionEvent) {
        guard isDriving else { return }

        let currentLocation = locationService.currentLocation

        if let index = currentDriveErrorEvents.firstIndex(where: { $0.id == event.id }) {
            currentDriveErrorEvents[index].timestamp = event.timestamp
            currentDriveErrorEvents[index].severity = event.severity
            currentDriveErrorEvents[index].speedKmh = event.speedKmh
            currentDriveErrorEvents[index].accelerationG = event.accelerationG
            currentDriveErrorEvents[index].latitude = currentLocation?.coordinate.latitude
            currentDriveErrorEvents[index].longitude = currentLocation?.coordinate.longitude
        } else {
            currentDriveErrorEvents.append(
                DriveErrorEvent(
                    id: event.id,
                    timestamp: event.timestamp,
                    type: event.type,
                    severity: event.severity,
                    latitude: currentLocation?.coordinate.latitude,
                    longitude: currentLocation?.coordinate.longitude,
                    speedKmh: event.speedKmh,
                    accelerationG: event.accelerationG
                )
            )
        }
    }

    private func recomputeErrorCount() {
        errorCount = hardBrakeCount + veryHardBrakeCount +
                     hardAccelCount + veryHardAccelCount +
                     sharpTurnCount + verySharpTurnCount
    }

    private func emitErrorFeedbackIfNeeded(for event: MotionEvent) {
        guard isDriving else { return }
        guard event.kind == .started else { return }
        guard isAcousticWarningEnabled() else { return }

        let now = Date()
        if let lastErrorFeedbackAt,
           now.timeIntervalSince(lastErrorFeedbackAt) < errorFeedbackCooldownSeconds {
            return
        }
        lastErrorFeedbackAt = now

        let shouldUseVibration = shouldFallbackToVibration()
        let isVeryHard = event.severity == .veryHard

        playErrorFeedbackOnce(useVibration: shouldUseVibration)

        guard isVeryHard else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.playErrorFeedbackOnce(useVibration: shouldUseVibration)
        }
    }

    private func playErrorFeedbackOnce(useVibration: Bool) {
        if useVibration {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let haptic = UINotificationFeedbackGenerator()
            haptic.prepare()
            haptic.notificationOccurred(.warning)
            return
        }

        AudioServicesPlaySystemSound(errorToneSystemSoundID)
    }

    private func shouldFallbackToVibration() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let isVolumeMuted = audioSession.outputVolume <= 0.01
        let silencedHint = audioSession.secondaryAudioShouldBeSilencedHint
        return isVolumeMuted || silencedHint
    }

    private func isAcousticWarningEnabled() -> Bool {
        AppUserDefaults.bool(for: AppSettingKeys.acousticWarningEnabled, default: AppSettingDefaults.acousticWarningEnabled)
    }

    private func isAutoTrackingEnabled() -> Bool {
        AppUserDefaults.bool(for: AppSettingKeys.autoTrackDrives, default: AppSettingDefaults.autoTrackDrives)
    }

    private func isKeepDisplayAwakeEnabled() -> Bool {
        AppUserDefaults.bool(for: AppSettingKeys.keepDisplayAwakeWhileTracking, default: AppSettingDefaults.keepDisplayAwakeWhileTracking)
    }

    private func evaluateAutoTracking(withSpeedKmh speedKmh: Double) {
        guard isAutoTrackingEnabled() else {
            highSpeedSince = nil
            lowSpeedSince = nil
            return
        }

        let now = Date()

        if !isDriving {
            lowSpeedSince = nil
            if speedKmh >= autoStartSpeedThresholdKmh {
                if highSpeedSince == nil {
                    highSpeedSince = now
                }
                if let highSpeedStart = highSpeedSince,
                   now.timeIntervalSince(highSpeedStart) >= autoStartStableSeconds {
                    startDrive(initiatedByAutoTracking: true)
                    notificationService.notifyAutoTrackingStarted()
                    self.highSpeedSince = nil
                }
            } else {
                highSpeedSince = nil
            }
            return
        }

        highSpeedSince = nil

        guard wasAutoStartedDrive else {
            lowSpeedSince = nil
            return
        }

        if speedKmh <= autoStopSpeedThresholdKmh {
            if lowSpeedSince == nil {
                lowSpeedSince = now
            }

            if let lowSpeedSince,
               now.timeIntervalSince(lowSpeedSince) >= autoStopStableSeconds {
                stopDrive(initiatedByAutoTracking: true)
                self.lowSpeedSince = nil
            }
        } else {
            lowSpeedSince = nil
        }
    }

    private func updateIdleTimerPolicy() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = self.isDriving && self.isKeepDisplayAwakeEnabled()
        }
    }

    func refreshIdleTimerPolicy() {
        updateIdleTimerPolicy()
    }
    
    // MARK: - Persistence
    
    /// Lädt alle Fahrten aus Core Data
    private func loadDrives() {
        do {
            drives = try storageService.loadDrives()
            lastError = nil
        } catch let error as DriveWiseError {
            lastError = error
            drives = []
        } catch {
            lastError = .loadFailed(reason: error.localizedDescription)
            drives = []
        }
        calculateOverallScore()
        notificationService.refreshWeeklyRecap(allDrives: drives)
    }
    
    /// Refreshes achievements and statistics by reloading drives and recalculating
    func refreshAchievementsAndStatistics() {
        loadDrives()
        calculateOverallScore()
    }

    func synchronizeFromFirebaseAfterEnablingCloudSync() {
        synchronizeFromFirebaseIfNeeded(force: true)
    }

    func synchronizeFromPullToRefresh() {
        let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
        if cloudSyncEnabled {
            synchronizeFromFirebaseIfNeeded(force: true)
        } else {
            refreshAchievementsAndStatistics()
        }
    }

    private func synchronizeFromFirebaseIfNeeded(force: Bool = false) {
        guard force || !hasAttemptedFirebaseBootstrap else { return }
        if !force {
            hasAttemptedFirebaseBootstrap = true
        }
        
        // Check if cloud sync is enabled
        let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
        guard cloudSyncEnabled else {
            lastSyncError = nil
            return
        }
        
        guard firebaseSyncService.isAvailable else { return }
        guard let userIdentifier, !userIdentifier.isEmpty else { return }

        let localSnapshot = drives
        isSyncing = true
        lastSyncError = nil

        firebaseSyncService.pullSettings(for: userIdentifier)
        firebaseSyncService.pullDrives(for: userIdentifier) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let remoteDrives):
                DispatchQueue.main.async {
                    do {
                        let mergedDrives = self.mergeDrives(localDrives: localSnapshot, remoteDrives: remoteDrives)
                        let remoteDriveIDs = Set(remoteDrives.map { $0.id })
                        let localDrivesToUpload = localSnapshot.filter { !remoteDriveIDs.contains($0.id) }

                        if !localDrivesToUpload.isEmpty {
                            for localDrive in localDrivesToUpload {
                                self.firebaseSyncService.pushDrive(localDrive, for: userIdentifier)
                            }
                            self.firebaseSyncService.schedulePushCurrentSettings(for: userIdentifier)
                        }

                        try self.storageService.replaceAllDrives(with: mergedDrives)
                        self.loadDrives()
                        self.isSyncing = false
                        self.lastSyncError = nil
                    } catch {
                        self.isSyncing = false
                        self.lastSyncError = "Synchronisierung fehlgeschlagen: \(error.localizedDescription)"
                        self.lastError = .loadFailed(reason: error.localizedDescription)
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isSyncing = false
                    self.lastSyncError = "Cloud-Sync Fehler: \(error.localizedDescription)"
                }
            }
        }
    }

    private func mergeDrives(localDrives: [Drive], remoteDrives: [Drive]) -> [Drive] {
        var mergedByID: [UUID: Drive] = [:]

        for drive in remoteDrives {
            mergedByID[drive.id] = drive
        }

        for drive in localDrives {
            mergedByID[drive.id] = drive
        }

        return mergedByID.values.sorted { $0.startDate > $1.startDate }
    }
    
    /// Speichert eine neue Fahrt
    private func saveDrive(_ drive: Drive) {
        do {
            try storageService.saveDrive(drive)
            
            // Only push to Firebase if cloud sync is enabled
            let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
            if cloudSyncEnabled {
                firebaseSyncService.pushDrive(drive, for: userIdentifier)
            }
            
            loadDrives()
            notificationService.handleDriveCompleted(drive: drive, allDrives: drives)
            lastError = nil
        } catch let error as DriveWiseError {
            lastError = error
        } catch {
            lastError = .saveFailed(reason: error.localizedDescription)
        }
    }

    
    // For demo / UI purposes we simulate movement while driving
    func startDrive(initiatedByAutoTracking: Bool = false) {
        guard !isDriving else { return }
        // reset counters
        elapsedSeconds = 0
        distanceKm = 0
        currentSpeedKmh = 0
        maxSpeedKmh = 0
        errorCount = 0
        hardBrakeCount = 0
        hardAccelCount = 0
        sharpTurnCount = 0
        maxAccelMS2 = 0
        maxBrakeMS2 = 0
        currentScore = 100
        lastErrorFeedbackAt = nil
        liveErrorSeverity = nil
        lastMotionEventSeverity = nil
        lastMotionEventDate = nil
        currentDriveErrorEvents = []
        wasAutoStartedDrive = initiatedByAutoTracking
        lowSpeedSince = nil
        highSpeedSince = nil
        
        startDate = Date()
        startLocation = locationService.currentLocation
        startPlaceName = nil
        startCityName = nil

        // Start GPS tracking for distance
        do {
            try locationService.startTracking { _ in
                // Handle location updates (distance auto-published)
            }
        } catch let error as DriveWiseError {
            lastError = error
        } catch {
            lastError = .locationUnavailable
        }
        
        motionService.startTracking()
        
        // Get start location name using LocationService
        if let location = startLocation {
            locationService.reverseGeocode(location: location, fallback: "Startpunkt") { [weak self] result in
                switch result {
                case .success((let fullAddress, let city)):
                    DispatchQueue.main.async {
                        self?.startPlaceName = fullAddress
                        self?.startCityName = city
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self?.startPlaceName = "Startpunkt"
                        self?.startCityName = "Startpunkt"
                    }
                }
            }
        } else {
            startPlaceName = "Startpunkt"
            startCityName = "Startpunkt"
        }
        
        isDriving = true
        updateIdleTimerPolicy()
        startLiveActivity()
        
        // start a simple timer that simulates speed/distance
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.refreshLiveActivity()
        }
    }
    
    func stopDrive(initiatedByAutoTracking: Bool = false) {
        guard isDriving else { return }
        timer?.invalidate()
        timer = nil
        isDriving = false
        updateIdleTimerPolicy()
        liveErrorSeverity = nil
        endLiveActivity()

        locationService.stopTracking()
        motionService.stopTracking()

        if elapsedSeconds < minimumTrackedDriveDurationSeconds {
            lastError = .driveTooShort(minimumSeconds: minimumTrackedDriveDurationSeconds)
            resetAfterDriveStopped(resetCurrentScore: true)
            return
        }

        let motionSummary = motionService.summary()
        let score = calculateScore(
            distanceKm: distanceKm,
            durationSeconds: elapsedSeconds,
            hardBrakeCount: hardBrakeCount,
            veryHardBrakeCount: veryHardBrakeCount,
            hardAccelCount: hardAccelCount,
            veryHardAccelCount: veryHardAccelCount,
            sharpTurnCount: sharpTurnCount,
            verySharpTurnCount: verySharpTurnCount,
            speedingKm: speedingKm
        )
        currentScore = score
        let wasAutoTracked = wasAutoStartedDrive || initiatedByAutoTracking
        
        let end = Date()
        let start = startDate ?? end
        let fromName = startPlaceName ?? "Startpunkt"
        let fromCity = startCityName ?? "Startpunkt"
        let endLocation = locationService.currentLocation

        if let endLocation = endLocation {
            locationService.reverseGeocode(location: endLocation, fallback: "Zielpunkt") { [weak self] result in
                switch result {
                case .success((let fullAddress, let city)):
                    DispatchQueue.main.async {
                        self?.finishStopDrive(
                            start: start,
                            end: end,
                            fromName: fromName,
                            toName: fullAddress,
                            fromCity: fromCity,
                            toCity: city,
                            startLocation: self?.startLocation,
                            endLocation: endLocation,
                            motionSummary: motionSummary,
                            score: score,
                            wasAutoTracked: wasAutoTracked
                        )
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self?.finishStopDrive(
                            start: start,
                            end: end,
                            fromName: fromName,
                            toName: "Zielpunkt",
                            fromCity: fromCity,
                            toCity: "Zielpunkt",
                            startLocation: self?.startLocation,
                            endLocation: endLocation,
                            motionSummary: motionSummary,
                            score: score,
                            wasAutoTracked: wasAutoTracked
                        )
                    }
                }
            }
        } else {
            finishStopDrive(
                start: start,
                end: end,
                fromName: fromName,
                toName: "Zielpunkt",
                fromCity: fromCity,
                toCity: "Zielpunkt",
                startLocation: startLocation,
                endLocation: nil,
                motionSummary: motionSummary,
                score: score,
                wasAutoTracked: wasAutoTracked
            )
        }
    }

    func recalibrateSensors() {
        guard isDriving else { return }
        motionService.recalibrate()
    }

    /// Simuliert eine kurze Testsequenz für den Bewegungsalgorithmus.
    func runAlgorithmTest() {
        guard isDriving else {
            lastError = .loadFailed(reason: "Bitte erst eine Fahrt starten")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.simulateForce(long: 2.0, lat: 0.0, duration: 1.0)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                self.simulateForce(long: -2.2, lat: 0.0, duration: 1.0)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    self.simulateForce(long: 0.0, lat: 2.0, duration: 1.0)
                }
            }
        }
    }

    private func simulateForce(long: Double, lat: Double, duration: TimeInterval) {
        let steps = Int(duration * 50)
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                self.motionService.injectTestForces(longMS2: long * 9.81, latMS2: lat * 9.81)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
            self.motionService.injectTestForces(longMS2: 0, latMS2: 0)
        }
    }

    private func finishStopDrive(
        start: Date,
        end: Date,
        fromName: String,
        toName: String,
        fromCity: String,
        toCity: String,
        startLocation: CLLocation?,
        endLocation: CLLocation?,
        motionSummary: (hardBrakeCount: Int, hardAccelCount: Int, sharpTurnCount: Int, maxAccelMS2: Double, maxBrakeMS2: Double, maxLateralAccelMS2: Double),
        score: Int,
        wasAutoTracked: Bool
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let avgSpeed = self.elapsedSeconds > 0 ? (self.distanceKm / Double(self.elapsedSeconds) * 3600.0) : 0
            let drive = Drive(
                id: UUID(),
                startDate: start,
                endDate: end,
                from: fromName,
                to: toName,
                fromCity: fromCity,
                toCity: toCity,
                distanceKm: self.distanceKm,
                avgSpeedKmh: avgSpeed,
                maxSpeedKmh: self.maxSpeedKmh,
                maxAccelMS2: motionSummary.maxAccelMS2,
                maxBrakeMS2: motionSummary.maxBrakeMS2,
                maxLateralAccelMS2: motionSummary.maxLateralAccelMS2,
                hardBrakeCount: self.hardBrakeCount,
                hardAccelCount: self.hardAccelCount,
                sharpTurnCount: self.sharpTurnCount,
                veryHardBrakeCount: self.veryHardBrakeCount,
                veryHardAccelCount: self.veryHardAccelCount,
                verySharpTurnCount: self.verySharpTurnCount,
                speedingKm: self.speedingKm,
                errorCount: self.errorCount,
                score: score,
                startLatitude: startLocation?.coordinate.latitude,
                startLongitude: startLocation?.coordinate.longitude,
                endLatitude: endLocation?.coordinate.latitude,
                endLongitude: endLocation?.coordinate.longitude,
                errorEvents: self.currentDriveErrorEvents
            )
            self.saveDrive(drive)
            if wasAutoTracked {
                self.notificationService.notifyAutoTrackingStopped(score: score)
            }
            self.resetAfterDriveStopped()
        }
    }

    private func resetAfterDriveStopped(resetCurrentScore: Bool = false) {
        startLocation = nil
        startPlaceName = nil
        startCityName = nil
        startDate = nil
        currentDriveErrorEvents = []
        wasAutoStartedDrive = false
        lowSpeedSince = nil
        highSpeedSince = nil

        elapsedSeconds = 0
        distanceKm = 0
        currentSpeedKmh = 0
        maxSpeedKmh = 0
        errorCount = 0
        hardBrakeCount = 0
        hardAccelCount = 0
        sharpTurnCount = 0
        veryHardBrakeCount = 0
        veryHardAccelCount = 0
        verySharpTurnCount = 0
        speedingKm = 0
        maxAccelMS2 = 0
        maxBrakeMS2 = 0
        if resetCurrentScore {
            currentScore = 100
        }
        motionService.reset()
        updateIdleTimerPolicy()
    }

    private func calculateScore(
        distanceKm: Double,
        durationSeconds: Int,
        hardBrakeCount: Int,
        veryHardBrakeCount: Int,
        hardAccelCount: Int,
        veryHardAccelCount: Int,
        sharpTurnCount: Int,
        verySharpTurnCount: Int,
        speedingKm: Double
    ) -> Int {
        var score = 100
        let durationMinutes = Double(durationSeconds) / 60.0
        
        // ---|--- PENALTIES ---|---
        score -= hardBrakeCount * 5
        score -= veryHardBrakeCount * 10
        score -= hardAccelCount * 4
        score -= veryHardAccelCount * 8
        score -= sharpTurnCount * 3
        score -= verySharpTurnCount * 7
        score -= Int(speedingKm * 2.0)
        
        // ---|--- BONUSES (Zeit + Distanz kombiniert) ---|---
        let totalErrors = hardBrakeCount + veryHardBrakeCount +
                         hardAccelCount + veryHardAccelCount +
                         sharpTurnCount + verySharpTurnCount
        
        // Fehlerquote pro 10 km
        let errorsPerKm = distanceKm > 0 ? Double(totalErrors) / distanceKm : 0
        
        // Bonus: Wenige Fehler relative zur Fahrtstrecke
        if errorsPerKm < 0.1 {  // < 1 Fehler pro 10 km
            score += 10
        } else if errorsPerKm < 0.3 {  // < 3 Fehler pro 10 km
            score += 5
        }
        
        // Fehlerquote pro Minute
        let errorsPerMin = durationMinutes > 0 ? Double(totalErrors) / durationMinutes : 0
        
        // Bonus: Wenige Fehler relative zur Fahrtdauer
        if errorsPerMin < 0.05 {  // < 1 Fehler pro 20 Minuten
            score += 10
        } else if errorsPerMin < 0.15 {  // < 1 Fehler pro 6-7 Minuten
            score += 5
        }
        
        // Bonus: Konsistente Fahrt (ähnlich viele Fehler über Zeit & Distanz)
        let consistency = abs(errorsPerKm - errorsPerMin)
        if consistency < 0.05 {
            score += 5
        }
        
        // Bonus: Lange Fahrt ohne viele Fehler
        if distanceKm > 50 && totalErrors < 5 {
            score += 8
        }
        
        // Bonus: Kurze, saubere Fahrt
        if distanceKm < 10 && totalErrors == 0 {
            score += 5
        }
        
        // Cap zwischen 0 und 120
        return max(0, min(120, score))
    }

    private func startLiveActivity() {
#if canImport(ActivityKit)
        liveActivityManager.start(
            distanceKm: distanceKm,
            elapsedSeconds: elapsedSeconds,
            errorCount: errorCount,
            status: liveActivityStatus()
        )
#endif
    }

    private func refreshLiveActivity() {
        guard isDriving else { return }
#if canImport(ActivityKit)
        liveActivityManager.update(
            distanceKm: distanceKm,
            elapsedSeconds: elapsedSeconds,
            errorCount: errorCount,
            status: liveActivityStatus()
        )
#endif
    }

    private func endLiveActivity() {
#if canImport(ActivityKit)
        liveActivityManager.end(
            distanceKm: distanceKm,
            elapsedSeconds: elapsedSeconds,
            errorCount: errorCount,
            status: liveActivityStatus()
        )
#endif
    }

#if canImport(ActivityKit)
    private func liveActivityStatus(at now: Date = Date()) -> DriveTrackingActivityAttributes.ContentState.Status {
        if liveErrorSeverity == .veryHard {
            return .critical
        }

        if liveErrorSeverity == .hard {
            return .warning
        }

        if let eventDate = lastMotionEventDate,
           let eventSeverity = lastMotionEventSeverity,
           now.timeIntervalSince(eventDate) <= statusPersistenceSeconds {
            return eventSeverity == .veryHard ? .critical : .warning
        }

        return .good
    }
#endif
    
    /// Berechnet Gesamtscore aus allen Fahrten
    private func calculateOverallScore() {
        guard !drives.isEmpty else {
            overallScore = 100
            return
        }
        
        let averageScore = drives.reduce(0) { $0 + $1.score } / drives.count
        overallScore = averageScore
    }

    func removeDrives(at offsets: IndexSet) {
        let drivesToDelete = offsets.map { drives[$0] }
        let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
        
        for drive in drivesToDelete {
            do {
                try storageService.deleteDrive(drive)
                if cloudSyncEnabled {
                    firebaseSyncService.deleteDrive(id: drive.id, for: userIdentifier)
                }
            } catch let error as DriveWiseError {
                lastError = error
            } catch {
                lastError = .deleteFailed(reason: error.localizedDescription)
            }
        }
        
        loadDrives()
        refreshAchievementsAndStatistics()
    }
    
    /// Remove a single drive by ID
    func removeDrive(byId id: UUID) {
        guard let drive = drives.first(where: { $0.id == id }) else {
            lastError = .deleteFailed(reason: "Fahrt nicht gefunden")
            return
        }
        
        let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
        
        do {
            try storageService.deleteDrive(drive)
            if cloudSyncEnabled {
                firebaseSyncService.deleteDrive(id: drive.id, for: userIdentifier)
            }
            loadDrives()
            refreshAchievementsAndStatistics()
            lastError = nil
        } catch let error as DriveWiseError {
            lastError = error
        } catch {
            lastError = .deleteFailed(reason: error.localizedDescription)
        }
    }
}
