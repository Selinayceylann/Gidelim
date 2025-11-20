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
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if favoriteRestaurants.isEmpty {
                EmptyStateView(
                    icon: "heart.slash",
                    title: "Favori mekan yok",
                    subtitle: "Beğendiğin mekanları favorilerine ekle"
                )
            } else {
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
        .navigationTitle("Favorilerim")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadFavorites()
        }
        .alert("Favorilerden Kaldır", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Kaldır", role: .destructive) {
            }
        } message: {
            Text("Bu mekanı favorilerinden kaldırmak istediğine emin misin?")
        }
    }
    
    private func loadFavorites() async {
        isLoading = true
        favoriteRestaurants = await viewModel.getFavoriteRestaurants()
        isLoading = false
    }
    
    
    struct FavoriteRestaurantCard: View {
        let restaurant: Restaurant
        let onRemove: () -> Void
        
        var body: some View {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.1))
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", restaurant.rating ?? 0.0))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                            .font(.caption)
                        Text(restaurant.district ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    if let features = restaurant.features, !features.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(features.prefix(2), id: \.self) { feature in
                                    Text(feature)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 0.2, green: 0.7, blue: 0.5).opacity(0.1))
                                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(viewModel: ProfileViewModel())
    }
}
