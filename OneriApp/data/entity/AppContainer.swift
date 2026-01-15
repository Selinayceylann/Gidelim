//
//  AppContainer.swift
//  OneriApp
//
//  Created by selinay ceylan on 11.01.2026.
//

import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let repository: OneriAppRepositoryProtocol
    let authService: AuthServiceProtocol

    init(
        repository: OneriAppRepositoryProtocol,
        authService: AuthServiceProtocol
    ) {
        self.repository = repository
        self.authService = authService
    }
}

@MainActor
extension AppContainer {

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            repository: repository,
            authService: authService
        )
    }

    func makeRestaurantDetailViewModel() -> RestaurantDetailViewModel {
        RestaurantDetailViewModel(
            repository: repository,
            authService: authService
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
            SearchViewModel(repository: repository)
        }
}
