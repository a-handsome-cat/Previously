import CoreLocation

struct HistoricPoint {
    let coordinates: CLLocationCoordinate2D
    let title: String
    let year: Int
    let fileURL: String
    
    init(apiPoint: APIPhotoModel) {
        self.coordinates = CLLocationCoordinate2D(latitude: apiPoint.geo[0], longitude: apiPoint.geo[1])
        self.title = apiPoint.title
        self.year = apiPoint.year
        self.fileURL = "https://img.pastvu.com/d/" + apiPoint.file
    }
}
