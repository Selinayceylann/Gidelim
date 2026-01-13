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
    @StateObject private var viewModel: SignUpViewModel

        init(viewModel: SignUpViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }


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
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .foregroundColor(AppColor.mainColor)
                }
            }
        }
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView(
                    viewModel: HomeViewModel(
                        repository: OneriAppRepository(),
                        authService: AuthService()
                    )
                )
        }
    }
}

// MARK: - Subviews
private extension SignUpView {

    var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColor.mainColor)

            Text("Hesap Oluştur")
                .font(.largeTitle)
                .bold()

            Text("Hemen ücretsiz hesap oluşturun")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 20)
    }

    var registerForm: some View {
        VStack(spacing: 16) {

            inputField(
                title: "Ad Soyad",
                systemImage: "person",
                text: $fullName,
                placeholder: "Ad ve soyadınız"
            )

            inputField(
                title: "E-posta",
                systemImage: "envelope",
                text: $email,
                placeholder: "ornek@email.com",
                keyboardType: .emailAddress
            )

            passwordField(
                title: "Şifre",
                text: $password,
                isVisible: $isPasswordVisible,
                placeholder: "En az 6 karakter"
            )

            passwordField(
                title: "Şifre Tekrar",
                text: $confirmPassword,
                isVisible: $isConfirmPasswordVisible,
                placeholder: "Şifrenizi tekrar girin"
            )
        }
    }

    var termsSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                agreeToTerms.toggle()
            } label: {
                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                    .foregroundColor(agreeToTerms ? AppColor.mainColor : .gray)
                    .font(.title3)
            }

            Text("Kullanım koşullarını ve gizlilik politikasını okudum, kabul ediyorum.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    var registerButton: some View {
        Button {
            signUp()
        } label: {
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
                    .background(agreeToTerms ? AppColor.mainColor : .gray)
                    .cornerRadius(12)
            }
        }
        .disabled(!agreeToTerms || viewModel.isLoading)
    }

    var loginLink: some View {
        HStack {
            Text("Zaten hesabınız var mı?")
                .foregroundColor(.gray)
            Button("Giriş Yap") {
                dismiss()
            }
            .foregroundColor(AppColor.mainColor)
            .bold()
        }
        .font(.subheadline)
    }
}

// MARK: - Actions
private extension SignUpView {

    func signUp() {
        if let error = viewModel.validate(
                fullName: fullName,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            ) {
                showError(error)
                return
            }

        Task {
            let authUser = await viewModel.signUp(email: email, password: password)

            guard let authUser else {
                showError(viewModel.errorMessage ?? "Kayıt başarısız")
                return
            }

            let parts = fullName.split(separator: " ", maxSplits: 1)
            let firstName = parts.first.map(String.init) ?? ""
            let lastName = parts.count > 1 ? String(parts[1]) : ""

            let user = User(
                id: authUser.uid,
                firstName: firstName,
                lastName: lastName,
                email: email,
                comments: [],
                plannedPlaces: [],
                historySearch: []
            )

            let success = await viewModel.saveUserToFirestore(user: user)

            if success {
                navigateToHome = true
            } else {
                showError(viewModel.errorMessage ?? "Kullanıcı kaydedilemedi")
            }
        }
    }

    func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Reusable Components
private extension SignUpView {

    func inputField(
        title: String,
        systemImage: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.gray)
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    func passwordField(
        title: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)

                if isVisible.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }

                Button {
                    isVisible.wrappedValue.toggle()
                } label: {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(
            viewModel: SignUpViewModel()
        )
    }
}
