//
//  FirebaseAuthService.swift
//  OneriApp
//
//  Created by selinay ceylan on 1.11.2025.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {

    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let user = result?.user else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                continuation.resume(returning: user)
            }
        }
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let user = result?.user else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                continuation.resume(returning: user)
            }
        }
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
