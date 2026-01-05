import UIKit

class CameraViewController: UIViewController {
    private let cameraService = CameraService()
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
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .capsule
        
        let button = UIButton(configuration: configuration)
        button.backgroundColor = .white
        button.tintColor = .black
        button.alpha = 0.5
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraService.setup()
        
        if let previewLayer = cameraService.previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        if let point = historicPoint {
            imageView.image = UIImage(named: point.fileName)
            pointLabel.text = "\(point.title), \(point.year)"
        }
        
        opacitySlider.addTarget(self, action: #selector(didChangeSliderValue), for: .valueChanged)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(opacitySlider)
        view.addSubview(dismissButton)
        view.addSubview(pointLabel)
        
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
        cameraService.previewLayer?.frame = view.bounds
    }
    
    private func setConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        opacitySlider.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            opacitySlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
}
