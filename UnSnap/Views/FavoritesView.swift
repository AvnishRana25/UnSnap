import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @State private var selectedImage: UnsplashImage?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Favorites")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            
            if favoritesManager.favoriteImages.isEmpty {
                Spacer()
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "heart")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .symbolEffect(.bounce, options: .repeating)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 12) {
                        Text("No favorites yet")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text("Photos you like will appear here\nTap the heart icon to add favorites")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                Spacer()
            } else {
                ScrollView {
                    ImageCarousel(images: favoritesManager.favoriteImages, selectedImage: $selectedImage)
                }
                .refreshable {
                    favoritesManager.loadFavorites()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedImage) { image in
            ImageDetailView(image: image)
                .environmentObject(favoritesManager)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("There was an error loading your favorites. Try again.")
        }
    }
} 
