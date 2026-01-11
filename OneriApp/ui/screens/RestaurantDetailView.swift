//
//  RestaurantDetail.swift
//  OneriApp
//
//  Created by selinay ceylan on 16.10.2025.
//

import SwiftUI
import Foundation

struct RestaurantDetailView: View {

    enum Tab { case about, menu, comments }

    @State private var selectedTab: Tab = .about
    @StateObject var viewModel: RestaurantDetailViewModel
    @Environment(\.dismiss) private var dismiss

    let restaurant: Restaurant
    @State private var showCommentSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerView
                hashtagSection
                tabButtons

                switch selectedTab {
                case .about:
                    aboutView
                case .menu:
                    menuView
                case .comments:
                    commentsView
                }
            }
            .padding(.vertical)
        }
        .task {
            await viewModel.getCurrentUser()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Gidelim")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                }
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentSheetView(restaurant: restaurant)
        }
    }
}

#if DEBUG
let sampleRestaurant = Restaurant(
    id: "1",
    name: "Preview Restoran",
    district: "Kadıköy",
    fullAddress: "Kadıköy / İstanbul",
    phoneNumber: "0212 000 00 00",
    openingHours: "09:00 - 22:00",
    description: "Preview açıklaması",
    imageURL: nil,
    reviews: [],
    hasWifi: true,
    acceptsCreditCard: true,
    hasValetParking: false,
    hasKidsMenu: true,
    smokingAllowed: false,
    petFriendly: true,
    liveMusic: false,
    sportsBroadcast: false,
    hasAirConditioning: true,
    wheelchairAccessible: true,
    features: ["WiFi", "Vegan"],
    menu: []
)
#endif



private extension RestaurantDetailView {
    var hashtagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let features = restaurant.features, !features.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(features, id: \.self) { feature in
                            hashtagView(feature)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    func hashtagView(_ text: String) -> some View {
        Text("#\(text)")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(AppColor.mainColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppColor.mainColor.opacity(0.1))
            )
    }
}

private extension RestaurantDetailView {

    var headerView: some View {
        ZStack(alignment: .topTrailing) {

            AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 250)
            .clipped()
            .cornerRadius(12)
            .padding(.horizontal)

            Button {
                Task {
                    guard let restaurantId = restaurant.id else { return }
                    await viewModel.togglePlannedPlace(restaurantId: restaurantId)
                }
            } label: {
                Image(systemName: heartIconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding()
        }
    }

    var heartIconName: String {
        guard let restaurantId = restaurant.id else {
            return "heart"
        }
        return viewModel.isFavorite(restaurantId: restaurantId)
            ? "heart.fill"
            : "heart"
    }
}



private extension RestaurantDetailView {
    var aboutView: some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Açıklama").bold().font(.headline)
                    Text(restaurant.description ?? "").font(.callout)
                }
            }
            
            CardView {
                VStack(spacing: 12) {
                    InfoRow(iconColor: .pink, icon: "location", title: "Adres", subtitle: restaurant.fullAddress ?? "")
                    InfoRow(iconColor: .blue, icon: "phone", title: "Telefon", subtitle: restaurant.phoneNumber ?? "")
                    InfoRow(iconColor: .purple, icon: "clock", title: "Çalışma Saatleri", subtitle: restaurant.openingHours ?? "")
                }
            }
            
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Özellikler").bold().font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        FeatureRow(icon: "wifi", text: "Ücretsiz Wi-Fi", available: restaurant.hasWifi ?? false)
                        FeatureRow(icon: "creditcard", text: "Kredi Kartı", available: restaurant.acceptsCreditCard ?? false)
                        FeatureRow(icon: "car.fill", text: "Vale Park", available: restaurant.hasValetParking ?? false)
                        FeatureRow(icon: "figure.and.child.holdinghands", text: "Çocuk Menüsü", available: restaurant.hasKidsMenu ?? false)
                        FeatureRow(icon: "smoke", text: "Sigara İçilebilir", available: restaurant.smokingAllowed ?? false)
                        FeatureRow(icon: "pawprint.fill", text: "Evcil Hayvan", available: restaurant.petFriendly! ?? false)
                        FeatureRow(icon: "music.note", text: "Canlı Müzik", available: restaurant.liveMusic ?? false)
                        FeatureRow(icon: "tv", text: "Spor Yayını", available: restaurant.sportsBroadcast ?? false)
                        FeatureRow(icon: "wind", text: "Klima", available: restaurant.hasAirConditioning ?? false)
                        FeatureRow(icon: "figure.roll", text: "Engelli Erişimi", available: restaurant.wheelchairAccessible! ?? false)
                    }
                }
            }
            Spacer(minLength: 20)
        }
    }
}

