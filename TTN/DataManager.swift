import SwiftUI
import Combine

class DataManager: ObservableObject {
    @Published var temperature: Double = 0.0
    @Published var humidity: Double = 0.0
    @Published var previousData: [(temperature: Double, humidity: Double)] = []
    
    private var cancellable: AnyCancellable?
    
    func fetchData() {
        let urlString = "https://<tenant>.cloud.thethings.network/api/v3/as/applications/<app_id>/devices/<device_id>/packages/storage/uplink_message"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer <API_KEY>", forHTTPHeaderField: "Authorization")
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: TTNResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching data: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // Stocker les anciennes données
                self.previousData.append((temperature: self.temperature, humidity: self.humidity))
                
                // Mettre à jour les nouvelles valeurs
                self.temperature = response.uplinkMessage.decodedPayload.temperature
                self.humidity = response.uplinkMessage.decodedPayload.humidity
            })
    }
}

// Struct pour correspondre à la réponse TTN
struct TTNResponse: Codable {
    let uplinkMessage: UplinkMessage
}

struct UplinkMessage: Codable {
    let decodedPayload: DecodedPayload
}

struct DecodedPayload: Codable {
    let temperature: Double
    let humidity: Double
}
