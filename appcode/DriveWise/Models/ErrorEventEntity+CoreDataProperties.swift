//
//  ErrorEventEntity+CoreDataProperties.swift
//  DriveWise
//
//  Created by Core Data Migration
//

import Foundation
import CoreData

extension ErrorEventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErrorEventEntity> {
        return NSFetchRequest<ErrorEventEntity>(entityName: "ErrorEventEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var type: String
    @NSManaged public var severity: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var speedKmh: Double
    @NSManaged public var accelerationG: Double
    @NSManaged public var drive: DriveEntity?

}

extension ErrorEventEntity : Identifiable {

}
