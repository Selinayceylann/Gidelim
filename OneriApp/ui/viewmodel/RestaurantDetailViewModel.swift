//
//  RestaurantDetailViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 7.11.2025.
//


import Foundation
import FirebaseAuth

@MainActor
class RestaurantDetailViewModel: ObservableObject {
    private let repository = OneriAppRepository()
    private let authService = FirebaseAuthService()
    
    @Published var restaurants: [Restaurant] = []
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadRestaurants() async {
        await MainActor.run { isLoading = true }
        
        do {
            let fetchedRestaurants = try await repository.loadRestaurants()
            await MainActor.run {
                self.restaurants = fetchedRestaurants
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Restoranlar yüklenirken hata oluştu: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func getCurrentUser() async {
        if let firebaseUser = Auth.auth().currentUser {
            do {
                let userData = try await repository.loadUser(userId: firebaseUser.uid)
                self.currentUser = userData
            } catch {
                self.errorMessage = "Kullanıcı yüklenemedi: \(error.localizedDescription)"
                print("Error loading user: \(error)")
            }
        } else {
            self.currentUser = nil
            print("No Firebase user found")
        }
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
            
            await getCurrentUser()
        } catch {
            errorMessage = "İşlem başarısız: \(error.localizedDescription)"
            print("Error toggling planned place: \(error)")
        }
        
        isLoading = false
    }
    
    func isFavorite(restaurantId: String) -> Bool {
        return currentUser?.plannedPlaces?.contains(restaurantId) ?? false
    }
}
