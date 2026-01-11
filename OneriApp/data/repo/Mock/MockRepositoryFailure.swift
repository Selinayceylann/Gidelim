//
//  MockRepositoryFailure.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 31.12.2025.
//

import Foundation

final class MockRepositoryFailure: OneriAppRepositoryProtocol {
    func loadRestaurants() async throws -> [Restaurant] {
        throw NSError(domain: "TestError", code: -1)
    }

    func loadUser(userId: String) async throws -> User {
        throw NSError(domain: "TestError", code: -1)
    }

    func togglePlannedPlace(userId: String, restaurantId: String) async throws {
        throw NSError(domain: "TestError", code: -1)
    }

    func saveUser(_ user: User) async -> Bool {
        return false
    }
}
