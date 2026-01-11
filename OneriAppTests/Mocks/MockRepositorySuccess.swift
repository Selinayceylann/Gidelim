//
//  MockRepositorySuccess.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

import Foundation
@testable import OneriApp

final class MockRepositorySuccess: OneriAppRepositoryProtocol {

    var restaurants: [Restaurant] = [
        Restaurant(id: "1", name: "Mock Restoran", district: "Kadıköy")
    ]

    var user: User?

    func saveUser(_ user: User) async -> Bool {
        true
    }

    func loadUser(userId: String) async throws -> User {
        user ?? User(id: userId, plannedPlaces: [])
    }

    func loadRestaurants() async throws -> [Restaurant] {
        restaurants
    }

    func togglePlannedPlace(userId: String, restaurantId: String) async throws {
        // success
    }
}
