import Foundation
struct UnsplashImage: Codable, Identifiable {
    let id: String
    let description: String?
    let altDescription: String?
    let urls: ImageURLs
    let user: User
    let createdAt: String
    let likes: Int
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case altDescription = "alt_description"
        case urls
        case user
        case createdAt = "created_at"
        case likes
    }
}

struct ImageURLs: Codable {
    
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
}

struct User: Codable {
    
    let name: String
    let username: String
    
}

extension UnsplashImage: Equatable {
    
    static func == (lhs: UnsplashImage, rhs: UnsplashImage) -> Bool {
        lhs.id == rhs.id
        
    }
} 
