//
//  PreviewAuthService.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.01.2026.
//

import Foundation

final class PreviewAuthService: AuthServiceProtocol {

    func signUp(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "preview-uid", email: email)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "preview-uid", email: email)
    }

    func signOut() async throws {}

    func getCurrentUser() -> AuthUser? {
        AuthUser(uid: "preview-uid", email: "preview@mail.com")
    }
}
