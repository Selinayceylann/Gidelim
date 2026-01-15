//
//  SearchViewModel.swift
//  OneriApp
//
//  Created by selinay ceylan on 8.11.2025.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    private let repository: OneriAppRepositoryProtocol
    
    @Published var searchResults: [Restaurant] = []
    @Published var isLoading = false
    
    init(repository: OneriAppRepositoryProtocol) {
        self.repository = repository
    }
    
    func search(searchText: String) async {
        isLoading = true
        do {
            searchResults = try await repository.search(searchText: searchText)
        } catch {
            searchResults = []
        }
        isLoading = false
    }
}
