import UIKit

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Adjust based on your needs
    }
    
    func set(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    func get(_ url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
} 