//
//  ContentView.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.10.2025.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var container: AppContainer

        init(viewModel: HomeViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }
    
    
    let categories: [String] = [
        "Tümü", "Restoran", "Kafe", "Bar", "Fast Food", "Pastane", "Kahvaltı", "Deniz Ürünleri", "Et Lokantası", "Vejetaryen"
    ]
    
    @State private var selectedCategory: String = "Tümü"
    
    var body: some View {
        TabView {
            homeTab
            searchTab
            mapTab
            profileTab
        }
        .accentColor(Color(red: 0.2, green: 0.7, blue: 0.5))
    }
}

// MARK: - Computed Properties
private extension HomeView {
    var filteredRestaurants: [Restaurant] {
        if selectedCategory == "Tümü" {
            return viewModel.restaurants
        }
        return viewModel.restaurants.filter { $0.category == selectedCategory }
    }
}

// MARK: - Tab Views
private extension HomeView {
    var homeTab: some View {
        NavigationStack {
            ZStack {
                mainScrollView
                errorOverlay
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
    }
    
    var searchTab: some View {
        NavigationStack {
            SearchView(container: container)
        }
        .environmentObject(container)
        .tabItem {
            Label("Arama", systemImage: "magnifyingglass")
        }
    }
    
    var mapTab: some View {
        NavigationStack {
            MapView()
        }
        .background(Color(.systemGroupedBackground))
        .tabItem {
            Label("Harita", systemImage: "map.fill")
        }
    }
    
    var profileTab: some View {
        NavigationStack {
            ProfileView()
        }
        .tabItem {
            Label("Profil", systemImage: "person.fill")
        }
    }
}

// MARK: - Main Content
private extension HomeView {
    var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                recommendedSection
                discoverSection
                popularSection
                categoriesScrollView
                restaurantsList
            }
            .padding(.bottom, 20)
        }
    }
    
    var errorOverlay: some View {
        Group {
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
    }
}

// MARK: - Recommended Section
private extension HomeView {
    var recommendedSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Sizin İçin Önerilenler")
            
            if viewModel.isLoading {
                loadingView
            } else {
                horizontalRestaurantList(restaurants: viewModel.recommendedRestaurants)
            }
        }
    }
}

// MARK: - Discover Section
private extension HomeView {
    var discoverSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Keşfedilmeye Açık Mekanlar")
            
            if viewModel.isLoading {
                loadingView
            } else {
                horizontalRestaurantList(restaurants: viewModel.recommendedRestaurants)
            }
        }
    }
}

// MARK: - Popular Section
private extension HomeView {
    var popularSection: some View {
        sectionHeader(title: "Popüler Mekanlar")
    }
    
    var categoriesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func categoryButton(for category: String) -> some View {
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

// MARK: - Restaurants List
private extension HomeView {
    var restaurantsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isLoading {
                loadingView
            } else if filteredRestaurants.isEmpty {
                emptyStateView
            } else {
                restaurantsContent
            }
        }
        .padding(.horizontal)
    }
    
    var emptyStateView: some View {
        Text("Bu kategoride mekan bulunamadı")
            .foregroundColor(.gray)
            .padding()
    }
    
    var restaurantsContent: some View {
        ForEach(filteredRestaurants) { restaurant in
            NavigationLink(destination: RestaurantDetailView(
                viewModel: container.makeRestaurantDetailViewModel(),
                restaurant: restaurant
            )) {
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

// MARK: - Reusable Components
private extension HomeView {
    func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.leading, 16)
    }
    
    var loadingView: some View {
        ProgressView()
            .frame(height: 200)
    }
    
    func horizontalRestaurantList(restaurants: [Restaurant]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 16) {
                ForEach(restaurants) { restaurant in
                    NavigationLink {
                        RestaurantDetailView(
                            viewModel: container.makeRestaurantDetailViewModel(),
                            restaurant: restaurant
                        )
                    } label: {
                        RestaurantCardView(restaurant: restaurant)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    let container = AppContainer(
        repository: PreviewRepository(),
        authService: PreviewAuthService()
    )
    let homeVM = container.makeHomeViewModel()

    HomeView(viewModel: homeVM)
        .environmentObject(homeVM)     // DistrictRestaurantCardView için
        .environmentObject(container)  // DI için
}




