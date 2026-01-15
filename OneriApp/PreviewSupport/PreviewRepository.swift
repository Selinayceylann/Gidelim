//
//  PreviewRepository.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.01.2026.
//

import Foundation

final class PreviewRepository: OneriAppRepositoryProtocol {

    func search(searchText: String) async throws -> [Restaurant] {
        let all = try await fetchRestaurants()

        guard !searchText.isEmpty else {
            return all
        }

        return all.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

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
        try await fetchRestaurants()
    }

    func togglePlannedPlace(userId: String, restaurantId: String) async throws {
        // no-op (Preview için yeterli)
    }

    func saveUser(_ user: User) async -> Bool {
        true
    }

    func fetchRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(
                id: "1",
                name: "Preview Restaurant",
                district: "Kadıköy",
                latitude: 41.0,
                longitude: 29.0
            ),
            Restaurant(
                id: "2",
                name: "Preview Cafe",
                district: "Beşiktaş",
                latitude: 41.04,
                longitude: 29.01
            )
        ]
    }
}
