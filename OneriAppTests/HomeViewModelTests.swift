//
//  HomeViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 31.12.2025.
//

import Foundation
import XCTest
@testable import OneriApp

@MainActor
final class HomeViewModelTests: XCTestCase {

    func test_loadRestaurants_success() async {
        // GIVEN
        let viewModel = HomeViewModel(
                repository: MockRepositorySuccess(),
                authService: MockAuthService()
            )

        // WHEN
        await viewModel.loadRestaurants()

        // THEN
        XCTAssertEqual(viewModel.restaurants.count, 1)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_loadRestaurants_failure() async {
        let viewModel = HomeViewModel(
            repository: MockRepositoryFailure(),
            authService: MockAuthService()
        )
        
        await viewModel.loadRestaurants()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.restaurants.isEmpty)
    }



    
    func test_recommendedRestaurants_sortedByRating() {
        let viewModel = HomeViewModel(
                repository: MockRepositorySuccess(),
                authService: MockAuthService()
            )

        viewModel.restaurants = [
            Restaurant(id: "1", name: "A", district: "Kadıköy", rating: 3.0, popularityScore: 10),
            Restaurant(id: "2", name: "B", district: "Kadıköy", rating: 5.0, popularityScore: 20)
        ]

        let result = viewModel.recommendedRestaurants

        XCTAssertEqual(result.first?.name, "B")
    }

}
