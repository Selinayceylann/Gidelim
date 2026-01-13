//
//  SignUpViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 2.11.2025.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {

    private let authRepository: AuthServiceProtocol
    private let repository: OneriAppRepositoryProtocol

    @Published var isLoading = false
    @Published var errorMessage: String?

    init(
        authRepository: AuthServiceProtocol = AuthService(),
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
    
    func validate(
        fullName: String,
        email: String,
        password: String,
        confirmPassword: String
    ) -> String? {

        if fullName.isEmpty {
            return "Lütfen ad ve soyadınızı girin"
        }

        if email.isEmpty {
            return "Lütfen e-posta adresinizi girin"
        }

        if password.count < 6 {
            return "Şifre en az 6 karakter olmalıdır"
        }

        if password != confirmPassword {
            return "Şifreler eşleşmiyor"
        }

        return nil
    }

}
