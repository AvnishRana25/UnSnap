import Foundation

class FavoritesManager: ObservableObject {
    @Published var favoriteImages: [UnsplashImage] = []
    private let favoritesKey = "FavoriteImages"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            do {
                let decoder = JSONDecoder()
                favoriteImages = try decoder.decode([UnsplashImage].self, from: data)
                print("Successfully loaded \(favoriteImages.count) favorites")
                // Debug print URLs
                favoriteImages.forEach { image in
                    print("Loaded image ID: \(image.id)")
                    print("Small URL: \(image.urls.small)")
                    print("Thumb URL: \(image.urls.thumb)")
                }
            } catch {
                print("Error decoding favorites: \(error)")
                favoriteImages = []
            }
        }
    }
    
    func saveFavorites() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favoriteImages)
            UserDefaults.standard.set(data, forKey: favoritesKey)
            print("Successfully saved \(favoriteImages.count) favorites")
        } catch {
            print("Error saving favorites: \(error)")
        }
    }
    
    func toggleFavorite(_ image: UnsplashImage) {
        if let index = favoriteImages.firstIndex(where: { $0.id == image.id }) {
            favoriteImages.remove(at: index)
        } else {
            var updatedImage = image
            updatedImage.isFavorite = true
            favoriteImages.append(updatedImage)
        }
        saveFavorites()
    }
    
    func isFavorite(_ image: UnsplashImage) -> Bool {
        favoriteImages.contains(where: { $0.id == image.id })
    }
} 