//
//  DriveEntity+CoreDataProperties.swift
//  DriveWise
//
//  Created by Core Data Migration
//

import Foundation
import CoreData
import CoreLocation

extension DriveEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DriveEntity> {
        return NSFetchRequest<DriveEntity>(entityName: "DriveEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var from: String
    @NSManaged public var to: String
    @NSManaged public var fromCity: String?
    @NSManaged public var toCity: String?
    @NSManaged public var distanceKm: Double
    @NSManaged public var avgSpeedKmh: Double
    @NSManaged public var maxSpeedKmh: Double
    @NSManaged public var maxAccelMS2: Double
    @NSManaged public var maxBrakeMS2: Double
    @NSManaged public var maxLateralAccelMS2: Double
    @NSManaged public var hardBrakeCount: Int32
    @NSManaged public var hardAccelCount: Int32
    @NSManaged public var sharpTurnCount: Int32
    @NSManaged public var veryHardBrakeCount: Int32
    @NSManaged public var veryHardAccelCount: Int32
    @NSManaged public var verySharpTurnCount: Int32
    @NSManaged public var speedingKm: Double
    @NSManaged public var errorCount: Int32
    @NSManaged public var startLatitude: Double
    @NSManaged public var startLongitude: Double
    @NSManaged public var endLatitude: Double
    @NSManaged public var endLongitude: Double
    @NSManaged public var score: Int16
    @NSManaged public var errorEvents: NSSet?

    // ---|--- Berechnete Eigenschaften (Zentrale Logik) ---|---
    
    public var totalBrakeEvents: Int { Int(hardBrakeCount + veryHardBrakeCount) }
    public var totalAccelEvents: Int { Int(hardAccelCount + veryHardAccelCount) }
    public var totalTurnEvents: Int { Int(sharpTurnCount + verySharpTurnCount) }
    public var totalSevereEvents: Int { Int(veryHardBrakeCount + veryHardAccelCount + verySharpTurnCount) }
    
    public var isPerfectDrive: Bool { errorCount == 0 }
    
    public var duration: TimeInterval { endDate.timeIntervalSince(startDate) }

}

// MARK: Generated accessors for errorEvents
extension DriveEntity {

    @objc(addErrorEventsObject:)
    @NSManaged public func addToErrorEvents(_ value: ErrorEventEntity)

    @objc(removeErrorEventsObject:)
    @NSManaged public func removeFromErrorEvents(_ value: ErrorEventEntity)

    @objc(addErrorEvents:)
    @NSManaged public func addToErrorEvents(_ values: NSSet)

