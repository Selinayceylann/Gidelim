//
//  ContentView.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.10.2025.
//

import SwiftUI

struct HomeView: View {
    
    let categories: [String] = [
        "Tümü", "Restoran", "Kafe", "Bar", "Fast Food", "Pastane", "Kahvaltı", "Deniz Ürünleri", "Et Lokantası", "Vejetaryen"
    ]

    @StateObject var viewModel = HomeViewModel()
    @State private var selectedCategory: String = "Tümü"
    
    var filteredRestaurants: [Restaurant] {
            if selectedCategory == "Tümü" {
                return viewModel.restaurants
            }
            return viewModel.restaurants.filter { $0.category == selectedCategory }
        }
    
    var body: some View {
        TabView {
            
            NavigationStack {
                ZStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            Text("Sizin İçin Önerilenler")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                                .padding(.leading, 16)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(height: 200)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(alignment: .top, spacing: 16) {
                                        ForEach(viewModel.recommendedRestaurants) { restaurant in
                                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                                RestaurantCardView(restaurant: restaurant)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            Text("Keşfedilmeye Açık Mekanlar")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(height: 200)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(alignment: .top, spacing: 16) {
                                        ForEach(viewModel.recommendedRestaurants) { restaurant in
                                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                                RestaurantCardView(restaurant: restaurant)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            Text("Popüler Mekanlar")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        Button(action: {
                                            selectedCategory = category
                                        }) {
                                            Text(category)
                                                .font(.subheadline)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedCategory == category ? Color(red: 0.2, green: 0.7, blue: 0.5).opacity(0.1) : Color.white)
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .stroke(selectedCategory == category ? Color(red: 0.2, green: 0.7, blue: 0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                                .foregroundColor(selectedCategory == category ? Color(red: 0.2, green: 0.7, blue: 0.5) : .black)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(height: 200)
                                } else if filteredRestaurants.isEmpty {
                                    Text("Bu kategoride mekan bulunamadı")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {

                                    ForEach(filteredRestaurants) { restaurant in
                                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                            DistrictRestaurantCardView(
                                                restaurant: restaurant,
                                                isLoggedIn: viewModel.isLoggedIn
                                            )
                                            .environmentObject(viewModel)
                                            .padding(.bottom, 8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal)

                        }
                        .padding(.bottom, 20)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Spacer()
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 4)
                                .padding()
                            Spacer()
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Gidelim")
                .task {
                    await viewModel.getCurrentUser()
                    await viewModel.loadRestaurants()
                }
                .refreshable {
                    await viewModel.loadRestaurants()
                }
            }
            .tabItem {
                Label("Anasayfa", systemImage: "house.fill")
            }
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Arama", systemImage: "magnifyingglass")
            }
            
            NavigationStack {
                MapView()
            }
            .background(Color(.systemGroupedBackground))
            .tabItem {
                Label("Harita", systemImage: "map.fill")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
        .accentColor(Color(red: 0.2, green: 0.7, blue: 0.5))
    }
}

#Preview {
    HomeView()
}
