//
//  Persistence.swift
//  DriveWise
//
//  Created by Max Joch on 05.11.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    private static var userScopedControllers: [String: PersistenceController] = [:]

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
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
        }
        return result
    }()

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
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
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
    }
}
