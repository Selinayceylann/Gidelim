//
//  MockRepositorySuccess.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

import Foundation

final class MockRepositorySuccess: OneriAppRepositoryProtocol {
    func saveUser(_ user: User) async -> Bool {
        return true
    }
    

    func loadUser(userId: String) async throws -> User {
        User(id: userId, plannedPlaces: [])
    }

    func loadRestaurants() async throws -> [Restaurant] {
        return [
            Restaurant(id: "1", name: "Mock Restoran", district: "Kadıköy")
        ]
    }


    func togglePlannedPlace(userId: String, restaurantId: String) async throws {
        // success
    }
}
