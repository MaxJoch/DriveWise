//
//  LandkarteView.swift
//  DriveWise
//
//  Created by Heid, Joscha on 06.10.25.
//

import SwiftUI

struct LandkarteView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.opacity(0.1).ignoresSafeArea()
                VStack {
                    Text("Hier kommt später die Landkarte rein.")
                        .font(.title2)
                        .padding()
                }
            }
            .navigationTitle("Landkarte")
        }
    }
}
