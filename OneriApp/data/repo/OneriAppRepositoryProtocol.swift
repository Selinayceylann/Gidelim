//
//  OneriAppRepositoryProtocol.swift
//  OneriApp
//
//  Created by selinay ceylan on 31.12.2025.
//

import Foundation
import SwiftUI

protocol OneriAppRepositoryProtocol {
    func loadUser(userId: String) async throws -> User
    func loadRestaurants() async throws -> [Restaurant]
    func togglePlannedPlace(userId: String, restaurantId: String) async throws
     func saveUser(_ user: User) async -> Bool
    func search(searchText: String) async throws -> [Restaurant]

}
