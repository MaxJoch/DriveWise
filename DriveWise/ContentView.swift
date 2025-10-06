import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StartseiteView()
                .tabItem {
                    Label("Start", systemImage: "house")
                }

            LandkarteView()
                .tabItem {
                    Label("Landkarte", systemImage: "map")
                }

            StatistikenView()
                .tabItem {
                    Label("Statistiken", systemImage: "chart.bar")
                }
            ProfilView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
}
