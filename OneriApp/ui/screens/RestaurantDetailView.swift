//
//  RestaurantDetail.swift
//  OneriApp
//
//  Created by selinay ceylan on 16.10.2025.
//

import SwiftUI

struct RestaurantDetailView: View {
    enum Tab { case about, menu, comments }
    @State private var selectedTab: Tab = .about
    @StateObject var viewModel = RestaurantDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let restaurant: Restaurant
    @State private var isFavorite = false
    @State private var showCommentSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerView
                
                hashtagSection
                
                HStack(spacing: 16) {
                    TabButton(title: "Hakkında", selected: selectedTab == .about) { selectedTab = .about }
                    TabButton(title: "Menü", selected: selectedTab == .menu) { selectedTab = .menu }
                    TabButton(title: "Yorumlar", selected: selectedTab == .comments) { selectedTab = .comments }
                }
                .padding(.horizontal)
                
                switch selectedTab {
                case .about: aboutView
                case .menu: menuView
                case .comments: commentsView
                }
            }
            .padding(.vertical)
        }
        .task {
            await viewModel.loadRestaurants()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Gidelim")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        Text("Geri")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentSheetView(restaurant: restaurant)
        }
    }
}

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
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 250)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name ?? "")
                        .bold()
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(restaurant.rating ?? 0.0))
                            .bold()
                            .foregroundColor(.white)
                            .font(.callout)
                            .padding(.leading, -4)
                        Text("(\(restaurant.reviews?.count ?? 0))")
                            .bold()
                            .foregroundColor(.gray)
                            .font(.callout)
                            .padding(.leading, -4)
                        Image(systemName: "mappin")
                            .foregroundColor(.white)
                        Text(restaurant.district ?? "")
                            .bold()
                            .foregroundColor(.white)
                            .font(.callout)
                            .padding(.leading, -4)
                    }
                }
                .padding(.all, 12)
                .background(
                    Color.black.opacity(0.5)
                        .cornerRadius(8)
                )
                .padding(.leading, 24)
                .padding(.bottom, 8)
            }
            
            Button(action: { isFavorite.toggle() }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(isFavorite ? AppColor.mainColor : .white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .padding(.trailing, 28)
                    .padding(.top, 12)
            }
        }
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
                        FeatureRow(icon: "wifi", text: "Ücretsiz Wi-Fi", available: restaurant.hasWifi!)
                        FeatureRow(icon: "creditcard", text: "Kredi Kartı", available: restaurant.acceptsCreditCard!)
                        FeatureRow(icon: "car.fill", text: "Vale Park", available: restaurant.hasValetParking!)
                        FeatureRow(icon: "figure.and.child.holdinghands", text: "Çocuk Menüsü", available: restaurant.hasKidsMenu!)
                        FeatureRow(icon: "smoke", text: "Sigara İçilebilir", available: restaurant.smokingAllowed!)
                        FeatureRow(icon: "pawprint.fill", text: "Evcil Hayvan", available: restaurant.petFriendly!)
                        FeatureRow(icon: "music.note", text: "Canlı Müzik", available: restaurant.liveMusic!)
                        FeatureRow(icon: "tv", text: "Spor Yayını", available: restaurant.sportsBroadcast!)
                        FeatureRow(icon: "wind", text: "Klima", available: restaurant.hasAirConditioning!)
                        FeatureRow(icon: "figure.roll", text: "Engelli Erişimi", available: restaurant.wheelchairAccessible!)
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
                                Text(item.userName!)
                                    .bold()
                                Text(item.comment!)
                                    .font(.callout)
                            }
                            Spacer()
                            VStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppColor.mainColor)
                                Text(String(format: "%.1f", item.rating!))
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
    let sampleRestaurant = Restaurant(
        id: "1",
        name: "Güzel Mekan",
        district: "Kadıköy",
        fullAddress: "Moda Caddesi No:12, İstanbul",
        phoneNumber: "0212 123 45 67",
        openingHours: "09:00 - 23:00",
        description: "Deniz manzaralı, kahvaltı ve akşam yemeği için ideal bir mekan.",
        imageURL: "https://example.com/sample-image.jpg",
        category: "Kafe",
        rating: 4.5,
        reviews: [
            Review(id: "1", userName: "Selin", comment: "Harika bir yer!", rating: 5.0,  date: Date())
        ],
        popularityScore: 95,
        hasWifi: true,
        acceptsCreditCard: true,
        hasValetParking: true,
        hasKidsMenu: false,
        smokingAllowed: false,
        petFriendly: true,
        liveMusic: true,
        sportsBroadcast: false,
        hasAirConditioning: true,
        wheelchairAccessible: true,
        menu: [
            Menu(id: "1", name: "Kahve", category: "İçecek", image: "https://example.com/coffee.jpg"),
            Menu(id: "2", name: "Tost", category: "Atıştırmalık", image: "https://example.com/toast.jpg")
        ],
        latitude: 29.04,
        longitude: 42.01,
        features: ["Romantik", "Deniz Manzaralı", "Toplantı", "Fotoğraf Çekilmelik"]
    )
    
    RestaurantDetailView(restaurant: sampleRestaurant)
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
