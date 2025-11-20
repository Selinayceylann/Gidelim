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
    private let service = FirebaseAuthService()
    private let repository = OneriAppRepository()
    
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
            print("❌ No current user found")
            errorMessage = "Lütfen giriş yapın"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.togglePlannedPlace(userId: userId, restaurantId: restaurantId)
            print("✅ Planned place toggled successfully")
            
            await refreshUser()
        } catch {
            errorMessage = "İşlem başarısız: \(error.localizedDescription)"
            print("❌ Error toggling planned place: \(error)")
        }
        
        isLoading = false
    }

    func getCurrentUser() async {
        if let firebaseUser = Auth.auth().currentUser {
            print("🔍 Loading user: \(firebaseUser.uid)")
            do {
                let userData = try await repository.loadUser(userId: firebaseUser.uid)
                self.currentUser = userData
                self.isLoggedIn = true
                print("✅ User loaded successfully. Planned places: \(userData.plannedPlaces?.count ?? 0)")
            } catch {
                self.currentUser = nil
                self.isLoggedIn = false
                self.errorMessage = "Kullanıcı yüklenemedi: \(error.localizedDescription)"
                print("❌ Error loading user: \(error)")
            }
        } else {
            self.currentUser = nil
            self.isLoggedIn = false
            print("⚠️ No Firebase user found")
        }
    }

    func refreshUser() async {
        print("🔄 Refreshing user...")
        await getCurrentUser()
    }
    
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
