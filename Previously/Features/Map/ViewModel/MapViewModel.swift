import MapKit

class MapViewModel {
    var places: [HistoricPoint] = []
    var onDataLoaded: (() -> Void)?
    
    func loadData(coordinate: CLLocationCoordinate2D) {
        Task {
            do {
                let points = try await APIService.shared.fetchNearestPoints(location: coordinate)
                
                await MainActor.run {
                    self.places = points
                    self.onDataLoaded?()
                }
            } catch {
                print("Error loading points: \(error)")
            }
        }
    }
}
