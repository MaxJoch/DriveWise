//
//  StartseiteView.swift
//  DriveWise
//
//  Created by Heid, Joscha on 06.10.25.
//

import SwiftUI

struct StartseiteView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer() // Fügt Leerraum oben hinzu
                    
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("DriveWise")
                        .font(.largeTitle).bold()
                        .foregroundColor(.green)
                    
                    Text("Verfolge deine Fahrten und bekomme Feedback, wie sicher du fährst. Test :)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer() // Fügt Leerraum unten hinzu
                }
            }
        }
    }
}
