import SwiftUI

struct DistrictRestaurantCardView: View {
    let restaurant: Restaurant
    let isLoggedIn: Bool
    @EnvironmentObject var viewModel: HomeViewModel

    @State private var isFavorite: Bool = false
    @State private var showSignInAlert = false
    @State private var showSignInView = false

    var body: some View {
        HStack(spacing: 12) {
            // Resim
            if let imageUrlString = restaurant.imageURL,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 140, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 100)
                            .cornerRadius(10)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("restaurant")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 100)
                    .cornerRadius(10)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name ?? "")
                    .lineLimit(1)
                    .bold()
                    .foregroundColor(.black)
                    .font(.headline)

                Text(restaurant.district ?? "")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", restaurant.rating ?? 0.0))
                        .foregroundColor(.black)
                        .font(.callout)
                        .bold()
                    Text("(\(restaurant.reviews?.count ?? 0) yorum)")
                        .foregroundColor(.gray)
                        .font(.caption)

                    Spacer()

                    // Favori butonu
                    Button {
                        if viewModel.isLoggedIn && viewModel.currentUser != nil {
                            Task {
                                await viewModel.togglePlannedPlace(restaurantId: restaurant.id ?? "")
                                // refreshUser zaten togglePlannedPlace içinde çağrılıyor
                                updateFavoriteStatus()
                            }
                        } else {
                            showSignInAlert = true
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? AppColor.mainColor : .gray)
                            .font(.system(size: 22))
                    }
                    .alert("Favorilere eklemek için giriş yapmalısınız", isPresented: $showSignInAlert) {
                        Button("Vazgeç", role: .cancel) {}
                        Button("Giriş Yap") {
                            showSignInView = true
                        }
                    }
                }
            }
            .padding(.trailing, 8)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView()
                .ignoresSafeArea()
        }
        .onAppear {
            updateFavoriteStatus()
        }
        .onChange(of: viewModel.currentUser?.plannedPlaces) { _ in
            updateFavoriteStatus()
        }
    }
    
    private func updateFavoriteStatus() {
        if let planned = viewModel.currentUser?.plannedPlaces,
           let restaurantId = restaurant.id {
            isFavorite = planned.contains(restaurantId)
        } else {
            isFavorite = false
        }
    }
}
