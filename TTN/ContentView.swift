import SwiftUI
import Combine
import Charts
import UserNotifications

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showHistory = false
    
    var body: some View {
        TabView {
            // Page principale avec les valeurs actuelles
            VStack(spacing: 20) {

                // Logo IUT
                Image("logo_iut")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.leading, 20) // Garder l'alignement à gauche
                
                // Température avec animation et couleur dynamique
                HStack {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 40))
                        .foregroundColor(dataManager.temperatureColor)
                        .scaleEffect(dataManager.temperatureScale)
                        .animation(.easeInOut(duration: 0.5))
                    Text("\(dataManager.temperature, specifier: "%.2f")°C")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(dataManager.temperatureColor)
                }
                .padding(.leading, 20) // Garder l'alignement à gauche
                
                // CO2 avec animation et couleur dynamique
                HStack {
                    Image(systemName: "carbon.dioxide.cloud")
                        .font(.system(size: 40))
                        .foregroundColor(dataManager.co2Color)
                        .scaleEffect(dataManager.co2Scale)
                        .animation(.easeInOut(duration: 0.5))
                    Text("\(dataManager.co2, specifier: "%.2f") ppm")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(dataManager.co2Color)
                }
                .padding(.leading, 20) // Garder l'alignement à gauche
                
                // Graphique des valeurs
                Chart(dataManager.previousData) {
                    LineMark(
                        x: .value("Temps", $0.time),
                        y: .value("Température", $0.temperature)
                    )
                    .foregroundStyle(.red)
                    
                    LineMark(
                        x: .value("Temps", $0.time),
                        y: .value("CO2", $0.co2)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
                .padding(.horizontal, 20) // Espacement horizontal
            }
            .padding(.top, 10)
            .onAppear {
                // Activer les notifications locales
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("Notifications autorisées")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
                // Rafraîchir toutes les 60 secondes
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    dataManager.fetchData()
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Accueil")
            }
            
            // Page Historique
            HistoryView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "clock")
                    Text("Historique")
                }
        }
    }
}

struct HistoryView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        List(dataManager.previousData, id: \.time) { data in
            HStack {
                Image(systemName: "thermometer.medium")
                Text("Température : \(data.temperature, specifier: "%.2f")°C")
                
                Spacer()

                Image(systemName: "carbon.dioxide.cloud")
                Text("CO2 : \(data.co2, specifier: "%.2f") ppm")
            }
        }
    }
}
