//
//  RestaurantCardView.swift
//  OneriApp
//
//  Created by selinay ceylan on 14.10.2025.
//

import SwiftUI

struct RestaurantCardView: View {
    private let viewModel = HomeViewModel()
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Firebase'deki URL'den resmi yükle
            if let imageUrlString = restaurant.imageURL,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                        }
                        .frame(width: 190, height: 140)
                        .cornerRadius(10)
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 190, height: 140)
                            .clipped()
                            .cornerRadius(10)
                        
                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 190, height: 140)
                        .cornerRadius(10)
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // URL yoksa varsayılan görsel
                Image("restaurant")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 190, height: 140)
                    .clipped()
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(restaurant.name ?? "Bilinmeyen Restoran")
                        .lineLimit(1)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating ?? 0.0))
                        .foregroundColor(.black)
                        .bold()
                }
                
                HStack {
                    Text(restaurant.category ?? "Kategori Yok")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                    Text(restaurant.district ?? "Bölge Yok")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 190)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
