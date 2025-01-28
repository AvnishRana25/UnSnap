import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = ImagesViewModel()
    @State private var searchText = ""
    @State private var selectedImage: UnsplashImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            Text("Discover")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            
            // Modern Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
                
                TextField("Search amazing photos...", text: $searchText)
                    .font(.system(size: 17))
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.searchImages(query: searchText)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            
            // Content Area
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Spacer()
            } else if viewModel.images.isEmpty && !searchText.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No results found")
                        .font(.title3.bold())
                    Text("Try searching with different keywords")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                Spacer()
            } else {
                ImageCarousel(images: viewModel.images, selectedImage: $selectedImage)
                    .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedImage) { image in
            ImageDetailView(image: image)
        }
    }
} 