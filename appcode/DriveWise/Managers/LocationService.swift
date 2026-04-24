//
//  LocationService.swift
//  DriveWise
//
//  GPS tracking and geocoding service
//

import Foundation
import CoreLocation
import Combine
import MapKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0 // km/h
    @Published var distanceSinceStartKm: Double = 0 // aktualisiert bei Fahrt
    @Published var isAuthorized: Bool = false
    @Published var authorizationError: DriveWiseError?
    
    private let locationManager = CLLocationManager()
    private var distanceStartLocation: CLLocation?
    private var lastAcceptedLocation: CLLocation?
    private var cumulativeDistanceMeters: Double = 0
    private var onLocationUpdate: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking(onUpdate: @escaping (CLLocation) -> Void) throws {
        guard isAuthorized else {
            throw DriveWiseError.locationPermissionDenied
        }
        
        self.onLocationUpdate = onUpdate
        distanceStartLocation = currentLocation
        lastAcceptedLocation = currentLocation
        cumulativeDistanceMeters = 0
        distanceSinceStartKm = 0
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        distanceStartLocation = nil
        lastAcceptedLocation = nil
        cumulativeDistanceMeters = 0
        onLocationUpdate = nil
    }
    
    func calculateDistanceSinceStart() -> Double {
        guard distanceStartLocation != nil else { return 0 }
        return cumulativeDistanceMeters / 1000.0
    }
    
    func resetForNewDrive() {
        distanceStartLocation = currentLocation
        lastAcceptedLocation = currentLocation
        cumulativeDistanceMeters = 0
        distanceSinceStartKm = 0
        currentSpeed = 0
    }

    private func isUsableForDistance(_ location: CLLocation) -> Bool {
        let isAccuracyValid = location.horizontalAccuracy > 0 && location.horizontalAccuracy <= 40
        let isRecentEnough = abs(location.timestamp.timeIntervalSinceNow) <= 10
        return isAccuracyValid && isRecentEnough
    }
    
    // MARK: - Geocoding
    
    func reverseGeocode(
        location: CLLocation,
        fallback: String,
        completion: @escaping (Result<(fullAddress: String, city: String), DriveWiseError>) -> Void
    ) {
        Task {
            if #available(iOS 26.0, *) {
                do {
                    guard let request = MKReverseGeocodingRequest(location: location) else {
                        await MainActor.run {
                            completion(.success((fallback, fallback)))
                        }
                        return
                    }

                    let mapItems = try await request.mapItems

                    await MainActor.run {
                        let mapItem = mapItems.first
                        let addressRepresentations = mapItem?.addressRepresentations
                        let fullAddress = addressRepresentations?.fullAddress(includingRegion: false, singleLine: true)
                            ?? mapItem?.address?.fullAddress
                            ?? mapItem?.name
                            ?? fallback
                        let city = addressRepresentations?.cityName
                            ?? addressRepresentations?.cityWithContext
                            ?? fallback
                        let resolved = (fullAddress: fullAddress, city: city)
                        completion(.success(resolved))
                    }
                } catch {
                    await MainActor.run {
                        completion(.failure(.geocodingFailed(reason: error.localizedDescription)))
                    }
                }
            } else {
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    if let error {
                        completion(.failure(.geocodingFailed(reason: error.localizedDescription)))
                        return
                    }

                    let resolved = self.resolveAddress(from: placemarks?.first, fallback: fallback)
                    completion(.success(resolved))
                }
            }
        }
    }

    private func resolveAddress(
        from placemark: CLPlacemark?,
        fallback: String
    ) -> (fullAddress: String, city: String) {
        guard let placemark else {
            return (fallback, fallback)
        }

        let city = placemark.locality
            ?? placemark.subLocality
            ?? placemark.administrativeArea
            ?? fallback

        var addressComponents: [String] = []

        if let street = placemark.thoroughfare {
            var streetPart = street
            if let number = placemark.subThoroughfare {
                streetPart += " \(number)"
            }
            addressComponents.append(streetPart)
        }

        if let locality = placemark.locality {
            addressComponents.append(locality)
        } else if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }

        if addressComponents.isEmpty {
            if let name = placemark.name, !name.isEmpty {
                addressComponents.append(name)
            } else if let postalCode = placemark.postalCode {
                addressComponents.append("PLZ \(postalCode)")
            }
        }

        let fullAddress = addressComponents.isEmpty
            ? fallback
            : addressComponents.joined(separator: ", ")

        return (fullAddress, city)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }

        for newLocation in locations {
            currentLocation = newLocation

            if newLocation.speed >= 0 {
                currentSpeed = newLocation.speed * 3.6
            }

            if distanceStartLocation != nil,
               isUsableForDistance(newLocation) {
                if let last = lastAcceptedLocation {
                    let dt = newLocation.timestamp.timeIntervalSince(last.timestamp)
                    if dt > 0 {
                        let segmentDistance = newLocation.distance(from: last)
                        let segmentSpeedMS = segmentDistance / dt

                        // Filter GPS spikes/jumps before accumulating distance
                        if segmentDistance >= 0.5 && segmentSpeedMS <= 70 {
                            cumulativeDistanceMeters += segmentDistance
                            distanceSinceStartKm = cumulativeDistanceMeters / 1000.0
                        }
                    }
                }

                lastAcceptedLocation = newLocation
            }

            onLocationUpdate?(newLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        authorizationError = .locationUnavailable
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            authorizationError = nil
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            isAuthorized = false
            authorizationError = .locationPermissionDenied
        case .notDetermined:
            isAuthorized = false
            authorizationError = nil
        @unknown default:
            isAuthorized = false
        }
    }
}
