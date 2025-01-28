import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError
    case unauthorized
    case forbidden
    case rateLimitExceeded
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .invalidResponse:
            return "Server error. Please try again later."
        case .invalidData:
            return "No images found. Please try again."
        case .decodingError:
            return "Error processing data. Please try again."
        case .unauthorized:
            return "Unauthorized access. Please check your API key."
        case .forbidden:
            return "Access forbidden. Please check your permissions."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .networkError:
            return "Network error. Please check your internet connection and try again."
        }
    }
}

class UnsplashService {
    // Your access key should be the one you got from Unsplash API
    private let accessKey = "NX0N3gch2GTAs3FGkS4CHIBc3Vvcrk5TKG_Q4vn0Sj4"
    private let baseURL = "https://api.unsplash.com"
    
    func fetchImages() async throws -> [UnsplashImage] {
        guard let url = URL(string: "\(baseURL)/photos/random?count=30") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60 // Increased timeout
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)") // Debug print
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let images = try JSONDecoder().decode([UnsplashImage].self, from: data)
                    if images.isEmpty {
                        throw NetworkError.invalidData
                    }
                    return images
                } catch {
                    print("Decoding error: \(error.localizedDescription)") // Debug print
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)") // Debug print
                    }
                    throw NetworkError.decodingError
                }
            case 401:
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 429:
                throw NetworkError.rateLimitExceeded
            default:
                throw NetworkError.invalidResponse
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            print("Network error: \(error.localizedDescription)") // Debug print
            throw NetworkError.networkError
        }
    }

    func searchImages(query: String) async throws -> [UnsplashImage] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/search/photos?query=\(encodedQuery)&per_page=30") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                    if searchResponse.results.isEmpty {
                        throw NetworkError.invalidData
                    }
                    return searchResponse.results
                } catch {
                    print("Decoding error: \(error)")
                    throw NetworkError.decodingError
                }
            case 401:
                throw NetworkError.invalidResponse
            case 403:
                throw NetworkError.invalidResponse
            case 429:
                throw NetworkError.invalidResponse
            default:
                throw NetworkError.invalidResponse
            }
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }
}

struct SearchResponse: Codable {
    let results: [UnsplashImage]
} 
