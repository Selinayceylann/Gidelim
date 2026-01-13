//
//  ProfileViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 3.11.2025.
//
import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authRepository = AuthService()
    private let repository = OneriAppRepository()
    
    func loadCurrentUser() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let firebaseUser = authRepository.getCurrentUser() else {
            errorMessage = "Kullanıcı oturumu bulunamadı."
            return
        }
        
        do {
            currentUser = try await repository.loadUser(userId: firebaseUser.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addComment(review: Review) async {
        guard let userId = currentUser?.id else { return }
        do {
            try await repository.addComment(userId: userId, review: review)
            currentUser?.comments?.append(review)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteComment(commentId: String) async {
        guard let userId = currentUser?.id else { return }
        do {
            try await repository.deleteComment(userId: userId, commentId: commentId)
            currentUser?.comments?.removeAll { $0.id == commentId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    
    func getFavoriteRestaurants() async -> [Restaurant] {
        guard let userId = currentUser?.id,
              let favoriteIds = currentUser?.plannedPlaces else { return [] }
        do {
            return try await repository.getFavoriteRestaurants(userId: userId, favoriteIds: favoriteIds)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
        
        func signOut() async throws {
            do {
                try await authRepository.signOut()
                currentUser = nil
                print("Çıkış yapıldı")
            }
            catch {
                print("Çıkış hatası: \(error.localizedDescription)")
                throw error
            }
        }
    }
