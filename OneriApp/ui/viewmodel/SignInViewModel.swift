//
//  SignInViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 2.11.2025.
//

import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    private let authRepository = FirebaseAuthService()
    @Published var errorMessage: String?
    
    func signIn(email: String, password: String) async -> Bool {
        do {
           _ = try await authRepository.signIn(email: email, password: password)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
