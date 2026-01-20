import UIKit

class CollageViewController: UIViewController {
    var image: UIImage?
    var onDismissButtonPressed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        view.backgroundColor = .black
        
        let dismissButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapDismissButton))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapShareButton))
        
        navigationItem.rightBarButtonItems = [dismissButton, shareButton]
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc func didTapDismissButton() {
        onDismissButtonPressed?()
    }
    
    @objc func didTapShareButton() {
        guard let image = image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true)
    }
}
