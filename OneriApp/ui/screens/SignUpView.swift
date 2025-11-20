//
//  SignUpView.swift
//  OneriApp
//
//  Created by selinay ceylan on 1.11.2025.
//

import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var agreeToTerms = false
    @State private var navigateToHome = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    headerSection
                    registerForm
                    termsSection
                    registerButton
                    loginLink
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColor.mainColor)
                        Text("Geri")
                            .foregroundColor(AppColor.mainColor)
                    }
                }
            }
        }
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
    }
}

private extension SignUpView {
    var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColor.mainColor)
            
            Text("Hesap Oluştur")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
            
            Text("Hemen ücretsiz hesap oluşturun")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 20)
    }
    
    var registerForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ad Soyad")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    TextField("Ad ve soyadınız", text: $fullName)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("E-posta")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("ornek@email.com", text: $email)
                        .foregroundColor(.gray)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Şifre")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if isPasswordVisible {
                        TextField("En az 6 karakter", text: $password)
                    } else {
                        SecureField("En az 6 karakter", text: $password)
                    }
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Şifre Tekrar")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    
                    if isConfirmPasswordVisible {
                        TextField("Şifrenizi tekrar girin", text: $confirmPassword)
                    } else {
                        SecureField("Şifrenizi tekrar girin", text: $confirmPassword)
                    }
                    
                    Button(action: {
                        isConfirmPasswordVisible.toggle()
                    }) {
                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    var termsSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: {
                agreeToTerms.toggle()
            }) {
                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                    .foregroundColor(agreeToTerms ? AppColor.mainColor : .gray)
                    .font(.title3)
            }
            
            Text("Kullanım koşullarını ve gizlilik politikasını okudum, kabul ediyorum.")
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    var registerButton: some View {
        Button(action: {
            // Validasyon kontrolleri
            guard !fullName.isEmpty else {
                alertMessage = "Lütfen ad ve soyadınızı girin"
                showAlert = true
                return
            }
            
            guard !email.isEmpty else {
                alertMessage = "Lütfen e-posta adresinizi girin"
                showAlert = true
                return
            }
            
            guard password.count >= 6 else {
                alertMessage = "Şifre en az 6 karakter olmalıdır"
                showAlert = true
                return
            }
            
            guard password == confirmPassword else {
                alertMessage = "Şifreler eşleşmiyor"
                showAlert = true
                return
            }
            
            Task {
                let firebaseUser = await viewModel.signUp(email: email, password: password)
                
                if let firebaseUser = firebaseUser {
                    print("✅ Firebase Auth user created: \(firebaseUser.uid)")
                    
                    let nameParts = fullName.split(separator: " ", maxSplits: 1)
                    let firstName = nameParts.first.map(String.init) ?? ""
                    let lastName = nameParts.count > 1 ? String(nameParts[1]) : ""
                    
                    let user = User(
                        id: firebaseUser.uid,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        comments: [],
                        plannedPlaces: [],
                        historySearch: []
                    )
                    
                    let saveSuccess = await viewModel.saveUserToFirestore(user: user)
                    
                    if saveSuccess {
                        print("✅ User saved to Firestore")
                        navigateToHome = true
                    } else {
                        alertMessage = viewModel.errorMessage ?? "Kullanıcı kaydedilemedi"
                        showAlert = true
                        print("❌ Failed to save user: \(viewModel.errorMessage ?? "Unknown error")")
                    }
                } else {
                    alertMessage = viewModel.errorMessage ?? "Kayıt başarısız"
                    showAlert = true
                    print("❌ Sign up failed: \(viewModel.errorMessage ?? "Unknown error")")
                }
            }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Kayıt Ol")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(agreeToTerms ? AppColor.mainColor : Color.gray)
                    .cornerRadius(12)
                    .shadow(color: agreeToTerms ? AppColor.mainColor.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            }
        }
        .disabled(!agreeToTerms || viewModel.isLoading)
    }
    
    var loginLink: some View {
        HStack {
            Text("Zaten hesabınız var mı?")
                .foregroundColor(.gray)
            Button(action: { dismiss() }) {
                Text("Giriş Yap")
                    .foregroundColor(AppColor.mainColor)
                    .bold()
            }
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
