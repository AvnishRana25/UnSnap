import SwiftUI

struct ImageCarousel: View {
    let images: [UnsplashImage]
    @Binding var selectedImage: UnsplashImage?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(images) { image in
                    ImageCard(image: image, onTap: {
                        withAnimation(.spring()) {
                            selectedImage = image
                        }
                    })
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
    }
}

struct ImageCell: View {
    let image: UnsplashImage
    let onTap: () -> Void
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let uiImage = loadedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width * 1.2)
                        .clipped()
                } else if isLoading {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.width * 1.2)
                        .background(Color.gray.opacity(0.1))
                } else {
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Failed to load")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width * 1.2)
                    .background(Color.gray.opacity(0.1))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .onAppear {
                loadImage()
            }
        }
        .aspectRatio(0.8, contentMode: .fit)
    }
    
    private func loadImage() {
        let urlString = image.urls.small
      
        if let cachedImage = ImageCache.shared.get(urlString) {
            self.loadedImage = cachedImage
            self.isLoading = false
            return
        }
        
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

struct ImageCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ImageCarousel(images: [], selectedImage: .constant(nil))
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
} 
