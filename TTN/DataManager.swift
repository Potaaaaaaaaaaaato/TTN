import SwiftUI
import Combine

struct DataModel: Identifiable {
    var id = UUID()  // Ajout de l'identifiant unique
    var time: Date
    var temperature: Double
    var co2: Double
}

class DataManager: ObservableObject {
    @Published var temperature: Double = 0.0
    @Published var co2: Double = 0.0
    @Published var previousData: [DataModel] = []
    
    var temperatureColor: Color {
        switch temperature {
        case ..<15: return .blue
        case 15..<25: return .green
        case 25..<35: return .orange
        default: return .red
        }
    }
    
    var co2Color: Color {
        switch co2 {
        case ..<600: return .green
        case 600..<1000: return .yellow
        default: return .red
        }
    }
    
    var temperatureScale: CGFloat {
        return temperature > 30 ? 1.2 : 1.0
    }
    
    var co2Scale: CGFloat {
        return co2 > 1000 ? 1.2 : 1.0
    }
    
    func fetchData() {
        // Remplacer cette partie par les vraies données de The Things Network
        let newTemperature = Double.random(in: 10...40)
        let newCO2 = Double.random(in: 300...1200)
        
        // Mise à jour des données actuelles
        temperature = newTemperature
        co2 = newCO2
        
        // Stockage des données précédentes
        let newData = DataModel(time: Date(), temperature: newTemperature, co2: newCO2)
        previousData.append(newData)
        
        // Envoi d'une notification si des valeurs critiques sont dépassées
        if newTemperature > 35 {
            sendNotification(title: "Température élevée", message: "La température a dépassé 35°C !")
        }
        
        if newCO2 > 1000 {
            sendNotification(title: "CO2 élevé", message: "Le niveau de CO2 a dépassé 1000 ppm !")
        }
    }
    
    func sendNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
