//
//  SignInViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 13.01.2026.
//

import XCTest
@testable import OneriApp
import Combine

@MainActor
final class SignInViewModelTests: XCTestCase {

    private var viewModel: SignInViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        super.tearDown()
    }
    
    func test_signIn_success_returnsTrue_andErrorMessageIsNil() async {
        // GIVEN
        viewModel = SignInViewModel(
            authService: MockAuthServiceSuccess()
        )

        // WHEN
        let result = await viewModel.signIn(
            email: "test@mail.com",
            password: "123456"
        )

        // THEN
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_signIn_failure_setsErrorMessage_andReturnsFalse() async {
        // GIVEN
        viewModel = SignInViewModel(
            authService: MockAuthServiceFailure()
        )

        let expectation = XCTestExpectation(description: "Error message published")

        viewModel.$errorMessage
            .dropFirst() // initial nil'i atla
            .sink { value in
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "Invalid credentials")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // WHEN
        let result = await viewModel.signIn(
            email: "wrong@mail.com",
            password: "wrongpass"
        )

        // THEN
        XCTAssertFalse(result)
        await fulfillment(of: [expectation], timeout: 1)
    }

}
