//
//  MockAuthService.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

struct AuthUser {
    let uid: String
    let email: String?
}


final class MockAuthService: FirebaseAuthServiceProtocol {

    func signUp(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "mock-uid", email: email)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "mock-uid", email: email)
    }

    func signOut() async throws {}

    func getCurrentUser() -> AuthUser? {
        AuthUser(uid: "mock-uid", email: "mock@mail.com")
    }
}
