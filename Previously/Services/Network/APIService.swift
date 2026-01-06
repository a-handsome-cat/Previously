import Foundation
import CoreLocation

class APIService {
    static let shared = APIService()
    
    enum APIServiceError: Error {
        case apiError
        case decodingError
    }
    
    func sendAPIRequest(method: String, params: [String:Any]) async throws -> Data {
        let paramsData = try JSONSerialization.data(withJSONObject: params, options: [])
        guard let paramsString = String(data: paramsData, encoding: .utf8) else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.pastvu.com"
        components.path = "/api2"
        components.queryItems = [
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "params", value: paramsString)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return data
    }
    
    func fetchNearestPoints(location: CLLocationCoordinate2D) async throws -> [HistoricPoint] {
        let params: [String: Any] = [
            "geo": [location.latitude, location.longitude],
            "limit": 20
        ]
        
        let data = try await sendAPIRequest(method: "photo.giveNearestPhotos", params: params)
        
        do {
            let response = try JSONDecoder().decode(APIResultResponse<APIPhotosResponse>.self, from: data)
            let photos = response.result.photos.map { HistoricPoint(apiPoint: $0) }
            return photos
        } catch {
            print(error)
            throw APIServiceError.decodingError
        }
    }
}
