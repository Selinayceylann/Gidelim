//
//  SignUpViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 2.11.2025.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {

    private let authRepository: FirebaseAuthServiceProtocol
    private let repository: OneriAppRepositoryProtocol

    @Published var isLoading = false
    @Published var errorMessage: String?

    init(
        authRepository: FirebaseAuthServiceProtocol = FirebaseAuthService(),
        repository: OneriAppRepositoryProtocol = OneriAppRepository()
    ) {
        self.authRepository = authRepository
        self.repository = repository
    }

    func signUp(email: String, password: String) async -> AuthUser? {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authRepository.signUp(email: email, password: password)
            isLoading = false
            return user
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    func saveUserToFirestore(user: User) async -> Bool {
        await repository.saveUser(user)
    }
}
