import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showFilterSheet = false
    
    @State private var selectedDistrict: String = "Tümü"
    @State private var selectedCategory: String = "Tümü"
    @State private var selectedFeatures: Set<String> = []
    
    private let popularSearches = [
        ("Ders Çalışma", "Ders Çalışma"),
        ("Fotoğraf Çekilmelik", "Fotoğraf Çekilmelik"),
        ("Deniz Manzaralı", "Deniz Manzaralı"),
        ("Randevuluk", "Randevuluk"),
        ("Toplantı", "Toplantı"),
        ("Romantik", "Romantik"),
        ("Aile Mekanı", "Aile Mekanı"),
        ("Pet-Friendly", "Pet-Friendly")
    ]
    
    var filteredResults: [Restaurant] {
        var results = viewModel.searchResults
        
        if selectedDistrict != "Tümü" {
            results = results.filter { restaurant in
                guard let district = restaurant.district else { return false }
                return district.lowercased() == selectedDistrict.lowercased()
            }
        }
        
        if selectedCategory != "Tümü" {
            results = results.filter { restaurant in
                guard let category = restaurant.category else { return false }
                return category.lowercased() == selectedCategory.lowercased()
            }
        }
        
        if !selectedFeatures.isEmpty {
            results = results.filter { restaurant in
                guard let restaurantFeatures = restaurant.features else { return false }
                return selectedFeatures.allSatisfy { selectedFeature in
                    restaurantFeatures.contains { restaurantFeature in
                        restaurantFeature.lowercased() == selectedFeature.lowercased()
                    }
                }
            }
        }
        
        return results
    }
    
    var activeFilterCount: Int {
        var count = 0
        if selectedDistrict != "Tümü" { count += 1 }
        if selectedCategory != "Tümü" { count += 1 }
        count += selectedFeatures.count
        return count
    }
    
    var hasActiveFilters: Bool {
        selectedDistrict != "Tümü" || selectedCategory != "Tümü" || !selectedFeatures.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                searchBarWithFilter

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if activeFilterCount > 0 {
                            activeFiltersSection
                        }
                        
                        if !isSearchFieldFocused && searchText.isEmpty && !hasActiveFilters {
                            popularSearchesSection
                        }

                        if isSearchFieldFocused || !searchText.isEmpty || hasActiveFilters {
                            searchResultsList
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .animation(.easeInOut, value: isSearchFieldFocused)
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(
                    selectedDistrict: $selectedDistrict,
                    selectedCategory: $selectedCategory,
                    selectedFeatures: $selectedFeatures,
                    onApply: {
                        performSearch()
                    }
                )
            }
            .onAppear {
                searchText = ""
                isSearchFieldFocused = false
            }
        }
    }
    
    private func performSearch() {
        Task {
            await viewModel.search(searchText: searchText.isEmpty ? "" : searchText)
        }
    }
}

private extension SearchView {
    var activeFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .foregroundColor(AppColor.mainColor)
                Text("Aktif Filtreler (\(activeFilterCount))")
                    .font(.subheadline.bold())
                Spacer()
                Button("Temizle") {
                    selectedDistrict = "Tümü"
                    selectedCategory = "Tümü"
                    selectedFeatures.removeAll()
                    performSearch()
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            if #available(iOS 16.0, *) {
                FlowLayout(spacing: 8) {
                    filterChips
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChips
                    }
                }
            }
        }
        .padding(12)
        .background(AppColor.mainColor.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    var filterChips: some View {
        if selectedDistrict != "Tümü" {
            FilterChipView(text: selectedDistrict, icon: "map.fill") {
                selectedDistrict = "Tümü"
            }
        }
        
        if selectedCategory != "Tümü" {
            FilterChipView(text: selectedCategory, icon: "fork.knife") {
                selectedCategory = "Tümü"
            }
        }
        
        ForEach(Array(selectedFeatures), id: \.self) { feature in
            FilterChipView(text: feature, icon: "star.fill") {
                selectedFeatures.remove(feature)
            }
        }
    }
}

private extension SearchView {
    var searchBarWithFilter: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Mekan ara...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isSearchFieldFocused)
                    .submitLabel(.done)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            Button(action: {
                showFilterSheet = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.title2)
                        .foregroundColor(activeFilterCount > 0 ? AppColor.mainColor : .gray)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    if activeFilterCount > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 18, height: 18)
                            Text("\(activeFilterCount)")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                        .offset(x: 4, y: -4)
                    }
                }
            }

            if isSearchFieldFocused {
                Button("İptal") {
                    withAnimation {
                        searchText = ""
                        isSearchFieldFocused = false
                    }
                }
                .tint(AppColor.mainColor)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding()
        .animation(.easeInOut, value: isSearchFieldFocused)
    }
}

private extension SearchView {
    var popularSearchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popüler Aramalar")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .padding(.top, 8)

