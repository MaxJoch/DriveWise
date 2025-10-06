//
//  ProfilView.swift
//  DriveWise
//
//  Created by Heid, Joscha on 06.10.25.
//

import SwiftUI

struct ProfilView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Statisches Profilbild
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .foregroundColor(.green) // Farbe angepasst für einen Platzhalter-Look
                        .shadow(radius: 5)

                    // Name
                    Text("Max Mustermann")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    // Wohnort
                    HStack {
                        Image(systemName: "house.fill").foregroundColor(.green)
                        Text("Berlin, Deutschland").foregroundColor(.gray)
                    }
                    
                    // E-Mail
                    HStack {
                        Image(systemName: "envelope.fill").foregroundColor(.green)
                        Text("max.mustermann@email.com").foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
