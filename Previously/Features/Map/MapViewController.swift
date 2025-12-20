import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    var viewModel = MapViewModel()
    
    var onPointSelect: ((HistoricPoint) -> Void)?
    
    private let pinIdentifier = "HistoricPin"
    
    var hasSetInitialLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        setConstraints()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: pinIdentifier)
        
        bindViewModel()
        
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        checkLocationPermissions()
    }
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            let annotatinons = self?.viewModel.places.compactMap { PhotoAnnotation($0) }
            self?.mapView.addAnnotations(annotatinons ?? [])
        }
    }
    
    private func checkLocationPermissions() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            //TODO: Alert
            print("No authorization")
        @unknown default:
            break
        }
    }
    
    private func setConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if !hasSetInitialLocation {
            let region = MKCoordinateRegion.init(center: location.coordinate,latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            hasSetInitialLocation = true
            
            viewModel.addMockPoints(coordinate: location.coordinate)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        guard let _ = annotation as? PhotoAnnotation else { return nil }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier, for: annotation) as? MKMarkerAnnotationView
        
        view?.markerTintColor = .systemIndigo
        view?.glyphImage = UIImage(systemName: "camera.fill")
        view?.canShowCallout = true
        
        let button = UIButton(type: .detailDisclosure)
        view?.rightCalloutAccessoryView = button
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? PhotoAnnotation else { return }
        
        onPointSelect?(annotation.historicPoint)
    }
}
