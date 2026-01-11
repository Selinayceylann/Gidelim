//
//  ContentView.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.10.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0605, longitude: 28.9872),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @StateObject private var viewModel = MapViewModel()
    @State private var showNearbySheet = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            mapSection
            loadingOverlay
            errorOverlay
            bottomInfoCard
        }
        .sheet(isPresented: $showNearbySheet) {
            BottomSheetView(restaurants: nearbyRestaurants)
                .presentationDetents([.fraction(0.25), .fraction(0.5), .large])
        }
        .task {
            await viewModel.loadRestaurants()
        }
    }
}

// MARK: - Computed Properties
private extension MapView {
    var nearbyRestaurants: [Restaurant] {
        let userLocation = CLLocation(latitude: 41.0605, longitude: 28.9872)
        return viewModel.restaurants.filter { restaurant in
            guard let lat = restaurant.latitude, let lon = restaurant.longitude else { return false }
            let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
            return userLocation.distance(from: restaurantLocation) <= 1000
        }
    }
    
    var allLocations: [Restaurant] {
        return viewModel.restaurants + [userLocationItem()]
    }
}

// MARK: - Map Section
private extension MapView {
    var mapSection: some View {
        Map(coordinateRegion: $region, annotationItems: allLocations) { place in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: place.latitude ?? 0,
                longitude: place.longitude ?? 0
            )) {
                if place.id == "user_location" {
                    userLocationAnnotation
                } else {
                    restaurantAnnotation(for: place)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var userLocationAnnotation: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "location.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                )
            Text("Ben")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(4)
                .background(Capsule().fill(Color.white))
        }
    }
    
    func restaurantAnnotation(for place: Restaurant) -> some View {
        NavigationLink(destination: RestaurantDetailView(restaurant: place)) {
            VStack(spacing: 4) {
                Circle()
                    .fill(AppColor.mainColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    )
                Text(place.name ?? "Bilinmeyen")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(4)
                    .background(Capsule().fill(Color.white))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Overlay Sections
private extension MapView {
    var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView("Mekanlar yükleniyor...")
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        Spacer()
                    }
                    Spacer()
                }
            }
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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Bottom Info Card
private extension MapView {
    var bottomInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                locationInfoSection
                Spacer()
                actionButtonsSection
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        }
        .padding()
    }
    
    var locationInfoSection: some View {
        VStack(alignment: .leading) {
            Text("Yakınımdaki Mekanlar")
                .font(.headline)
            Text("Çevremde \(nearbyRestaurants.count) mekan")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var actionButtonsSection: some View {
        HStack(spacing: 12) {
            centerLocationButton
            showSheetButton
        }
    }
    
    var centerLocationButton: some View {
        Button {
            withAnimation {
                region.center = CLLocationCoordinate2D(latitude: 41.0605, longitude: 28.9872)
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColor.mainColor)
                .padding()
                .background(Circle().fill(Color.white))
        }
    }
    
    var showSheetButton: some View {
        Button {
            withAnimation {
                showNearbySheet.toggle()
            }
        } label: {
            Image(systemName: "chevron.up.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(AppColor.mainColor)
        }
    }
}

// MARK: - Helper Functions
private extension MapView {
    func userLocationItem() -> Restaurant {
        Restaurant(
            id: "user_location",
            name: "Benim Konumum",
            district: "",
            fullAddress: "",
            phoneNumber: "",
            openingHours: "",
            description: "",
            imageURL: "",
            category: "",
            rating: 0,
            reviews: [],
            popularityScore: 0,
            hasWifi: false,
            acceptsCreditCard: false,
            hasValetParking: false,
            hasKidsMenu: false,
            smokingAllowed: false,
            petFriendly: false,
            liveMusic: false,
            sportsBroadcast: false,
            hasAirConditioning: false,
            wheelchairAccessible: false,
            latitude: 41.0605,
            longitude: 28.9872,
            features: [],
            menu: []
            
        )
    }
}

// MARK: - Bottom Sheet View
struct BottomSheetView: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Divider()
            contentSection
        }
    }
}

// MARK: - Bottom Sheet Extensions
private extension BottomSheetView {
    var headerSection: some View {
        HStack {
            Text("Yakındaki Mekanlar")
                .font(.title3)
                .bold()
            Spacer()
            Text("\(restaurants.count) mekan")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    var contentSection: some View {
        Group {
            if restaurants.isEmpty {
                emptyStateView
            } else {
                restaurantListView
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Yakında mekan bulunamadı")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    var restaurantListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(restaurants, id: \.id) { restaurant in
                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                        NearbyRestaurantCard(restaurant: restaurant)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Nearby Restaurant Card
struct NearbyRestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            restaurantIcon
            restaurantInfo
            Spacer()
            distanceInfo
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Restaurant Card Extensions
private extension NearbyRestaurantCard {
    var restaurantIcon: some View {
        Circle()
            .fill(AppColor.mainColor.opacity(0.15))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundColor(AppColor.mainColor)
            )
    }
    
    var restaurantInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(restaurant.name ?? "Bilinmeyen Mekan")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 4) {
                if let rating = restaurant.rating {
                    ratingSection(rating: rating)
                }
                
                Text(restaurant.district ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func ratingSection(rating: Double) -> some View {
        Group {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            Text(String(format: "%.1f", rating))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("•")
                .foregroundColor(.secondary)
        }
    }
    
    var distanceInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Image(systemName: "location.fill")
                .foregroundColor(AppColor.mainColor)
                .font(.caption)
            Text(distance)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var distance: String {
        let userLocation = CLLocation(latitude: 41.0605, longitude: 28.9872)
        guard let lat = restaurant.latitude, let lon = restaurant.longitude else {
            return "?"
        }
        let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
        let distanceInMeters = userLocation.distance(from: restaurantLocation)
        
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.1f km", distanceInMeters / 1000)
        }
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
}
