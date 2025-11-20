//
//  ReviewClass.swift
//  OneriApp
//
//  Created by selinay ceylan on 14.10.2025.
//

import Foundation

struct Review: Identifiable, Codable {
    var id: String?
    var userName: String?
    var comment: String?
    var rating: Double?
    var date: Date?
    var restaurantId: String?
    var restaurantName: String?
    
    init(id: String?, userName: String?, comment: String?, rating: Double?, date: Date?, restaurantId: String? = nil, restaurantName: String? = nil) {
        self.id = id
        self.userName = userName
        self.comment = comment
        self.rating = rating
        self.date = date
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
    }
    
    init() {

    }
    
    enum CodingKeys: String, CodingKey {
        case id, userName, comment, rating, date, restaurantId, restaurantName
    }
}
