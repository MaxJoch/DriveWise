//
//  StatistikenView.swift
//  DriveWise
//
//  Created by Heid, Joscha on 06.10.25.
//

import SwiftUI

struct StatistikenView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.opacity(0.1).ignoresSafeArea()
                VStack {
                    Text("Hier erscheinen die Statistiken.")
                        .font(.title2)
                        .padding()
                }
            }
            .navigationTitle("Statistiken")
        }
    }
}
