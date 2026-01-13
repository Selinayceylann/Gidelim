//
//  HomeViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 14.10.2025.
//

import Foundation
import FirebaseAuth

@MainActor
class HomeViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let repository: OneriAppRepositoryProtocol
    
    init(
            repository: OneriAppRepositoryProtocol,
            authService: AuthServiceProtocol
        ) {
            self.repository = repository
            self.authService = authService
        }
    
    @Published var currentUser: User? = nil
    @Published var isLoggedIn: Bool = false
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var recommendedRestaurants: [Restaurant] {
        restaurants
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            .prefix(10)
            .map { $0 }
    }
    
    var popularRestaurants: [Restaurant] {
        restaurants
            .sorted { ($0.popularityScore ?? 0) > ($1.popularityScore ?? 0) }
    }
    
    func togglePlannedPlace(restaurantId: String) async {
        guard let user = currentUser, let userId = user.id else {
            print("No current user found")
            errorMessage = "Lütfen giriş yapın"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.togglePlannedPlace(userId: userId, restaurantId: restaurantId)
            print("Planned place toggled successfully")
            
            await refreshUser()
        } catch {
            errorMessage = "İşlem başarısız: \(error.localizedDescription)"
            print("Error toggling planned place: \(error)")
        }
        
        isLoading = false
    }

    func getCurrentUser() async {
        guard let firebaseUser = authService.getCurrentUser() else {
            self.currentUser = nil
            self.isLoggedIn = false
            return
        }

        do {
            let userData = try await repository.loadUser(userId: firebaseUser.uid)
            self.currentUser = userData
            self.isLoggedIn = true
        } catch {
            self.currentUser = nil
            self.isLoggedIn = false
            self.errorMessage = "Kullanıcı yüklenemedi: \(error.localizedDescription)"
        }
    }


    func refreshUser() async {
        print("Refreshing user...")
        await getCurrentUser()
    }
    
    func loadRestaurants() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await repository.loadRestaurants()
            restaurants = result
        } catch {
            restaurants = []
            errorMessage = error.localizedDescription
        }
    }

    
    func filterRestaurants(by district: String) -> [Restaurant] {
        if district == "Tümü" {
            return restaurants
        }
        
        let normalizedDistrict = district.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return restaurants.filter { restaurant in
            restaurant.district?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() == normalizedDistrict
        }
    }

}
