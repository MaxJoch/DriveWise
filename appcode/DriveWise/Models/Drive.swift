import Foundation
import CoreLocation

struct Drive: Identifiable, Codable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let from: String
    let to: String
    let fromCity: String?
    let toCity: String?
    let distanceKm: Double
    let avgSpeedKmh: Double
    let maxSpeedKmh: Double
    let maxAccelMS2: Double
    let maxBrakeMS2: Double
    let maxLateralAccelMS2: Double
    
    // Normal severity events
    let hardBrakeCount: Int
    let hardAccelCount: Int
    let sharpTurnCount: Int
    
    // Very hard severity events
    let veryHardBrakeCount: Int
    let veryHardAccelCount: Int
    let verySharpTurnCount: Int
    
    // Speeding
    let speedingKm: Double
    
    let errorCount: Int
    let score: Int
    let startLatitude: Double?
    let startLongitude: Double?
    let endLatitude: Double?
    let endLongitude: Double?
    let errorEvents: [DriveErrorEvent]

    init(
        id: UUID,
        startDate: Date,
        endDate: Date,
        from: String,
        to: String,
        fromCity: String? = nil,
        toCity: String? = nil,
        distanceKm: Double,
        avgSpeedKmh: Double,
        maxSpeedKmh: Double,
        maxAccelMS2: Double = 0,
        maxBrakeMS2: Double = 0,
        maxLateralAccelMS2: Double = 0,
        hardBrakeCount: Int = 0,
        hardAccelCount: Int = 0,
        sharpTurnCount: Int = 0,
        veryHardBrakeCount: Int = 0,
        veryHardAccelCount: Int = 0,
        verySharpTurnCount: Int = 0,
        speedingKm: Double = 0,
        errorCount: Int = 0,
        score: Int = 100,
        startLatitude: Double? = nil,
        startLongitude: Double? = nil,
        endLatitude: Double? = nil,
        endLongitude: Double? = nil,
        errorEvents: [DriveErrorEvent] = []
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.from = from
        self.to = to
        self.fromCity = fromCity
        self.toCity = toCity
        self.distanceKm = distanceKm
        self.avgSpeedKmh = avgSpeedKmh
        self.maxSpeedKmh = maxSpeedKmh
        self.maxAccelMS2 = maxAccelMS2
        self.maxBrakeMS2 = maxBrakeMS2
        self.maxLateralAccelMS2 = maxLateralAccelMS2
        self.hardBrakeCount = hardBrakeCount
        self.hardAccelCount = hardAccelCount
        self.sharpTurnCount = sharpTurnCount
        self.veryHardBrakeCount = veryHardBrakeCount
        self.veryHardAccelCount = veryHardAccelCount
        self.verySharpTurnCount = verySharpTurnCount
        self.speedingKm = speedingKm
        self.errorCount = errorCount
        self.score = score
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.errorEvents = errorEvents
    }

    // ---|--- Berechnete Eigenschaften (Reduziert Redundanz in ViewModels) ---|---
    
    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }
    
    var totalBrakeEvents: Int { hardBrakeCount + veryHardBrakeCount }
    var totalAccelEvents: Int { hardAccelCount + veryHardAccelCount }
    var totalTurnEvents: Int { sharpTurnCount + verySharpTurnCount }
    var totalSevereEvents: Int { veryHardBrakeCount + veryHardAccelCount + verySharpTurnCount }
    
    var isPerfectDrive: Bool { errorCount == 0 }
    
    var startCoordinate: CLLocationCoordinate2D? {
        guard let lat = startLatitude, let lon = startLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var endCoordinate: CLLocationCoordinate2D? {
        guard let lat = endLatitude, let lon = endLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // ---|--- Firebase / Dictionary Serialization ---|---
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "startDate": startDate,
            "endDate": endDate,
            "from": from,
            "to": to,
            "fromCity": fromCity as Any,
            "toCity": toCity as Any,
            "distanceKm": distanceKm,
            "avgSpeedKmh": avgSpeedKmh,
            "maxSpeedKmh": maxSpeedKmh,
            "maxAccelMS2": maxAccelMS2,
            "maxBrakeMS2": maxBrakeMS2,
            "maxLateralAccelMS2": maxLateralAccelMS2,
            "hardBrakeCount": hardBrakeCount,
            "hardAccelCount": hardAccelCount,
            "sharpTurnCount": sharpTurnCount,
            "veryHardBrakeCount": veryHardBrakeCount,
            "veryHardAccelCount": veryHardAccelCount,
            "verySharpTurnCount": verySharpTurnCount,
            "speedingKm": speedingKm,
            "errorCount": errorCount,
            "score": score,
            "startLatitude": startLatitude as Any,
            "startLongitude": startLongitude as Any,
            "endLatitude": endLatitude as Any,
            "endLongitude": endLongitude as Any,
            "errorEvents": errorEvents.map { event in
                [
                    "id": event.id.uuidString,
                    "timestamp": event.timestamp,
                    "type": event.type.rawValue,
                    "severity": event.severity.rawValue,
                    "latitude": event.latitude as Any,
                    "longitude": event.longitude as Any,
                    "speedKmh": event.speedKmh,
                    "accelerationG": event.accelerationG
                ]
            }
        ]
    }

    init?(dictionary: [String: Any]) {
        guard let idString = dictionary["id"] as? String,
              let id = UUID(uuidString: idString),
              let startDate = dictionary["startDate"] as? Date,
              let endDate = dictionary["endDate"] as? Date,
              let from = dictionary["from"] as? String,
              let to = dictionary["to"] as? String else {
            return nil
        }

        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.from = from
        self.to = to
        self.fromCity = dictionary["fromCity"] as? String
        self.toCity = dictionary["toCity"] as? String
        self.distanceKm = (dictionary["distanceKm"] as? Double) ?? 0
        self.avgSpeedKmh = (dictionary["avgSpeedKmh"] as? Double) ?? 0
        self.maxSpeedKmh = (dictionary["maxSpeedKmh"] as? Double) ?? 0
        self.maxAccelMS2 = (dictionary["maxAccelMS2"] as? Double) ?? 0
        self.maxBrakeMS2 = (dictionary["maxBrakeMS2"] as? Double) ?? 0
        self.maxLateralAccelMS2 = (dictionary["maxLateralAccelMS2"] as? Double) ?? 0
        self.hardBrakeCount = (dictionary["hardBrakeCount"] as? Int) ?? 0
        self.hardAccelCount = (dictionary["hardAccelCount"] as? Int) ?? 0
        self.sharpTurnCount = (dictionary["sharpTurnCount"] as? Int) ?? 0
        self.veryHardBrakeCount = (dictionary["veryHardBrakeCount"] as? Int) ?? 0
        self.veryHardAccelCount = (dictionary["veryHardAccelCount"] as? Int) ?? 0
        self.verySharpTurnCount = (dictionary["verySharpTurnCount"] as? Int) ?? 0
        self.speedingKm = (dictionary["speedingKm"] as? Double) ?? 0
        self.errorCount = (dictionary["errorCount"] as? Int) ?? 0
        self.score = (dictionary["score"] as? Int) ?? 100
        self.startLatitude = dictionary["startLatitude"] as? Double
        self.startLongitude = dictionary["startLongitude"] as? Double
        self.endLatitude = dictionary["endLatitude"] as? Double
        self.endLongitude = dictionary["endLongitude"] as? Double

        let eventsData = dictionary["errorEvents"] as? [[String: Any]] ?? []
        self.errorEvents = eventsData.compactMap { item in
            guard let eventIDString = item["id"] as? String,
                  let eventID = UUID(uuidString: eventIDString),
                  let timestamp = item["timestamp"] as? Date,
                  let typeRaw = item["type"] as? String,
                  let type = DriveErrorEventType(rawValue: typeRaw),
                  let severityRaw = item["severity"] as? String,
                  let severity = DriveErrorEventSeverity(rawValue: severityRaw) else {
                return nil
            }
            return DriveErrorEvent(
                id: eventID,
                timestamp: timestamp,
                type: type,
                severity: severity,
                latitude: item["latitude"] as? Double,
                longitude: item["longitude"] as? Double,
                speedKmh: (item["speedKmh"] as? Double) ?? 0,
                accelerationG: (item["accelerationG"] as? Double) ?? 0
            )
        }
    }
}
