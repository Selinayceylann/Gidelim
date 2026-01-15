//
//  SearchViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 15.01.2026.
//

import Foundation
import XCTest
@testable import OneriApp

@MainActor
final class SearchViewModelTests: XCTestCase {

    func test_search_success_setsResultsAndStopsLoading() async {
        // GIVEN
        let repository = MockRepositorySuccess()
        let viewModel = SearchViewModel(repository: repository)
        
        // WHEN
        await viewModel.search(searchText: "kafe")
        
        // THEN
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.name, "Test Mekan")
    }
    
    func test_search_failure_clearsResultsAndStopsLoading() async {
        // GIVEN
        let repository = MockRepositoryFailure()
        let viewModel = SearchViewModel(repository: repository)
        
        // WHEN
        await viewModel.search(searchText: "kafe")
        
        // THEN
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
    
    func test_search_setsLoadingTrueWhileSearching() async {
        // GIVEN
        let repository = MockRepositorySuccess()
        let viewModel = SearchViewModel(repository: repository)
        
        // WHEN
        let task = Task {
            await viewModel.search(searchText: "test")
        }
        
        // THEN
        XCTAssertTrue(viewModel.isLoading)
        
        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }

}
