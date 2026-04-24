//
//  DriveEntity+CoreDataClass.swift
//  DriveWise
//
//  Created by Core Data Migration
//

import Foundation
import CoreData
import CoreLocation

@objc(DriveEntity)
public class DriveEntity: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}
