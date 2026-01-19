//
//  DriveWiseApp.swift
//  DriveWise
//
//  Created by Max Joch on 05.11.25.
//

import SwiftUI
import CoreData

@main
struct DriveWiseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
