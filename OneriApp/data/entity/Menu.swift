//
//  MenuClass.swift
//  OneriApp
//
//  Created by selinay ceylan on 18.10.2025.
//

import Foundation

struct Menu : Identifiable, Codable {
        var id: String?
        var name: String?
        var category: String?
        var image: String?
    
    init(id: String? = nil, name: String? = nil, category: String? = nil, image: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.image = image
    }
    
    init() {
        
    }
}
