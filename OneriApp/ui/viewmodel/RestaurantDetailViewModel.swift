//
//  RestaurantDetailViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 7.11.2025.
//

import Foundation
import SwiftUI

@MainActor
final class RestaurantDetailViewModel: ObservableObject {

    // MARK: - Dependencies
    private let repository: OneriAppRepositoryProtocol
    private let authService: FirebaseAuthServiceProtocol

    // MARK: - Published State
    @Published private(set) var restaurants: [Restaurant] = []
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(
        repository: OneriAppRepositoryProtocol,
        authService: FirebaseAuthServiceProtocol
    ) {
        self.repository = repository
        self.authService = authService
    }

    // MARK: - Public Functions

    func loadRestaurants() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            restaurants = try await repository.loadRestaurants()
        } catch {
            errorMessage = "Restoranlar yüklenirken hata oluştu"
        }
    }

    func getCurrentUser() async {
        errorMessage = nil

        guard let authUser = authService.getCurrentUser() else {
            currentUser = nil
            return
        }

        do {
            currentUser = try await repository.loadUser(userId: authUser.uid)
        } catch {
            errorMessage = "Kullanıcı yüklenemedi"
        }
    }

    func togglePlannedPlace(restaurantId: String) async {
        errorMessage = nil

        guard let userId = currentUser?.id else {
            errorMessage = "Lütfen giriş yapın"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await repository.togglePlannedPlace(
                userId: userId,
                restaurantId: restaurantId
            )
            await getCurrentUser()
        } catch {
            errorMessage = "İşlem başarısız"
        }
    }

    func isFavorite(restaurantId: String) -> Bool {
        currentUser?.plannedPlaces?.contains(restaurantId) ?? false
    }
}
