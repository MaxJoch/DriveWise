//
//  Persistence.swift
//  DriveWise
//
//  Created by Max Joch on 05.11.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
<<<<<<< HEAD
=======
    private static var userScopedControllers: [String: PersistenceController] = [:]
>>>>>>> 8b0cfe3 (DriveWise)

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
<<<<<<< HEAD
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
=======
        
        // Erstelle Sample Drives für Preview
        for i in 0..<3 {
            let drive = DriveEntity(context: viewContext)
            drive.id = UUID()
            drive.startDate = Date().addingTimeInterval(-3600 * 24 * Double(i + 1))
            drive.endDate = Date().addingTimeInterval(-3600 * 24 * Double(i + 1) + 600)
            drive.from = "Malsch"
            drive.to = "Durmersheim"
            drive.fromCity = "Malsch"
            drive.toCity = "Durmersheim"
            drive.distanceKm = 4.7
            drive.avgSpeedKmh = 35.0
            drive.maxSpeedKmh = 85.0
            drive.errorCount = Int32(i + 1)
            drive.maxAccelMS2 = 2.0 + Double(i) * 0.3
            drive.maxBrakeMS2 = 2.5 + Double(i) * 0.4
            drive.hardBrakeCount = Int32(i)
            drive.hardAccelCount = Int32(i + 1)
            drive.sharpTurnCount = Int32(max(0, i - 1))
            drive.score = Int16(95 - i * 5)
            drive.startLatitude = 48.8836
            drive.startLongitude = 8.3341
            drive.endLatitude = 48.9345
            drive.endLongitude = 8.2832
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Preview error: \(nsError), \(nsError.userInfo)")
>>>>>>> 8b0cfe3 (DriveWise)
        }
        return result
    }()

<<<<<<< HEAD
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "DriveWise")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
=======
    let container: NSPersistentContainer

    init(inMemory: Bool = false, storeSuffix: String? = nil) {
        container = NSPersistentContainer(name: "DriveWise")
        if let description = container.persistentStoreDescriptions.first {
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            } else if let storeSuffix, !storeSuffix.isEmpty {
                let fileManager = FileManager.default
                let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                    ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let storeDirectory = appSupportURL.appendingPathComponent("DriveWise", isDirectory: true)
                try? fileManager.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
                description.url = storeDirectory.appendingPathComponent("DriveWise_\(storeSuffix).sqlite")
            }
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
>>>>>>> 8b0cfe3 (DriveWise)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
<<<<<<< HEAD
=======
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    static func forUser(_ userIdentifier: String?) -> PersistenceController {
        guard let userIdentifier, !userIdentifier.isEmpty else {
            return shared
        }

        let suffix = sanitizedStoreSuffix(from: userIdentifier)
        if let controller = userScopedControllers[suffix] {
            return controller
        }

        let controller = PersistenceController(storeSuffix: suffix)
        userScopedControllers[suffix] = controller
        return controller
    }

    private static func sanitizedStoreSuffix(from raw: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let cleanedScalars = raw.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
        let cleaned = String(cleanedScalars)
        return cleaned.isEmpty ? "default" : cleaned
    }
    
    // MARK: - Helper Functions
    
    /// Speichert den Context, falls Änderungen vorhanden sind
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// Löscht alle Daten (für Testing/Reset)
    func deleteAll() {
        let context = container.viewContext
        
        // Delete all DriveEntities
        let driveFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "DriveEntity")
        let driveDelete = NSBatchDeleteRequest(fetchRequest: driveFetch)
        
        // Delete all ErrorEventEntities
        let errorFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ErrorEventEntity")
        let errorDelete = NSBatchDeleteRequest(fetchRequest: errorFetch)
        
        do {
            try context.execute(driveDelete)
            try context.execute(errorDelete)
            try context.save()
        } catch {
            print("Delete error: \(error)")
        }
>>>>>>> 8b0cfe3 (DriveWise)
    }
}
