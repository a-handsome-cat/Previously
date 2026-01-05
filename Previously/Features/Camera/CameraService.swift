import AVFoundation

class CameraService {
    private let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "ahc.previously.cameraQueue")
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setup() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        
        configureSession()
    }
    
    func configureSession() {
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            
        }
        
        session.commitConfiguration()
    }
    
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}
