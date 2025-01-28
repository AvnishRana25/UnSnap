import SwiftUI

struct ImageDetailView: View {
    let image: UnsplashImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    @State private var showMetadata = true
    @EnvironmentObject private var favoritesManager: FavoritesManager
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    // Main Image
                    AsyncImage(url: URL(string: image.urls.full)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale = min(max(scale * delta, 1), 4)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            if scale <= 1 {
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                    lastOffset = .zero
                                                }
                                            }
                                        }
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                            if scale <= 1 {
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                    lastOffset = .zero
                                                }
                                            }
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    withAnimation(.spring()) {
                                        if scale > 1 {
                                            scale = 1
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            scale = 2
                                        }
                                    }
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // Metadata overlay
                    if showMetadata {
                        VStack(alignment: .leading, spacing: 8) {
                            if let description = image.description {
                                Text(description)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("By \(image.user.name)")
                                        .font(.subheadline)
                                    Text("Posted: \(formatDate(image.createdAt))")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("\(image.likes)")
                                }
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .edgesIgnoringSafeArea(.bottom)
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        favoritesManager.toggleFavorite(image)
                    }) {
                        Image(systemName: favoritesManager.isFavorite(image) ? "heart.fill" : "heart")
                            .imageScale(.large)
                            .foregroundColor(favoritesManager.isFavorite(image) ? .red : .white)
                            .padding(8)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    
                    Button(action: {
                        withAnimation {
                            showMetadata.toggle()
                        }
                    }) {
                        Image(systemName: showMetadata ? "info.circle.fill" : "info.circle")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 