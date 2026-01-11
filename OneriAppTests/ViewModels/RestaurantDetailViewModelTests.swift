//
//  RestaurantDetailViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 11.01.2026.
//

import XCTest
@testable import OneriApp

@MainActor
final class RestaurantDetailViewModelTests: XCTestCase {

    private var viewModel: RestaurantDetailViewModel!
    private var repository: OneriAppRepositoryProtocol!
    private var authService: MockAuthService!

    override func setUp() {
        super.setUp()
        repository = MockRepositorySuccess()
        authService = MockAuthService()
        viewModel = RestaurantDetailViewModel(
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

    func test_loadRestaurants_success_setsRestaurants() async {
        await viewModel.loadRestaurants()

        XCTAssertEqual(viewModel.restaurants.count, 1)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_loadRestaurants_failure_setsErrorMessage() async {
        repository = MockRepositoryFailure()
        viewModel = RestaurantDetailViewModel(
            repository: repository,
            authService: authService
        )

        await viewModel.loadRestaurants()

        XCTAssertTrue(viewModel.restaurants.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func test_getCurrentUser_whenUserExists_setsCurrentUser() async {
        authService.currentUser = AuthUser(uid: "123", email: "test@mail.com")

        await viewModel.getCurrentUser()

        XCTAssertEqual(viewModel.currentUser?.id, "123")
    }

    func test_getCurrentUser_whenNoUser_setsNil() async {
        authService.currentUser = nil

        await viewModel.getCurrentUser()

        XCTAssertNil(viewModel.currentUser)
    }

    func test_togglePlannedPlace_withoutUser_setsErrorMessage() async {
        await viewModel.togglePlannedPlace(restaurantId: "1")

        XCTAssertEqual(viewModel.errorMessage, "Lütfen giriş yapın")
    }

    func test_togglePlannedPlace_success_doesNotSetError() async {
        authService.currentUser = AuthUser(uid: "123", email: "test@mail.com")
        await viewModel.getCurrentUser()

        await viewModel.togglePlannedPlace(restaurantId: "1")

        XCTAssertNil(viewModel.errorMessage)
    }
}
