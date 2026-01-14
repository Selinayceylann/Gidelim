//
//  MockRepositoryDelayed.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 14.01.2026.
//

import Foundation
@testable import OneriApp

final class MockRepositoryDelayed: OneriAppRepositoryProtocol {
    func loadRestaurants() async throws -> [Restaurant] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return []
    }

    func loadUser(userId: String) async throws -> User {
        User(id: userId, plannedPlaces: [])
    }

    func togglePlannedPlace(userId: String, restaurantId: String) async throws {}

    func saveUser(_ user: User) async -> Bool { true }
}
