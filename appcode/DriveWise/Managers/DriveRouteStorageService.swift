import Foundation
import CoreLocation

import Foundation
import CoreLocation

final class DriveRouteStorageService {
    private let fileManager: FileManager
    private let codec = DriveRoutePolylineCodec()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func saveRoute(_ coordinates: [CLLocationCoordinate2D], for driveId: UUID) throws {
        let encoded = codec.encode(coordinates)
        guard !encoded.isEmpty else { return }
        
        let data = Data(encoded.utf8)
        let directory = try routesDirectoryURL()
        let fileURL = directory.appendingPathComponent("\(driveId.uuidString).polyline")
        try data.write(to: fileURL, options: .atomic)
    }

    func loadRoute(for driveId: UUID) -> [CLLocationCoordinate2D] {
        do {
            let directory = try routesDirectoryURL()
            
            // Versuch polyline Datei zu laden (neu)
            let polylineURL = directory.appendingPathComponent("\(driveId.uuidString).polyline")
            if fileManager.fileExists(atPath: polylineURL.path) {
                let data = try Data(contentsOf: polylineURL)
                if let encoded = String(data: data, encoding: .utf8) {
                    return codec.decode(encoded)
                }
            }
            
            // Fallback: Alte JSON Datei laden (Migration)
            let jsonURL = directory.appendingPathComponent("\(driveId.uuidString).json")
            if fileManager.fileExists(atPath: jsonURL.path) {
                let data = try Data(contentsOf: jsonURL)
                let routePoints = try JSONDecoder().decode([RoutePoint].self, from: data)
                let coordinates = routePoints.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                }
                
                // Migriere zu polyline für die Zukunft
                try? saveRoute(coordinates, for: driveId)
                try? fileManager.removeItem(at: jsonURL)
                
                return coordinates
            }
            
            return []
        } catch {
            return []
        }
    }

    func deleteRoute(for driveId: UUID) {
        do {
            let directory = try routesDirectoryURL()
            let polylineURL = directory.appendingPathComponent("\(driveId.uuidString).polyline")
            let jsonURL = directory.appendingPathComponent("\(driveId.uuidString).json")
            
            if fileManager.fileExists(atPath: polylineURL.path) {
                try fileManager.removeItem(at: polylineURL)
            }
            if fileManager.fileExists(atPath: jsonURL.path) {
                try fileManager.removeItem(at: jsonURL)
            }
        } catch {
            // Ignore delete failures
        }
    }

    private struct RoutePoint: Codable {
        let latitude: Double
        let longitude: Double
    }

    private func routesDirectoryURL() throws -> URL {
        let baseURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = baseURL
            .appendingPathComponent("DriveWise", isDirectory: true)
            .appendingPathComponent("Routes", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}
