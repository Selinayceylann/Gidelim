//
//  MockAuthService.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

import Foundation
@testable import OneriApp

final class MockAuthService: FirebaseAuthServiceProtocol {

    var currentUser: AuthUser?

    func signUp(email: String, password: String) async throws -> AuthUser {
        let user = AuthUser(uid: "mock-uid", email: email)
        currentUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let user = AuthUser(uid: "mock-uid", email: email)
        currentUser = user
        return user
    }

    func signOut() async throws {
        currentUser = nil
    }

    func getCurrentUser() -> AuthUser? {
        currentUser
    }
}
