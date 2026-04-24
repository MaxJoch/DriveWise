//
//  DriveStorageService.swift
//  DriveWise
//
//  Core Data persistence service
//

import Foundation
import CoreData

class DriveStorageService {
    private let persistenceController: PersistenceController
    private var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    func loadDrives() throws -> [Drive] {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDrive() }
        } catch {
            throw DriveWiseError.loadFailed(reason: error.localizedDescription)
        }
    }
    
    func saveDrive(_ drive: Drive) throws {
        let _ = DriveEntity.fromDrive(drive, context: context)
        persistenceController.save()
    }

    func replaceAllDrives(with drives: [Drive]) throws {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        let existing = try context.fetch(fetchRequest)

        for entity in existing {
            context.delete(entity)
        }

        for drive in drives {
            let _ = DriveEntity.fromDrive(drive, context: context)
        }

        persistenceController.save()
    }
    
    func deleteDrive(_ drive: Drive) throws {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", drive.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let entities = try context.fetch(fetchRequest)
            guard let entity = entities.first else {
                throw DriveWiseError.deleteFailed(reason: "Fahrt mit ID \(drive.id) nicht gefunden")
            }
            
            context.delete(entity)
            persistenceController.save()
        } catch let error as DriveWiseError {
            throw error
        } catch {
            throw DriveWiseError.deleteFailed(reason: error.localizedDescription)
        }
    }
    
    func deleteAllDrives() throws {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        let entities = try context.fetch(fetchRequest)
        
        for entity in entities {
            context.delete(entity)
        }
        
        persistenceController.save()
    }
    
    func countDrives() throws -> Int {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        do {
            return try context.count(for: fetchRequest)
        } catch {
            throw DriveWiseError.loadFailed(reason: error.localizedDescription)
        }
    }
    
    func totalDistance() throws -> Double {
        let drives = try loadDrives()
        return drives.reduce(0) { $0 + $1.distanceKm }
    }
    
    func loadDrives(from startDate: Date, to endDate: Date) throws -> [Drive] {
        let fetchRequest: NSFetchRequest<DriveEntity> = DriveEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "startDate >= %@ AND startDate <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDrive() }
        } catch {
            throw DriveWiseError.loadFailed(reason: error.localizedDescription)
        }
    }
}
