import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(urlString: String, onImageLoaded: (() -> Void)? = nil) {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            onImageLoaded?()
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            
            imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                self.image = image
            }
            
            onImageLoaded?()
        }
        
        task.resume()
    }
}
