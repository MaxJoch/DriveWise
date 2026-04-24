import Foundation
import CoreLocation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

final class FirebaseSyncService {
    static let shared = FirebaseSyncService()

    private let usersCollection = "users"
    private let drivesCollection = "drives"
    private let settingsCollection = "settings"
    private let appSettingsDocument = "app"
    private let syncBatchLimit = 1000
    private let maxRoutePointsForSync = 1200
    private var pendingSettingsPush: DispatchWorkItem?
    private let routeStorageService = DriveRouteStorageService()
    private let routePolylineCodec = DriveRoutePolylineCodec()

    private init() {}

    var isAvailable: Bool {
#if canImport(FirebaseFirestore)
        return true
#else
        return false
#endif
    }

    func pullDrives(for userIdentifier: String?, completion: @escaping (Result<[Drive], Error>) -> Void) {
#if canImport(FirebaseFirestore)
        guard let userIdentifier, !userIdentifier.isEmpty else {
            completion(.success([]))
            return
        }

        firestore
            .collection(usersCollection)
            .document(userIdentifier)
            .collection(drivesCollection)
            .order(by: "startDate", descending: true)
            .limit(to: syncBatchLimit)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let drives = snapshot?.documents.compactMap { self.drive(from: $0) } ?? []
                completion(.success(drives))
            }
#else
        completion(.success([]))
#endif
    }

    func pushDrive(_ drive: Drive, routeCoordinates: [CLLocationCoordinate2D]? = nil, for userIdentifier: String?) {
#if canImport(FirebaseFirestore)
        guard let userIdentifier, !userIdentifier.isEmpty else { return }

        firestore
            .collection(usersCollection)
            .document(userIdentifier)
            .collection(drivesCollection)
            .document(drive.id.uuidString)
            .setData(driveToDictionary(drive, routeCoordinatesOverride: routeCoordinates), merge: true)
#endif
    }

    func deleteDrive(id: UUID, for userIdentifier: String?) {
#if canImport(FirebaseFirestore)
        guard let userIdentifier, !userIdentifier.isEmpty else { return }

        firestore
            .collection(usersCollection)
            .document(userIdentifier)
            .collection(drivesCollection)
            .document(id.uuidString)
            .delete()
#endif
    }

    func pullSettings(for userIdentifier: String?, completion: (() -> Void)? = nil) {
#if canImport(FirebaseFirestore)
        guard let userIdentifier, !userIdentifier.isEmpty else {
            completion?()
            return
        }

        firestore
            .collection(usersCollection)
            .document(userIdentifier)
            .collection(settingsCollection)
            .document(appSettingsDocument)
            .getDocument { snapshot, _ in
                defer { completion?() }
                guard let data = snapshot?.data() else { return }

                self.applyRemoteSettings(data)
            }
#else
        completion?()
#endif
    }

    func schedulePushCurrentSettings(for userIdentifier: String?) {
#if canImport(FirebaseFirestore)
        guard let userIdentifier, !userIdentifier.isEmpty else { return }
        let cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
        guard cloudSyncEnabled else { return }

        pendingSettingsPush?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.pushCurrentSettingsNow(for: userIdentifier)
        }
        pendingSettingsPush = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: workItem)
