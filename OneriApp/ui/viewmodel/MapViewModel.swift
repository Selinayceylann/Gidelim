//
//  MapViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 10.11.2025.
//

import Foundation
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    private let repository: OneriAppRepositoryProtocol

    @Published var restaurants: [Restaurant] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(repository: OneriAppRepositoryProtocol) {
        self.repository = repository
    }

    func loadRestaurants() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedRestaurants = try await repository.loadRestaurants()
            self.restaurants = fetchedRestaurants
        } catch {
            self.errorMessage = "Restoranlar yüklenemedi: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

extension MapViewModel {

    func nearbyRestaurants(
        userLocation: CLLocation,
        maxDistance: CLLocationDistance = 1000
    ) -> [Restaurant] {

        restaurants.filter { restaurant in
            guard let lat = restaurant.latitude,
                  let lon = restaurant.longitude else { return false }

            let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
            return userLocation.distance(from: restaurantLocation) <= maxDistance
        }
    }
}

