//
//  MapViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 14.01.2026.
//

import XCTest
@testable import OneriApp
import CoreLocation

@MainActor
final class MapViewModelTests: XCTestCase {

    private var viewModel: MapViewModel!

    // MARK: - SUCCESS CASE
    func test_loadRestaurants_success_setsRestaurants() async {
        // GIVEN
        let repository = MockRepositorySuccess()
        viewModel = MapViewModel(repository: repository)

        // WHEN
        await viewModel.loadRestaurants()

        // THEN
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.restaurants.count, 1)
        XCTAssertEqual(viewModel.restaurants.first?.name, "Mock Restoran")
    }

    // MARK: - FAILURE CASE
    func test_loadRestaurants_failure_setsErrorMessage() async {
        // GIVEN
        let repository = MockRepositoryFailure()
        viewModel = MapViewModel(repository: repository)

        // WHEN
        await viewModel.loadRestaurants()

        // THEN
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.restaurants.isEmpty)
    }
    
    func test_nearbyRestaurants_returnsOnlyNearbyOnes() {
        // GIVEN
        let viewModel = MapViewModel(repository: MockRepositorySuccess())

        let userLocation = CLLocation(latitude: 41.0605, longitude: 28.9872)

        let nearby = Restaurant(
            id: "1",
            name: "Yakın",
            district: "",
            latitude: 41.0606,
            longitude: 28.9873
        )

        let far = Restaurant(
            id: "2",
            name: "Uzak",
            district: "",
            latitude: 41.20,
            longitude: 29.20
        )

        viewModel.restaurants = [nearby, far]

        // WHEN
        let result = viewModel.nearbyRestaurants(userLocation: userLocation)

        // THEN
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Yakın")
    }

    
    func test_loadRestaurants_setsLoadingStateCorrectly() async {
        // GIVEN
        let repository = MockRepositoryDelayed()
        viewModel = MapViewModel(repository: repository)

        // WHEN
        let task = Task {
            await viewModel.loadRestaurants()
        }

        // küçük bir yield
        await Task.yield()

        // THEN
        XCTAssertTrue(viewModel.isLoading)

        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }

}
