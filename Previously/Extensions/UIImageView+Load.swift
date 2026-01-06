import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(urlString: String) {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            
            imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
        
        task.resume()
    }
}
