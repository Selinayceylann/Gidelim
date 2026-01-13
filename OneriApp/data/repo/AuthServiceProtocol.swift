//
//  FirebaseAuthServiceProtocol.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

import FirebaseAuth

protocol AuthServiceProtocol {
    func signUp(email: String, password: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
    func getCurrentUser() -> AuthUser?
}
