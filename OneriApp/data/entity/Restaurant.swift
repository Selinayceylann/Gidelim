//
//  RestaurantClass.swift
//  OneriApp
//
//  Created by selinay ceylan on 14.10.2025.
//

import Foundation

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
    
    
    init(id: String, name: String, district: String, fullAddress: String, phoneNumber: String, openingHours: String, description: String, imageURL: String, category: String, rating: Double, reviews: [Review], popularityScore: Int, hasWifi: Bool, acceptsCreditCard: Bool, hasValetParking: Bool, hasKidsMenu: Bool, smokingAllowed: Bool, petFriendly: Bool, liveMusic: Bool, sportsBroadcast: Bool, hasAirConditioning: Bool, wheelchairAccessible: Bool, menu: [Menu], latitude: Double, longitude: Double, features: [String]) {
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
            self.menu = menu
            self.latitude = latitude
            self.longitude = longitude
            self.features = features
        }
    
    
    init() {
        
    }
}
