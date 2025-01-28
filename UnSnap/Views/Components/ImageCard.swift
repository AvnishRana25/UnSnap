import SwiftUI

struct ImageCard: View {
    let image: UnsplashImage
    let onTap: () -> Void
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var showsShadow = false
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let uiImage = loadedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                } else if isLoading {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                        .background(Color.gray.opacity(0.1))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                        Text("Failed to load")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                    .background(Color.gray.opacity(0.1))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(showsShadow ? 0.2 : 0.1),
                   radius: showsShadow ? 15 : 10,
                   x: 0,
                   y: showsShadow ? 10 : 5)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .onAppear {
                loadImage()
                withAnimation(.easeInOut(duration: 0.3)) {
                    showsShadow = true
                }
            }
            .onDisappear {
                showsShadow = false
            }
        }
        .aspectRatio(0.7, contentMode: .fit)
    }
    
    private func loadImage() {
        let urlString = image.urls.small
        
        // Check cache first
        if let cachedImage = ImageCache.shared.get(urlString) {
            self.loadedImage = cachedImage
            self.isLoading = false
            return
        }
        
        // If not in cache, load from network
        guard let url = URL(string: urlString) else {
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let uiImage = UIImage(data: data) {
                    ImageCache.shared.set(uiImage, for: urlString)
                    self.loadedImage = uiImage
                }
                self.isLoading = false
            }
        }.resume()
    }
} 