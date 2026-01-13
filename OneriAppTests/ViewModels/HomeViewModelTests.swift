//
//  HomeViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 31.12.2025.
//


import XCTest
@testable import OneriApp

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var viewModel: HomeViewModel!
    private var repository: OneriAppRepositoryProtocol!
    private var authService: MockAuthServiceSuccess!

    override func setUp() {
        super.setUp()
        repository = MockRepositorySuccess()
        authService = MockAuthServiceSuccess()
        viewModel = HomeViewModel(
            repository: repository,
            authService: authService
        )
    }

    override func tearDown() {
        viewModel = nil
        repository = nil
        authService = nil
        super.tearDown()
    }

    func test_loadRestaurants_success() async {
        await viewModel.loadRestaurants()

        XCTAssertEqual(viewModel.restaurants.count, 1)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_loadRestaurants_failure_setsErrorMessage() async {
        repository = MockRepositoryFailure()
        viewModel = HomeViewModel(
            repository: repository,
            authService: authService
        )

        await viewModel.loadRestaurants()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.restaurants.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_recommendedRestaurants_sortedByRatingDescending() {
        viewModel.restaurants = [
            Restaurant(id: "1", name: "A", district: "Kadıköy", rating: 3.0, popularityScore: 10),
            Restaurant(id: "2", name: "B", district: "Kadıköy", rating: 5.0, popularityScore: 20)
        ]

        let result = viewModel.recommendedRestaurants
        XCTAssertEqual(result.first?.id, "2")
    }
}
