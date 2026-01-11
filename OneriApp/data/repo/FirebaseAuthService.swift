//
//  FirebaseAuthService.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

import FirebaseAuth

struct AuthUser {
    let uid: String
    let email: String?
}

final class FirebaseAuthService: FirebaseAuthServiceProtocol {

    func signUp(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth()
            .createUser(withEmail: email, password: password)

        return AuthUser(
            uid: result.user.uid,
            email: result.user.email
        )
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth()
            .signIn(withEmail: email, password: password)

        return AuthUser(
            uid: result.user.uid,
            email: result.user.email
        )
    }

    func signOut() async throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthUser(uid: user.uid, email: user.email)
    }
}
