//
//  SignInView.swift
//  OneriApp
//
//  Created by selinay ceylan on 1.11.2025.
//


import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var navigateToHome = false
    @StateObject private var viewModel = SignInViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 60)
                        
                        logoSection
                        loginForm
                        forgotPasswordButton
                        loginButton
                        dividerSection
                        socialLoginButtons
                        signUpLink
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .fullScreenCover(isPresented: $navigateToHome) {
                HomeView(
                        viewModel: HomeViewModel(
                            repository: OneriAppRepository(),
                            authService: FirebaseAuthService()
                        )
                    )
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Hata"),
                    message: Text(error),
                    dismissButton: .default(Text("Tamam"))
                )
            }

        }
    }
}

private extension SignInView {
    var logoSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColor.mainColor)
            
            Text("Gidelim")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
            
            Text("Hoş geldiniz! Lütfen giriş yapın")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 20)
    }
    
    var loginForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("E-posta")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("ornek@email.com", text: $email)
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
                        TextField("Şifrenizi girin", text: $password)
                    } else {
                        SecureField("Şifrenizi girin", text: $password)
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
        }
    }
    
    var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button(action: {
            }) {
                Text("Şifremi Unuttum?")
                    .font(.subheadline)
                    .foregroundColor(AppColor.mainColor)
            }
        }
    }
    
    var loginButton: some View {
        Button(action: {
            Task {
                if await viewModel.signIn(email: email, password: password) {
                    navigateToHome = true
                }
            }
        }) {
            Text("Giriş Yap")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColor.mainColor)
                .cornerRadius(12)
                .shadow(color: AppColor.mainColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text("veya")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    var socialLoginButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.red)
                    Text("Google ile Giriş Yap")
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                        .foregroundColor(.black)
                    Text("Apple ile Giriş Yap")
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    var signUpLink: some View {
        HStack {
            Text("Hesabınız yok mu?")
                .foregroundColor(.gray)
            NavigationLink(destination: SignUpView()) {
                Text("Kayıt Ol")
                    .foregroundColor(AppColor.mainColor)
                    .bold()
            }
        }
        .font(.subheadline)
    }
}

extension String: Identifiable {
    public var id: String { self }
}


#Preview {
    SignInView()
}
