//
//  UserClass.swift
//  OneriApp
//
//  Created by selinay ceylan on 3.11.2025.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String? 
    var firstName: String?
    var lastName: String?
    var email: String
    var comments: [Review]?
    var plannedPlaces: [String]?
    var historySearch: [String]?
    
    init(id: String? = nil, firstName: String? = nil, lastName: String? = nil, email: String, comments: [Review]? = nil, plannedPlaces: [String]? = nil, historySearch: [String]? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.comments = comments
        self.plannedPlaces = plannedPlaces
        self.historySearch = historySearch
    }
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email, comments, plannedPlaces, historySearch
    }
}
