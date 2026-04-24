//
//  DriveWiseApp.swift
//  DriveWise
//
//  Created by Max Joch on 05.11.25.
//

import SwiftUI
import CoreData
import Combine
import UserNotifications
#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseAuth
import UIKit
#endif

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if canImport(FirebaseCore)
        FirebaseApp.configure()
#endif
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

@main
struct DriveWiseApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authVM = AuthenticationViewModel()

    private var persistenceController: PersistenceController {
        PersistenceController.forUser(authVM.userIdentifier)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isSignedIn {
                    ContentView(userIdentifier: authVM.userIdentifier)
                        .id(authVM.userIdentifier ?? "anonymous")
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(authVM)
                } else {
                    NavigationStack {
                        LoginView()
                            .environmentObject(authVM)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                }
            }
        }
    }
}
