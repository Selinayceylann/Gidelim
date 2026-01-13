//
//  SignUpViewModelTests.swift
//  OneriAppTests
//
//  Created by selinay ceylan on 13.01.2026.
//

import XCTest
@testable import OneriApp

@MainActor
final class SignUpViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var viewModel: SignUpViewModel!
    
    // MARK: - SignUp Success
    func test_signUp_success_returnsUser_andStopsLoading() async {
        // GIVEN
        let mockAuth = MockAuthServiceSuccess()
        let mockRepo = MockRepositorySuccess()
        
        viewModel = SignUpViewModel(
            authRepository: mockAuth,
            repository: mockRepo
        )
        
        // WHEN
        let user = await viewModel.signUp(
            email: "test@mail.com",
            password: "123456"
        )
        
        // THEN
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.uid, "mock-uid")
        XCTAssertEqual(mockAuth.currentUser?.email, "test@mail.com")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_signUp_failure_setsErrorMessage() async {
        // GIVEN
        viewModel = SignUpViewModel(
            authRepository: MockAuthServiceFailure(),
            repository: MockRepositorySuccess()
        )
        
        // WHEN
        let user = await viewModel.signUp(
            email: "fail@mail.com",
            password: "123456"
        )
        
        // THEN
        XCTAssertNil(user)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_saveUserToFirestore_success_returnsTrue() async {
        // GIVEN
        viewModel = SignUpViewModel(
            authRepository: MockAuthServiceSuccess(),
            repository: MockRepositorySuccess()
        )

        let user = User(
            id: "mock-uid",
            firstName: "Test",
            lastName: "User",
            email: "test@mail.com",
            comments: [],
            plannedPlaces: [],
            historySearch: []
        )

        // WHEN
        let result = await viewModel.saveUserToFirestore(user: user)

        // THEN
        XCTAssertTrue(result)
    }
    
    func test_saveUserToFirestore_failure_returnsFalse() async {
        // GIVEN
        viewModel = SignUpViewModel(
            authRepository: MockAuthServiceSuccess(),
            repository: MockRepositoryFailure()
        )

        let user = User(
            id: "mock-uid",
            firstName: "Test",
            lastName: "User",
            email: "test@mail.com",
            comments: [],
            plannedPlaces: [],
            historySearch: []
        )

        // WHEN
        let result = await viewModel.saveUserToFirestore(user: user)

        // THEN
        XCTAssertFalse(result)
    }
    
    func test_signUp_loadingState_changesCorrectly() async {
        // GIVEN
        let mockAuth = MockAuthServiceSuccess()
        let mockRepo = MockRepositorySuccess()

        viewModel = SignUpViewModel(
            authRepository: mockAuth,
            repository: mockRepo
        )

        var loadingStates: [Bool] = []
        let expectation = XCTestExpectation(description: "Loading states captured")

        let cancellable = viewModel.$isLoading
            .dropFirst() // initial false'u at
            .sink { value in
                loadingStates.append(value)
                if loadingStates.count == 2 {
                    expectation.fulfill()
                }
            }

        // WHEN
        await viewModel.signUp(
            email: "test@mail.com",
            password: "123456"
        )

        // THEN
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(loadingStates, [true, false])

        cancellable.cancel()
    }

    func test_signUp_failure_publishesErrorMessage() async {
        // GIVEN
        viewModel = SignUpViewModel(
            authRepository: MockAuthServiceFailure(),
            repository: MockRepositorySuccess()
        )

        let expectation = XCTestExpectation(description: "Error message published")

        let cancellable = viewModel.$errorMessage
            .compactMap { $0 }               // 👈 KRİTİK SATIR
            .receive(on: DispatchQueue.main)
            .sink { value in
                XCTAssertFalse(value.isEmpty)
                expectation.fulfill()
            }

        // WHEN
        _ = await viewModel.signUp(
            email: "fail@mail.com",
            password: "123456"
        )

        // THEN
        await fulfillment(of: [expectation], timeout: 1)
        cancellable.cancel()
    }



    func test_fullSignUpFlow_success() async {
        // GIVEN
        let mockAuth = MockAuthServiceSuccess()
        let mockRepo = MockRepositorySuccess()

        viewModel = SignUpViewModel(
            authRepository: mockAuth,
            repository: mockRepo
        )

        // WHEN
        let authUser = await viewModel.signUp(
            email: "test@mail.com",
            password: "123456"
        )

        let user = User(
            id: authUser!.uid,
            firstName: "Test",
            lastName: "User",
            email: "test@mail.com",
            comments: [],
            plannedPlaces: [],
            historySearch: []
        )

        let saveResult = await viewModel.saveUserToFirestore(user: user)

        // THEN
        XCTAssertNotNil(authUser)
        XCTAssertTrue(saveResult)
    }

}
