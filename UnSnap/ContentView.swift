//
//  ContentView.swift
//  UnSnap
//
//  Created by Avnish Rana on 28/01/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImagesViewModel()
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var selectedImage: UnsplashImage?
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HeaderView(
                        title: "UnSnap",
                        showRefreshButton: selectedTab == 0,
                        isLoading: viewModel.isLoading,
                        onRefresh: { viewModel.fetchImages() }
                    )
                    
                    mainContent
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.isLoading)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.errorMessage)
                }
                .navigationBarHidden(true)
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .sheet(item: $selectedImage) { image in
            ImageDetailView(image: image)
                .environmentObject(favoritesManager)
        }
        .environmentObject(favoritesManager)
        .onAppear {
            if selectedTab == 0 {
                viewModel.fetchImages()
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            switch selectedTab {
            case 0:
                homeView
            case 1:
                SearchView()
            case 2:
                FavoritesView()
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var homeView: some View {
        ZStack {
            if viewModel.isLoading && viewModel.images.isEmpty {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button(action: { viewModel.fetchImages() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Retry")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.blue)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding()
            } else {
                ImageCarousel(images: viewModel.images, selectedImage: $selectedImage)
            }
        }
    }
}

#Preview {
    ContentView()
}
