//
//  ErrorEventEntity+CoreDataClass.swift
//  DriveWise
//
//  Created by Core Data Migration
//

import Foundation
import CoreData

@objc(ErrorEventEntity)
public class ErrorEventEntity: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date(), forKey: "timestamp")
    }
}
