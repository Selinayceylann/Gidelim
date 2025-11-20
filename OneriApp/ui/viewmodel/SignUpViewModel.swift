//
//  SignUpViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 2.11.2025.
//

import Foundation
import FirebaseAuth

@MainActor
class SignUpViewModel: ObservableObject {
    private let authRepository = FirebaseAuthService()
    private let repository = OneriAppRepository()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func signUp(email: String, password: String) async -> FirebaseAuth.User? {
        isLoading = true
        errorMessage = nil
        
        do {
            let firebaseUser = try await authRepository.signUp(email: email, password: password)
            print("Firebase Auth user created: \(firebaseUser.uid)")
            isLoading = false
            return firebaseUser
        } catch {
            errorMessage = error.localizedDescription
            print("SignUp error: \(error.localizedDescription)")
            isLoading = false
            return nil
        }
    }
    
    func saveUserToFirestore(user: User) async -> Bool {
        errorMessage = nil
        
        guard let userId = user.id else {
            errorMessage = "Kullanıcı ID'si bulunamadı"
            return false
        }
        
        do {
            try await repository.saveUserToFirestore(user: user)
            print("User saved to Firestore with ID: \(userId)")
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Firestore save error: \(error.localizedDescription)")
            return false
        }
    }
}
