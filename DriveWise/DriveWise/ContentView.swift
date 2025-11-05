//
//  ContentView.swift
//  DriveWise
//
//  Created by Max Joch on 05.11.25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var driveManager = DriveManager()
    // selection to open Startseite on launch even if it's not first tab
    enum Tab: Hashable {
        case achievements, statistics, startseite, fahrten, profil
    }

    @State private var selection: Tab = .startseite

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
                StatisticsView()
            }
            .tabItem {
                Label("Statistiken", systemImage: "chart.bar")
            }
            .tag(Tab.statistics)

            NavigationStack {
                StartseiteView()
            }
            .tabItem {
                // use original center_icon asset if present (no resizing)
                if UIImage(named: "center_icon") != nil {
                    VStack(spacing: 4) {
                        Image("center_icon")
                            .renderingMode(.original)
                    }
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
                Text("Profil (Platzhalter)")
                    .navigationTitle("Profil")
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

