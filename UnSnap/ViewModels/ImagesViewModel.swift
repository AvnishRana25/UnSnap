import Foundation

@MainActor
class ImagesViewModel: ObservableObject {
    @Published var images: [UnsplashImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var retryCount = 0
    
    private let service = UnsplashService()
    private let maxRetries = 3
    
    func fetchImages() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedImages = try await service.fetchImages()
                self.images = fetchedImages
                self.retryCount = 0 // Reset retry count on success
            } catch let error as NetworkError {
                if error == .networkError && retryCount < maxRetries {
                    retryCount += 1
                    await retryFetch()
                } else {
                    self.errorMessage = error.localizedDescription
                }
            } catch {
                self.errorMessage = "An unexpected error occurred. Please try again."
            }
            self.isLoading = false
        }
    }
    
    private func retryFetch() async {
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000)) // Wait 1 second before retry
        await MainActor.run {
            fetchImages()
        }
    }
    
    func searchImages(query: String) {
        guard !query.isEmpty else {
            errorMessage = "Please enter a search term"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let searchResults = try await service.searchImages(query: query)
                self.images = searchResults
            } catch let error as NetworkError {
                self.errorMessage = error.localizedDescription
            } catch {
                self.errorMessage = "An unexpected error occurred. Please try again."
            }
            self.isLoading = false
        }
    }
} 