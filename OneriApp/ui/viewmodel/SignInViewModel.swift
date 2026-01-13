//
//  SignInViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 2.11.2025.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {

    private let authService: AuthServiceProtocol
    @Published var errorMessage: String?

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signIn(email: String, password: String) async -> Bool {
        do {
            _ = try await authService.signIn(email: email, password: password)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