#endif
    }

    private func applyRemoteSettings(_ data: [String: Any]) {
        if let remoteUpdatedAt = remoteSettingsTimestamp(from: data),
           let localMutationDate = AppUserDefaults.lastLocalSettingsMutationDate(),
           localMutationDate > remoteUpdatedAt {
            return
        }

        if let notificationsEnabled = data[AppSettingKeys.notificationsEnabled] as? Bool {
            AppUserDefaults.set(notificationsEnabled, for: AppSettingKeys.notificationsEnabled, source: .remoteSync)
        }
        if let acousticWarningEnabled = data[AppSettingKeys.acousticWarningEnabled] as? Bool {
            AppUserDefaults.set(acousticWarningEnabled, for: AppSettingKeys.acousticWarningEnabled, source: .remoteSync)
        }
        if let keepDisplayAwakeWhileTracking = data[AppSettingKeys.keepDisplayAwakeWhileTracking] as? Bool {
            AppUserDefaults.set(keepDisplayAwakeWhileTracking, for: AppSettingKeys.keepDisplayAwakeWhileTracking, source: .remoteSync)
        }
        if let autoTrackDrives = data[AppSettingKeys.autoTrackDrives] as? Bool {
            AppUserDefaults.set(autoTrackDrives, for: AppSettingKeys.autoTrackDrives, source: .remoteSync)
        }
        if let routeCloudSyncEnabled = data[AppSettingKeys.routeCloudSyncEnabled] as? Bool {
            AppUserDefaults.set(routeCloudSyncEnabled, for: AppSettingKeys.routeCloudSyncEnabled, source: .remoteSync)
        }

        if let autoTrackStartSpeedKmh = data[AppSettingKeys.autoTrackStartSpeedKmh] as? Double {
            AppUserDefaults.set(autoTrackStartSpeedKmh, for: AppSettingKeys.autoTrackStartSpeedKmh, source: .remoteSync)
        }
        if let autoTrackStopSpeedKmh = data[AppSettingKeys.autoTrackStopSpeedKmh] as? Double {
            AppUserDefaults.set(autoTrackStopSpeedKmh, for: AppSettingKeys.autoTrackStopSpeedKmh, source: .remoteSync)
        }
        if let autoTrackStartStableSeconds = data[AppSettingKeys.autoTrackStartStableSeconds] as? Double {
            AppUserDefaults.set(autoTrackStartStableSeconds, for: AppSettingKeys.autoTrackStartStableSeconds, source: .remoteSync)
        }
        if let autoTrackStopStableSeconds = data[AppSettingKeys.autoTrackStopStableSeconds] as? Double {
            AppUserDefaults.set(autoTrackStopStableSeconds, for: AppSettingKeys.autoTrackStopStableSeconds, source: .remoteSync)
        }
    }

    private func remoteSettingsTimestamp(from data: [String: Any]) -> Date? {
#if canImport(FirebaseFirestore)
        if let timestamp = data["updatedAt"] as? Timestamp {
            return timestamp.dateValue()
        }
#endif
        return data["updatedAt"] as? Date
    }

    private func pushCurrentSettingsNow(for userIdentifier: String) {
#if canImport(FirebaseFirestore)
        let payload: [String: Any] = [
            AppSettingKeys.notificationsEnabled: AppUserDefaults.bool(for: AppSettingKeys.notificationsEnabled, default: AppSettingDefaults.notificationsEnabled),
            AppSettingKeys.acousticWarningEnabled: AppUserDefaults.bool(for: AppSettingKeys.acousticWarningEnabled, default: AppSettingDefaults.acousticWarningEnabled),
            AppSettingKeys.keepDisplayAwakeWhileTracking: AppUserDefaults.bool(for: AppSettingKeys.keepDisplayAwakeWhileTracking, default: AppSettingDefaults.keepDisplayAwakeWhileTracking),
            AppSettingKeys.autoTrackDrives: AppUserDefaults.bool(for: AppSettingKeys.autoTrackDrives, default: AppSettingDefaults.autoTrackDrives),
            AppSettingKeys.routeCloudSyncEnabled: AppUserDefaults.bool(for: AppSettingKeys.routeCloudSyncEnabled, default: AppSettingDefaults.routeCloudSyncEnabled),
            AppSettingKeys.autoTrackStartSpeedKmh: AppUserDefaults.double(for: AppSettingKeys.autoTrackStartSpeedKmh, default: AppSettingDefaults.autoTrackStartSpeedKmh),
            AppSettingKeys.autoTrackStopSpeedKmh: AppUserDefaults.double(for: AppSettingKeys.autoTrackStopSpeedKmh, default: AppSettingDefaults.autoTrackStopSpeedKmh),
            AppSettingKeys.autoTrackStartStableSeconds: AppUserDefaults.double(for: AppSettingKeys.autoTrackStartStableSeconds, default: AppSettingDefaults.autoTrackStartStableSeconds),
            AppSettingKeys.autoTrackStopStableSeconds: AppUserDefaults.double(for: AppSettingKeys.autoTrackStopStableSeconds, default: AppSettingDefaults.autoTrackStopStableSeconds),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        firestore
            .collection(usersCollection)
            .document(userIdentifier)
            .collection(settingsCollection)
            .document(appSettingsDocument)
            .setData(payload, merge: true)
#endif
    }

#if canImport(FirebaseFirestore)
    private var firestore: Firestore {
        Firestore.firestore()
    }
#endif

    private func driveToDictionary(_ drive: Drive, routeCoordinatesOverride: [CLLocationCoordinate2D]? = nil) -> [String: Any] {
        var payload = drive.toDictionary()
        payload["updatedAt"] = Date()

        let routeSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.routeCloudSyncEnabled, default: AppSettingDefaults.routeCloudSyncEnabled)
        if routeSyncEnabled {
            let routeSource: [CLLocationCoordinate2D]
            if let routeCoordinatesOverride, routeCoordinatesOverride.count >= 2 {
                routeSource = routeCoordinatesOverride
            } else {
                routeSource = routeStorageService.loadRoute(for: drive.id)
            }

            if routeSource.count >= 2 {
                let limitedRoute = cappedRouteForSync(from: routeSource)
                let encodedPolyline = routePolylineCodec.encode(limitedRoute)
                if !encodedPolyline.isEmpty {
                    payload["routePolyline"] = encodedPolyline
                    payload["routePointCount"] = limitedRoute.count
                }
            }
        }

        return payload
    }

    private func drive(from document: Any) -> Drive? {
#if canImport(FirebaseFirestore)
        guard let document = document as? QueryDocumentSnapshot else { return nil }
        var data = document.data()
        
        // Convert Timestamps to Dates for the model initializer
        for (key, value) in data {
            if let timestamp = value as? Timestamp {
                data[key] = timestamp.dateValue()
            } else if let events = value as? [[String: Any]] {
                data[key] = events.map { event in
                    var modEvent = event
                    if let ts = event["timestamp"] as? Timestamp {
                        modEvent["timestamp"] = ts.dateValue()
                    }
                    return modEvent
                }
            }
        }

        guard let drive = Drive(dictionary: data) else { return nil }

        if let encodedPolyline = data["routePolyline"] as? String {
            let decodedRoute = routePolylineCodec.decode(encodedPolyline)
            if decodedRoute.count >= 2 {
                try? routeStorageService.saveRoute(decodedRoute, for: drive.id)
            }
        }

        return drive
#else
        return nil
#endif
    }

    private func cappedRouteForSync(from coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard coordinates.count > maxRoutePointsForSync else {
            return coordinates
        }

        var sampled: [CLLocationCoordinate2D] = []
        sampled.reserveCapacity(maxRoutePointsForSync)

        let maxIndex = coordinates.count - 1
        let denominator = max(maxRoutePointsForSync - 1, 1)

        for sampleIndex in 0..<maxRoutePointsForSync {
            let scaledIndex = Int(round(Double(sampleIndex) * Double(maxIndex) / Double(denominator)))
            sampled.append(coordinates[scaledIndex])
        }

        return sampled
    }
}
