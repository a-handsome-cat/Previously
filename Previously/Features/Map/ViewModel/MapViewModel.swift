import MapKit

class MapViewModel {
    var places: [HistoricPoint] = []
    var onDataLoaded: (() -> Void)?
    
    func addMockPoints(coordinate: CLLocationCoordinate2D) {
        let point1 = HistoricPoint(coordinates: CLLocationCoordinate2D(latitude: coordinate.latitude + 0.002, longitude: coordinate.longitude), title: "Point One", year: 1970, fileName: "file1")
        let point2 = HistoricPoint(coordinates: CLLocationCoordinate2D(latitude: coordinate.latitude - 0.002, longitude: coordinate.longitude), title: "Point Two", year: 1980, fileName: "file2")
        let point3 = HistoricPoint(coordinates: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude  + 0.002), title: "Point Three", year: 1990, fileName: "file3")
        let point4 = HistoricPoint(coordinates: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude - 0.002), title: "Point Four", year: 2000, fileName: "file4")
        
        places.append(contentsOf: [point1, point2, point3, point4])
        
        onDataLoaded?()
    }
}
