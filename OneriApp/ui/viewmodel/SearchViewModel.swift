//
//  SearchViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 8.11.2025.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    private let repository = OneriAppRepository()
    
    @Published var searchResults: [Restaurant] = []
    @Published var isLoading = false
    
    func search(searchText: String) async {
        isLoading = true
        do {
            searchResults = try await repository.search(searchText: searchText)
        } catch {
            searchResults = []
            print("Arama hatası: \(error)")
        }
        isLoading = false
    }
    
}
