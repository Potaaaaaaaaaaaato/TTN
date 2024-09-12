import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        VStack {
            Text("Température : \(dataManager.temperature, specifier: "%.2f")°C")
                .font(.largeTitle)
            
            Text("Humidité : \(dataManager.humidity, specifier: "%.2f")%")
                .font(.title)
            
            List(dataManager.previousData, id: \.temperature) { data in
                HStack {
                    Text("Température : \(data.temperature, specifier: "%.2f")°C")
                    Spacer()
                    Text("Humidité : \(data.humidity, specifier: "%.2f")%")
                }
            }
        }
        .padding()
        .onAppear {
            // Rafraîchir toutes les 60 secondes
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                dataManager.fetchData()
            }
        }
    }
}