    @objc(removeErrorEvents:)
    @NSManaged public func removeFromErrorEvents(_ values: NSSet)

}

// MARK: - Convenience Methods

extension DriveEntity {
    private func mappedErrorEvents() -> [DriveErrorEvent] {
        guard let eventsSet = errorEvents as? Set<ErrorEventEntity> else { return [] }

        return eventsSet
            .map {
                DriveErrorEvent(
                    id: $0.id ?? UUID(),
                    timestamp: $0.timestamp ?? self.endDate,
                    type: DriveErrorEventType(rawValue: $0.type) ?? .brake,
                    severity: DriveErrorEventSeverity.from(numericValue: $0.severity),
                    latitude: $0.latitude == 0 ? nil : $0.latitude,
                    longitude: $0.longitude == 0 ? nil : $0.longitude,
                    speedKmh: $0.speedKmh,
                    accelerationG: $0.accelerationG
                )
            }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private static func createErrorEventEntities(from events: [DriveErrorEvent], for driveEntity: DriveEntity, context: NSManagedObjectContext) {
        for event in events {
            let eventEntity = ErrorEventEntity(context: context)
            eventEntity.id = event.id
            eventEntity.timestamp = event.timestamp
            eventEntity.type = event.type.rawValue
            eventEntity.severity = event.severity.numericValue
            eventEntity.latitude = event.latitude ?? 0
            eventEntity.longitude = event.longitude ?? 0
            eventEntity.speedKmh = event.speedKmh
            eventEntity.accelerationG = event.accelerationG
            eventEntity.drive = driveEntity
            driveEntity.addToErrorEvents(eventEntity)
        }
    }

    /// Konvertiert DriveEntity zu Drive Struct für UI
    func toDrive() -> Drive {
        let events = mappedErrorEvents()
        let derivedMaxLateralMS2 = events
            .filter { $0.type == .turn }
            .map { $0.accelerationG * 9.81 }
            .max() ?? 0

        return Drive(
            id: self.id ?? UUID(),
            startDate: self.startDate,
            endDate: self.endDate,
            from: self.from,
            to: self.to,
            fromCity: self.fromCity,
            toCity: self.toCity,
            distanceKm: self.distanceKm,
            avgSpeedKmh: self.avgSpeedKmh,
            maxSpeedKmh: self.maxSpeedKmh,
            maxAccelMS2: self.maxAccelMS2,
            maxBrakeMS2: self.maxBrakeMS2,
            maxLateralAccelMS2: max(self.maxLateralAccelMS2, derivedMaxLateralMS2),
            hardBrakeCount: Int(self.hardBrakeCount),
            hardAccelCount: Int(self.hardAccelCount),
            sharpTurnCount: Int(self.sharpTurnCount),
            veryHardBrakeCount: Int(self.veryHardBrakeCount),
            veryHardAccelCount: Int(self.veryHardAccelCount),
            verySharpTurnCount: Int(self.verySharpTurnCount),
            speedingKm: self.speedingKm,
            errorCount: Int(self.errorCount),
            score: Int(self.score),
            startLatitude: self.startLatitude == 0 ? nil : self.startLatitude,
            startLongitude: self.startLongitude == 0 ? nil : self.startLongitude,
            endLatitude: self.endLatitude == 0 ? nil : self.endLatitude,
            endLongitude: self.endLongitude == 0 ? nil : self.endLongitude,
            errorEvents: events
        )
    }
    
    /// Erstellt DriveEntity aus Drive Struct
    @discardableResult
    static func fromDrive(_ drive: Drive, context: NSManagedObjectContext) -> DriveEntity {
        let entity = DriveEntity(context: context)
        entity.id = drive.id
        entity.startDate = drive.startDate
        entity.endDate = drive.endDate
        entity.from = drive.from
        entity.to = drive.to
        entity.fromCity = drive.fromCity
        entity.toCity = drive.toCity
        entity.distanceKm = drive.distanceKm
        entity.avgSpeedKmh = drive.avgSpeedKmh
        entity.maxSpeedKmh = drive.maxSpeedKmh
        entity.maxAccelMS2 = drive.maxAccelMS2
        entity.maxBrakeMS2 = drive.maxBrakeMS2
        entity.maxLateralAccelMS2 = drive.maxLateralAccelMS2
        entity.hardBrakeCount = Int32(drive.hardBrakeCount)
        entity.hardAccelCount = Int32(drive.hardAccelCount)
        entity.sharpTurnCount = Int32(drive.sharpTurnCount)
        entity.veryHardBrakeCount = Int32(drive.veryHardBrakeCount)
        entity.veryHardAccelCount = Int32(drive.veryHardAccelCount)
        entity.verySharpTurnCount = Int32(drive.verySharpTurnCount)
        entity.speedingKm = drive.speedingKm
        entity.errorCount = Int32(drive.errorCount)
        entity.startLatitude = drive.startLatitude ?? 0
        entity.startLongitude = drive.startLongitude ?? 0
        entity.endLatitude = drive.endLatitude ?? 0
        entity.endLongitude = drive.endLongitude ?? 0
        entity.score = Int16(drive.score)
        createErrorEventEntities(from: drive.errorEvents, for: entity, context: context)
        return entity
    }
}

extension DriveEntity : Identifiable {

}
