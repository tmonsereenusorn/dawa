//
//  UserService.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/6/23.
//

import Firebase
import FirebaseFirestoreSwift
import PhotosUI
import SwiftUI


class UserService {
    @Published var currentUser: User?
    static let shared = UserService()
    
    init() {
        Task { try await fetchCurrentUser() }
    }
    
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        self.currentUser = try snapshot.data(as: User.self)
    }
    
    static func fetchUser(uid: String) async throws -> User {
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        FirestoreConstants.UserCollection.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else {
                print("DEBUG: Failed to map user")
                return
            }
            completion(user)
        }
    }
    
    @MainActor
    static func searchForUsers(beginningWith startString: String) async throws -> [User] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        let query = FirestoreConstants.UserCollection
            .whereField("username", isGreaterThanOrEqualTo: startString)
            .whereField("username", isLessThan: startString + "\u{f8ff}")
            .limit(to: 100)
        
        let snapshot = try await query.getDocuments()
        return mapUsers(fromSnapshot: snapshot, currentUid: currentUid)
    }
    
    @MainActor
    func editUser(withUid uid: String, username: String, bio: String, uiImage: UIImage?) async throws {
        do {
            guard uid == Auth.auth().currentUser?.uid else { return } // Only current user can edit their information
            
            if username.count > ProfileConstants.maxUsernameLength { throw AppError.usernameTooLong }
            
            if username.count < ProfileConstants.minUsernameLength { throw AppError.usernameTooShort }
            
            if bio.count > ProfileConstants.maxBioLength { throw AppError.bioTooLong }
            
            guard let snapshot = try? await FirestoreConstants.UserCollection.document(uid).getDocument() else { return }
            guard let oldUserProfile = try? snapshot.data(as: User.self) else { return }
            
            // Check if the username already exists
            if username.lowercased() != oldUserProfile.username.lowercased() {
                let querySnapshot = try await FirestoreConstants.UserCollection
                    .whereField("username", isEqualTo: username.lowercased())
                    .getDocuments()

                if !querySnapshot.documents.isEmpty { throw AppError.usernameAlreadyExists }
            }

            var newUserProfile = User(
                email: oldUserProfile.email,
                username: username.lowercased(),
                bio: bio,
                profileImageUrl: oldUserProfile.profileImageUrl
            )

            // Upload new profile image if provided
            if let image = uiImage {
                if let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .profile) {
                    newUserProfile.profileImageUrl = imageUrl
                } else {
                    print("DEBUG: Failed to upload profile image")
                    return
                }
            }

            let encodedUser = try Firestore.Encoder().encode(newUserProfile)
            try await FirestoreConstants.UserCollection.document(uid).setData(encodedUser, merge: true)
            try await fetchCurrentUser()
        } catch {
            print("DEBUG: Failed to edit user with error \(error.localizedDescription)")
            throw error // Re-throw the error so it can be handled appropriately
        }
    }
    
    private static func mapUsers(fromSnapshot snapshot: QuerySnapshot, currentUid: String) -> [User] {
        return snapshot.documents
            .compactMap({ try? $0.data(as: User.self) })
            .filter({ $0.id !=  currentUid })
    }
}
