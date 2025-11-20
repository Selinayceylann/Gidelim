//
//  MapViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 10.11.2025.
//

import Foundation

@MainActor
class MapViewModel : ObservableObject {
    private var repository = OneriAppRepository()
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func loadRestaurants() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedRestaurants = try await repository.loadRestaurants()
            self.restaurants = fetchedRestaurants
        } catch {
            self.errorMessage = "Restoranlar yüklenemedi: \(error.localizedDescription)"
            print("Error loading restaurants: \(error)")
        }
        
        isLoading = false
    }
}
