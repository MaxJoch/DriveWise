//
//  ContentView.swift
//  DriveWise
//
//  Created by Max Joch on 05.11.25.


import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var driveManager: DriveManager
    @Environment(\.managedObjectContext) private var viewContext

    private static func makeTabBarLogo(from source: UIImage, size: CGFloat = 50) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        let rendered = renderer.image { _ in
            source.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        }
        return rendered.withRenderingMode(.alwaysOriginal)
    }

    private let startTabLogo: UIImage? = {
        if let dataAsset = NSDataAsset(name: "DriveWiseLogoData"),
           let image = UIImage(data: dataAsset.data) {
            return ContentView.makeTabBarLogo(from: image)
        }

        return nil
    }()
    // selection to open Startseite on launch even if it's not first tab
    enum Tab: Hashable {
        case achievements, statistics, startseite, fahrten, profil
    }

    @State private var selection: Tab = .startseite

    init(userIdentifier: String? = SessionUserContext.activeUserIdentifier) {
        _driveManager = StateObject(wrappedValue: DriveManager(userIdentifier: userIdentifier))
    }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                AchievementsView()
            }
            .tabItem {
                Label("Erfolge", systemImage: "rosette")
            }
            .tag(Tab.achievements)

            NavigationStack {
                StatisticsView(context: viewContext)
            }
            .tabItem {
                Label("Statistiken", systemImage: "chart.bar")
            }
            .tag(Tab.statistics)

            NavigationStack {
                StartseiteView()
            }
            .tabItem {
                if let startTabLogo {
                    Image(uiImage: startTabLogo)
                } else {
                    Label("Startseite", systemImage: "car.fill")
                }
            }
            .tag(Tab.startseite)
            

            NavigationStack {
                FahrtenListView()
            }
            .tabItem {
                Label("Fahrten", systemImage: "list.bullet")
            }
            .tag(Tab.fahrten)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle")
            }
            .tag(Tab.profil)
        }
        .environmentObject(driveManager)
        .onAppear {
            // ensure Startseite is selected at app launch
            selection = .startseite
        }
    }
}

#Preview {
    ContentView()
}

