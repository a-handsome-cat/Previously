import UIKit
import AVKit

class CameraViewController: UIViewController {
    private let cameraService = CameraService()
    
    var onPhotoTaken: ((UIImage) -> Void)?
    
    private let cameraView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.alpha = 0.5
        imgView.isUserInteractionEnabled = false
        return imgView
    }()
    
    var historicPoint: HistoricPoint?
    var pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.shadowColor = .black
        return label
    }()
    
    private let opacitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        return slider
    }()
    
    private let dismissButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        
        configuration.baseBackgroundColor = .black.withAlphaComponent(0.5)
        configuration.baseForegroundColor = .white
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        configuration.image = UIImage(systemName: "xmark", withConfiguration: symbolConfig)
        
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let button = UIButton(configuration: configuration)
        
        return button
    }()
    
    private let captureButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .capsule
        
        let button = UIButton(configuration: configuration)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 6
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraService.setup()
        
        view.addSubview(cameraView)
        
        if let previewLayer = cameraService.previewLayer {
            cameraView.layer.addSublayer(previewLayer)
        }
        
        if let point = historicPoint {
            imageView.loadImage(urlString: point.fileURL) {
                self.configureCameraSize()
            }
            pointLabel.text = "\(point.title), \(point.year)"
        }
        
        opacitySlider.addTarget(self, action: #selector(didChangeSliderValue), for: .valueChanged)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(didTapCameraCaptureButton), for: .touchUpInside)
        
        view.backgroundColor = .black
        
        cameraView.addSubview(imageView)
        view.addSubview(opacitySlider)
        view.addSubview(dismissButton)
        view.addSubview(pointLabel)
        view.addSubview(captureButton)
        
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        cameraService.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        cameraService.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraService.previewLayer?.frame = cameraView.bounds
    }
    
    func configureCameraSize() {
        guard let img = self.imageView.image else { return }
        
        let aspectRatio = img.size.width / img.size.height
        
        NSLayoutConstraint.activate([
            self.cameraView.heightAnchor.constraint(equalToConstant: self.view.frame.width / aspectRatio),
            self.cameraView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.cameraView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.cameraView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    private func setConstraints() {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        opacitySlider.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cameraView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),

            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 72),
            captureButton.heightAnchor.constraint(equalToConstant: 72),
            
            opacitySlider.bottomAnchor.constraint(equalTo: captureButton.topAnchor),
            opacitySlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            opacitySlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            pointLabel.bottomAnchor.constraint(equalTo: opacitySlider.topAnchor, constant: -10),
            pointLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            pointLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
    
    @objc func didChangeSliderValue(_ sender: UISlider) {
        imageView.alpha = CGFloat(sender.value)
    }
    
    @objc func didTapDismissButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapCameraCaptureButton() {
        cameraService.capturePhoto(delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func cropImageToAspectRatio(image: UIImage, aspectRatio: CGFloat) -> UIImage {
        
        var rect: CGRect = .zero
        
        if (image.size.width / image.size.height) > aspectRatio {
            let newWidth = image.size.height * aspectRatio
            rect = CGRect(x: (image.size.width - newWidth) / 2, y: 0, width: newWidth, height: image.size.height)
        } else {
            let newHeight = image.size.width / aspectRatio
            rect = CGRect(x: 0, y: (image.size.height - newHeight) / 2, width: image.size.width, height: newHeight)
        }
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { _ in
            image.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data),
              let oldImage = imageView.image else { return }
        
        let aspectRatio = oldImage.size.width / oldImage.size.height
        
        let newImage = cropImageToAspectRatio(image: image, aspectRatio: aspectRatio)
        
        let height = oldImage.size.height
        let width = oldImage.size.width
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: oldImage.size.height * 2))
        
        let collage = renderer.image { ctx in
            oldImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage.draw(in: CGRect(x: 0, y: height, width: width, height: height))
        }
        
        DispatchQueue.main.async {
            self.onPhotoTaken?(collage)
        }
    }
}