private extension RestaurantDetailView {
    var menuView: some View {
        CardView {
            VStack(spacing: 16) {
                ForEach(restaurant.menu ?? [], id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "").font(.body).bold()
                            Text(item.category ?? "").font(.caption).foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        AsyncImage(url: URL(string: item.image ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.vertical, 4)
                    
                    if item.id != restaurant.menu?.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}

private extension RestaurantDetailView {

    var tabButtons: some View {
        HStack {
            TabButton(title: "Hakkında", selected: selectedTab == .about) {
                selectedTab = .about
            }
            TabButton(title: "Menü", selected: selectedTab == .menu) {
                selectedTab = .menu
            }
            TabButton(title: "Yorumlar", selected: selectedTab == .comments) {
                selectedTab = .comments
            }
        }
        .padding(.horizontal)
    }
}


private extension RestaurantDetailView {
    var commentsView: some View {
        VStack(spacing: 16) {
            Button(action: {
                showCommentSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.headline)
                    Text("Yorum Yap")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColor.mainColor)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            CardView {
                if let reviews = restaurant.reviews, !reviews.isEmpty {
                    ForEach(reviews, id: \.id) { item in
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.userName ?? "Anonim")
                                    .bold()
                                Text(item.comment ?? "")
                                    .font(.callout)
                            }
                            Spacer()
                            VStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppColor.mainColor)
                                Text(String(format: "%.1f", item.rating ?? 0))
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if item.id != reviews.last?.id {
                            Divider()
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Henüz yorum yapılmamış")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("İlk yorumu siz yapın!")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
        }
    }
}

struct CommentSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let restaurant: Restaurant
    
    @State private var commentText = ""
    @State private var rating: Double = 5.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name ?? "")
                            .font(.headline)
                        Text(restaurant.district ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Puanınız")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: Double(index) <= rating ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(Double(index) <= rating ? .yellow : .gray)
                                .onTapGesture {
                                    rating = Double(index)
                                }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Yorumunuz")
                        .font(.headline)
                    
                    TextEditor(text: $commentText)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Gönder")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(commentText.isEmpty ? Color.gray : AppColor.mainColor)
                        .cornerRadius(12)
                }
                .disabled(commentText.isEmpty)
            }
            .padding()
            .navigationTitle("Yorum Yap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(AppColor.mainColor)
                }
            }
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
    }
}

struct InfoRow: View {
    let iconColor: Color
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(subtitle)
                    .font(.callout)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct TabButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(selected ? AppColor.mainColor : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(selected ? AppColor.mainColor.opacity(0.1) : Color.clear)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RestaurantDetailView(
        viewModel: RestaurantDetailViewModel(
            repository: PreviewRepository(),
            authService: PreviewAuthService()
        ),
        restaurant: sampleRestaurant
    )
}



struct FeatureRow: View {
    let icon: String
    let text: String
    let available: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(available ? AppColor.mainColor : .gray)
                .frame(width: 20)
            
            Text(text)
                .foregroundColor(available ? .primary : .gray)
            
            Spacer()
            
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(available ? AppColor.mainColor : .red.opacity(0.6))
        }
        .opacity(available ? 1.0 : 0.6)
    }
}

