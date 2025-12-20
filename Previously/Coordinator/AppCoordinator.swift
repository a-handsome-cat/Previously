import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let mapViewController = MapViewController()
        
        mapViewController.onPointSelect = { [weak self] point in
            self?.showCameraFlow(for: point)
        }
        
        navigationController.pushViewController(mapViewController, animated: false)
    }
    
    func showCameraFlow(for point: HistoricPoint) {
        let cameraViewController = CameraViewController()
        cameraViewController.historicPoint = point
        navigationController.pushViewController(cameraViewController, animated: true)
    }
}
