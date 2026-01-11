//
//  RestaurantClass.swift
//  OneriApp
//
//  Created by selinay ceylan on 14.10.2025.
//

import Foundation
import FirebaseFirestore

struct Restaurant: Identifiable, Codable {
    var id: String?
    var name: String?
    var district: String?
    var fullAddress: String?
    var phoneNumber: String?
    var openingHours: String?
    var description: String?
    var imageURL: String?
    var category: String?
    var rating: Double?
    var reviews: [Review]?
    var popularityScore: Int?
    var hasWifi: Bool?
    var acceptsCreditCard: Bool?
    var hasValetParking: Bool?
    var hasKidsMenu: Bool?
    var smokingAllowed: Bool?
    var petFriendly: Bool?
    var liveMusic: Bool?
    var sportsBroadcast: Bool?
    var hasAirConditioning: Bool?
    var wheelchairAccessible: Bool?
    var latitude: Double?
    var longitude: Double?
    var features: [String]?
    var menu: [Menu]?
    
    init(id: String? = nil, name: String? = nil, district: String? = nil, fullAddress: String? = nil, phoneNumber: String? = nil, openingHours: String? = nil, description: String? = nil, imageURL: String? = nil, category: String? = nil, rating: Double? = nil, reviews: [Review]? = nil, popularityScore: Int? = nil, hasWifi: Bool? = nil, acceptsCreditCard: Bool? = nil, hasValetParking: Bool? = nil, hasKidsMenu: Bool? = nil, smokingAllowed: Bool? = nil, petFriendly: Bool? = nil, liveMusic: Bool? = nil, sportsBroadcast: Bool? = nil, hasAirConditioning: Bool? = nil, wheelchairAccessible: Bool? = nil, latitude: Double? = nil, longitude: Double? = nil, features: [String]? = nil, menu: [Menu]? = nil) {
        self.id = id
        self.name = name
        self.district = district
        self.fullAddress = fullAddress
        self.phoneNumber = phoneNumber
        self.openingHours = openingHours
        self.description = description
        self.imageURL = imageURL
        self.category = category
        self.rating = rating
        self.reviews = reviews
        self.popularityScore = popularityScore
        self.hasWifi = hasWifi
        self.acceptsCreditCard = acceptsCreditCard
        self.hasValetParking = hasValetParking
        self.hasKidsMenu = hasKidsMenu
        self.smokingAllowed = smokingAllowed
        self.petFriendly = petFriendly
        self.liveMusic = liveMusic
        self.sportsBroadcast = sportsBroadcast
        self.hasAirConditioning = hasAirConditioning
        self.wheelchairAccessible = wheelchairAccessible
        self.latitude = latitude
        self.longitude = longitude
        self.features = features
        self.menu = menu
    }
    
    init() {
        
    }

}

extension Restaurant {
    init(data: [String: Any], id: String) {
        self.id = id
        self.name = data["name"] as? String
        self.district = data["district"] as? String
        self.fullAddress = data["fullAddress"] as? String
        self.phoneNumber = data["phoneNumber"] as? String
        self.openingHours = data["openingHours"] as? String
        self.description = data["description"] as? String
        self.imageURL = data["imageURL"] as? String
        self.category = data["category"] as? String
        self.rating = data["rating"] as? Double
        self.popularityScore = data["popularityScore"] as? Int
        self.hasWifi = data["hasWifi"] as? Bool
        self.acceptsCreditCard = data["acceptsCreditCard"] as? Bool
        self.hasValetParking = data["hasValetParking"] as? Bool
        self.hasKidsMenu = data["hasKidsMenu"] as? Bool
        self.smokingAllowed = data["smokingAllowed"] as? Bool
        self.petFriendly = data["petFriendly"] as? Bool
        self.liveMusic = data["liveMusic"] as? Bool
        self.sportsBroadcast = data["sportsBroadcast"] as? Bool
        self.hasAirConditioning = data["hasAirConditioning"] as? Bool
        self.wheelchairAccessible = data["wheelchairAccessible"] as? Bool
        self.latitude = data["latitude"] as? Double
        self.longitude = data["longitude"] as? Double
        self.features = data["features"] as? [String]
        self.menu = []

        if let reviewsArray = data["reviews"] as? [[String: Any]] {
            self.reviews = reviewsArray.map { reviewData in
                Review(
                    id: reviewData["id"] as? String,
                    userName: reviewData["userName"] as? String ?? "",
                    comment: reviewData["comment"] as? String ?? "",
                    rating: reviewData["rating"] as? Double ?? 0.0,
                    date: (reviewData["date"] as? Timestamp)?.dateValue() ?? Date(),
                    restaurantId: reviewData["restaurantId"] as? String,
                    restaurantName: reviewData["restaurantName"] as? String
                )
            }
        } else {
            self.reviews = []
        }
    }
}
