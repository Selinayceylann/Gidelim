//
//  FavoritesView.swift
//  OneriApp
//
//  Created by selinay ceylan on 9.11.2025.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var favoriteRestaurants: [Restaurant] = []
    @State private var isLoading = true
    @State private var showDeleteAlert = false
    @State private var restaurantToDelete: Restaurant?
    
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .navigationTitle("Favorilerim")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadFavorites()
        }
        .alert("Favorilerden Kaldır", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Kaldır", role: .destructive) { }
        } message: {
            Text("Bu mekanı favorilerinden kaldırmak istediğine emin misin?")
        }
    }
}

// MARK: - Main Content
private extension FavoritesView {
    var backgroundView: some View {
        Color(red: 0.95, green: 0.95, blue: 0.97)
            .ignoresSafeArea()
    }
    
    var contentView: some View {
        Group {
            if isLoading {
                loadingView
            } else if favoriteRestaurants.isEmpty {
                emptyStateView
            } else {
                favoritesList
            }
        }
    }
    
    var loadingView: some View {
        ProgressView("Yükleniyor...")
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    var emptyStateView: some View {
        EmptyStateView(
            icon: "heart.slash",
            title: "Favori mekan yok",
            subtitle: "Beğendiğin mekanları favorilerine ekle"
        )
    }
    
    var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(favoriteRestaurants) { restaurant in
                    FavoriteRestaurantCard(
                        restaurant: restaurant,
                        onRemove: {
                            restaurantToDelete = restaurant
                            showDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Actions
private extension FavoritesView {
    func loadFavorites() async {
        isLoading = true
        favoriteRestaurants = await viewModel.getFavoriteRestaurants()
        isLoading = false
    }
}

// MARK: - Favorite Restaurant Card
struct FavoriteRestaurantCard: View {
    let restaurant: Restaurant
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            restaurantImage
            restaurantInfo
            Spacer()
            favoriteButton
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Card Components
private extension FavoriteRestaurantCard {
    var restaurantImage: some View {
        AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { phase in
            switch phase {
            case .empty:
                imageLoadingView
            case .success(let image):
                loadedImage(image)
            case .failure:
                imagePlaceholder
            @unknown default:
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var imageLoadingView: some View {
        ProgressView()
            .frame(width: 100, height: 100)
    }
    
    func loadedImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipped()
    }
    
    var imagePlaceholder: some View {
        Image(systemName: "photo")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.1))
    }
    
    var restaurantInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            restaurantName
            ratingSection
            locationSection
            featuresSection
        }
    }
    
    var restaurantName: some View {
        Text(restaurant.name ?? "")
            .font(.headline)
            .foregroundColor(.primary)
            .lineLimit(2)
    }
    
    var ratingSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            Text(String(format: "%.1f", restaurant.rating ?? 0.0))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    var locationSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                .font(.caption)
            Text(restaurant.district ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
    
    var featuresSection: some View {
        Group {
            if let features = restaurant.features, !features.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(features.prefix(2), id: \.self) { feature in
                            featureTag(feature)
                        }
                    }
                }
            }
        }
    }
    
    func featureTag(_ feature: String) -> some View {
        Text(feature)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(red: 0.2, green: 0.7, blue: 0.5).opacity(0.1))
            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
            .cornerRadius(6)
    }
    
    var favoriteButton: some View {
        Button(action: onRemove) {
            Image(systemName: "heart.fill")
                .font(.title3)
                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(viewModel: ProfileViewModel())
    }
}
