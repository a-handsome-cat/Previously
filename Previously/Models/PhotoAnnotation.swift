import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let historicPoint: HistoricPoint
    
    var title: String? {
        historicPoint.title
    }
    
    var subtitle: String? {
        historicPoint.year.description
    }
    
    init(_ historicPoint: HistoricPoint) {
        self.coordinate = historicPoint.coordinates
        self.historicPoint = historicPoint
    }
}
