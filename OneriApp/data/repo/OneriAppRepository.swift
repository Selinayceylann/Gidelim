//
//  OneriAppRepository.swift
//  OneriApp
//
//  Created by selinay ceylan on 1.11.2025.
//

import Foundation
import FirebaseFirestore

class OneriAppRepository : OneriAppRepositoryProtocol {
    private let db = Firestore.firestore()
    
    
    func togglePlannedPlace(userId: String, restaurantId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { transaction, errorPointer in
            let userDocument: DocumentSnapshot
            do {
                userDocument = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var plannedPlaces = userDocument.data()?["plannedPlaces"] as? [String] ?? []
            
            if let index = plannedPlaces.firstIndex(of: restaurantId) {
                plannedPlaces.remove(at: index)
                print("🗑️ Restaurant removed from plannedPlaces")
            } else {
                plannedPlaces.append(restaurantId)
                print("➕ Restaurant added to plannedPlaces")
            }
            
            transaction.updateData(["plannedPlaces": plannedPlaces], forDocument: userRef)
            
            return nil
        }
    }
    func loadUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard document.exists, let data = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        var comments: [Review] = []
        if let commentsArray = data["comments"] as? [[String: Any]] {
            for commentData in commentsArray {
                let review = Review(
                    id: commentData["id"] as? String,
                    userName: commentData["userName"] as? String ?? "",
                    comment: commentData["comment"] as? String ?? "",
                    rating: commentData["rating"] as? Double ?? 0.0,
                    date: (commentData["date"] as? Timestamp)?.dateValue() ?? Date(),
                    restaurantId: commentData["restaurantId"] as? String,
                    restaurantName: commentData["restaurantName"] as? String
                )
                comments.append(review)
            }
        }
        
        let plannedPlaces = data["plannedPlaces"] as? [String] ?? []
        let historySearch = data["historySearch"] as? [String] ?? []
        
        let user = User(
            id: userId,
            firstName: data["firstName"] as? String ?? "",
            lastName: data["lastName"] as? String ?? "",
            email: data["email"] as? String ?? "",
            comments: comments,
            plannedPlaces: plannedPlaces,
            historySearch: historySearch
        )
        
        return user
    }
    
    func addComment(userId: String, review: Review) async throws {
        let userRef = db.collection("users").document(userId)
        
        let commentData: [String: Any] = [
            "id": review.id ?? UUID().uuidString,
            "userName": review.userName,
            "comment": review.comment,
            "rating": review.rating,
            "date": Timestamp(date: review.date ?? Date()),
            "restaurantId": review.restaurantId ?? "",
            "restaurantName": review.restaurantName ?? ""
        ]
        
        try await userRef.updateData([
            "comments": FieldValue.arrayUnion([commentData])
        ])
    }
    
    func deleteComment(userId: String, commentId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let document = try await userRef.getDocument()
        guard var comments = document.data()?["comments"] as? [[String: Any]] else { return }
        
        comments.removeAll { ($0["id"] as? String) == commentId }
        try await userRef.updateData(["comments": comments])
    }
    


    func getFavoriteRestaurants(userId: String, favoriteIds: [String]) async throws -> [Restaurant] {
        let allRestaurants = try await loadRestaurants()
        return allRestaurants.filter { favoriteIds.contains($0.id ?? "") }
    }
    
    func saveUserToFirestore(user: User) async throws {
        guard let userId = user.id else {
            throw URLError(.badURL)
        }
        try await db.collection("users").document(userId).setData([
            "id": user.id ?? "", "firstName": user.firstName ?? "", "lastName": user.lastName ?? "", "email": user.email, "comments": [], "plannedPlaces": [], "historySearch": []
        ])
    }
    func saveUser(_ user: User) async -> Bool {
            do {
                // Firestore kayıt işlemi
                try await saveUserToFirestore(user: user)
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        }
    
    func search(searchText: String) async throws -> [Restaurant] {
        let allRestaurants = try await loadRestaurants()
        if searchText.isEmpty {
            return allRestaurants
        }
        return allRestaurants.filter { restaurant in
            let nameMatch = restaurant.name?.lowercased().contains(searchText.lowercased()) ?? false
            
            let featuresMatch = restaurant.features?.contains(where: { feature in
                feature.lowercased().contains(searchText.lowercased())
            }) ?? false
            
            return nameMatch || featuresMatch
        }
    }
    

    func loadRestaurants() async throws -> [Restaurant] {
        let snapshot = try await db.collection("restaurants").getDocuments()
        return snapshot.documents.map { Restaurant(data: $0.data(), id: $0.documentID) }
    }

}
