import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigateToSignIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showFavorites = false
    @State private var showComments = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ZStack(alignment: .bottom) {
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.7, blue: 0.5), Color(red: 0.15, green: 0.55, blue: 0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(red: 0.2, green: 0.7, blue: 0.5), Color(red: 0.15, green: 0.8, blue: 0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 45))
                                        .foregroundColor(.white)
                                    
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                                        )
                                        .offset(x: 35, y: 35)
                                }
                                
                                HStack(spacing: 8) {
                                    Text(viewModel.currentUser?.firstName ?? "İsim")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(viewModel.currentUser?.lastName ?? "Soyisim")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Text(viewModel.currentUser?.email ?? "kullanici@email.com")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 0) {
                                    StatView(number: "\(viewModel.currentUser?.comments?.count ?? 0)", label: "Yorum")
                                    
                                    Divider()
                                        .frame(height: 40)
                                    
                                    StatView(number: "\(viewModel.currentUser?.plannedPlaces?.count ?? 0)", label: "Favori")
                                }
                                .padding(.horizontal, 30)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                            )
                            .padding(.horizontal, 30)
                            .offset(y: 80)
                        }
                        .padding(.bottom, 80)
                        
                        VStack(spacing: 12) {
                            MenuButton(
                                icon: "heart.fill",
                                iconColor: Color(red: 0.2, green: 0.7, blue: 0.5),
                                title: "Favorilerim",
                                subtitle: "Gitmek İstediğin Mekanlar",
                                action: { showFavorites = true }
                            )
                            
                            MenuButton(
                                icon: "message.fill",
                                iconColor: .blue,
                                title: "Yorumlarım",
                                subtitle: "Yaptığın Değerlendirmeler",
                                action: { showComments = true }
                            )
                            
                            MenuButton(
                                icon: "bookmark.fill",
                                iconColor: .purple,
                                title: "Kayıtlı Listeler",
                                subtitle: "Özel Koleksiyonların"
                            )
                            
                            MenuButton(
                                icon: "bell.fill",
                                iconColor: .pink,
                                title: "Bildirimler",
                                subtitle: "Bildirim Ayarları"
                            )
                            
                            MenuButton(
                                icon: "gearshape.fill",
                                iconColor: .gray,
                                title: "Ayarlar",
                                subtitle: "Uygulama Tercihleri"
                            )
                            
                            Button(action: {
                                Task {
                                    do {
                                        try await viewModel.signOut()
                                        print("✅ Firebase çıkış başarılı")
                                        navigateToSignIn = true
                                    } catch {
                                        print("❌ Çıkış hatası: \(error.localizedDescription)")
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.15))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Çıkış Yap")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red)
                                        
                                        Text("Hesaptan Çık")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
            .task {
                await viewModel.loadCurrentUser()
            }
            .fullScreenCover(isPresented: $navigateToSignIn) {
                SignInView()
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $showFavorites) {
                FavoritesView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showComments) {
                CommentsView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ProfileView()
}