            if #available(iOS 16.0, *) {
                FlowLayout(spacing: 10) {
                    ForEach(popularSearches, id: \.0) { search in
                        searchTag(search.1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(popularSearches, id: \.0) { search in
                            searchTag(search.1)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    func searchTag(_ featureName: String) -> some View {
        Button(action: {
            selectedFeatures.insert(featureName)
            performSearch()
        }) {
            Text("#\(featureName)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColor.mainColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppColor.mainColor.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension SearchView {
    var searchResultsList: some View {
        VStack(spacing: 12) {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if filteredResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Sonuç bulunamadı")
                        .font(.headline)
                        .foregroundColor(.gray)
                    if activeFilterCount > 0 {
                        Text("Filtrelerinizi değiştirmeyi deneyin")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                HStack {
                    Text("\(filteredResults.count) mekan bulundu")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                
                LazyVStack(spacing: 12) {
                    ForEach(filteredResults) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            SearchResultCard(restaurant: restaurant)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: searchText) { newValue in
            performSearch()
        }
    }
}

struct FilterChipView: View {
    let text: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.mainColor, lineWidth: 1)
        )
        .foregroundColor(AppColor.mainColor)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SearchResultCard: View {
    let restaurant: Restaurant
    
    var restaurantImage: some View {
        Group {
            if let imageUrlString = restaurant.imageURL,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    var ratingView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            Text(String(format: "%.1f", restaurant.rating ?? 0.0))
                .foregroundColor(.gray)
                .font(.subheadline)
            Text("•")
                .foregroundColor(.gray)
            Text(restaurant.district ?? "")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }
    
    @ViewBuilder
    var featuresView: some View {
        if let features = restaurant.features, !features.isEmpty {
            let featureArray = Array(features.prefix(2))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(featureArray, id: \.self) { feature in
                        featureBadge(feature)
                    }
                }
            }
        }
    }
    
    func featureBadge(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(AppColor.mainColor.opacity(0.1))
            .foregroundColor(AppColor.mainColor)
            .cornerRadius(4)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            restaurantImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name ?? "Bilinmeyen Mekan")
                    .font(.headline)
                    .foregroundColor(.black)
                
                ratingView
                featuresView
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDistrict: String
    @Binding var selectedCategory: String
    @Binding var selectedFeatures: Set<String>
    var onApply: () -> Void
    
    @State private var isDistrictExpanded = false
    @State private var isCategoryExpanded = false
    @State private var isFeaturesExpanded = false
    
    let istanbulDistricts: [String] = [
        "Tümü","Adalar","Arnavutköy","Ataşehir","Avcılar","Bağcılar","Bahçelievler","Bakırköy","Başakşehir","Bayrampaşa","Beşiktaş","Beykoz","Beylikdüzü","Beyoğlu","Büyükçekmece","Çatalca","Çekmeköy","Esenler","Esenyurt","Eyüpsultan","Fatih","Gaziosmanpaşa","Güngören","Kadıköy","Kağıthane","Kartal","Küçükçekmece","Maltepe","Pendik","Sancaktepe","Sarıyer","Şile","Şişli","Silivri","Sultanbeyli","Sultangazi","Tuzla","Ümraniye","Üsküdar","Zeytinburnu"
    ]
    
    let categories: [String] = [
        "Tümü", "Restoran", "Kafe", "Bar", "Fast Food", "Pastane", "Kahvaltı", "Deniz Ürünleri", "Et Lokantası", "Vejetaryen"
    ]
    
    let features: [String] = [
        "Randevuluk", "Toplantılık", "Deniz Manzaralı", "Aile Mekanı", "Canlı Müzik", "Açık Alan", "WiFi", "Romantik", "Sessiz Ortam", "Pet-Friendly", "Ders Çalışma", "Fotoğraf Çekilmelik"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            withAnimation {
                                isDistrictExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundColor(AppColor.mainColor)
                                Text("İlçe")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: isDistrictExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if isDistrictExpanded {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 100), spacing: 10)
                            ], spacing: 10) {
                                ForEach(istanbulDistricts, id: \.self) { district in
                                    Button(action: {
                                        selectedDistrict = district
                                    }) {
                                        Text(district)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedDistrict == district ? AppColor.mainColor.opacity(0.15) : Color.white)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedDistrict == district ? AppColor.mainColor : Color.gray.opacity(0.3), lineWidth: 1.5)
                                            )
                                            .foregroundColor(selectedDistrict == district ? AppColor.mainColor : .black)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            withAnimation {
                                isCategoryExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(AppColor.mainColor)
                                Text("Kategori")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if isCategoryExpanded {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 120), spacing: 10)
                            ], spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedCategory == category ? AppColor.mainColor.opacity(0.15) : Color.white)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedCategory == category ? AppColor.mainColor : Color.gray.opacity(0.3), lineWidth: 1.5)
                                            )
                                            .foregroundColor(selectedCategory == category ? AppColor.mainColor : .black)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            withAnimation {
                                isFeaturesExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppColor.mainColor)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Özellikler")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("(Çoklu seçim yapabilirsiniz)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: isFeaturesExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if isFeaturesExpanded {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 140), spacing: 10)
                            ], spacing: 10) {
                                ForEach(features, id: \.self) { feature in
                                    Button(action: {
                                        if selectedFeatures.contains(feature) {
                                            selectedFeatures.remove(feature)
                                        } else {
                                            selectedFeatures.insert(feature)
                                        }
                                    }) {
                                        HStack {
                                            Text(feature)
                                                .font(.subheadline)
                                            if selectedFeatures.contains(feature) {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedFeatures.contains(feature) ? AppColor.mainColor.opacity(0.15) : Color.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedFeatures.contains(feature) ? AppColor.mainColor : Color.gray.opacity(0.3), lineWidth: 1.5)
                                        )
                                        .foregroundColor(selectedFeatures.contains(feature) ? AppColor.mainColor : .black)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sıfırla") {
                        selectedDistrict = "Tümü"
                        selectedCategory = "Tümü"
                        selectedFeatures.removeAll()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        onApply()
                        dismiss()
                    }
                    .foregroundColor(.black)
                    .bold()
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    SearchView()
}
