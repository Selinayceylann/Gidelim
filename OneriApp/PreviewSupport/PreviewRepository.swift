//
//  PreviewRepository.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.01.2026.
//

import Foundation

final class PreviewRepository: OneriAppRepositoryProtocol {

    func loadUser(userId: String) async throws -> User {
        User(
            id: userId,
            firstName: "Preview",
            lastName: "User",
            email: "preview@mail.com",
            plannedPlaces: []
        )
    }

    func loadRestaurants() async throws -> [Restaurant] {
        []
    }

    func togglePlannedPlace(userId: String, restaurantId: String) async throws {
        // no-op
    }

    func saveUser(_ user: User) async -> Bool {
        true
    }
}
