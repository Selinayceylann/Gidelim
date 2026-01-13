//
//  MockAuthServiceFailure.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 13.01.2026.
//


import Foundation
@testable import OneriApp

final class MockAuthServiceFailure: AuthServiceProtocol {

    func signIn(email: String, password: String) async throws -> AuthUser {
        throw NSError(
            domain: "AuthError",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Invalid credentials"
            ]
        )
    }

    func signUp(email: String, password: String) async throws -> AuthUser {
        throw NSError(domain: "AuthError", code: -1)
    }

    func signOut() async throws {}
    func getCurrentUser() -> AuthUser? { nil }
}


