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
        
        cameraViewController.onPhotoTaken = { [weak self] image in
            self?.showCollageScreen(image: image)
        }
        
        navigationController.pushViewController(cameraViewController, animated: true)
    }
    
    func showCollageScreen(image: UIImage) {
        let collageViewController = CollageViewController()
        collageViewController.image = image
        collageViewController.onDismissButtonPressed = {
            self.navigationController.popToRootViewController(animated: true)
        }
        navigationController.pushViewController(collageViewController, animated: true)
    }
}
