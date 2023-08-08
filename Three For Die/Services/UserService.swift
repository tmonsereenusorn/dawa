//
//  UserService.swift
//  Three For Die
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
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        self.currentUser = try snapshot.data(as: User.self)
    }
    
    static func fetchUser(uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else {
                print("DEBUG: Failed to map user")
                return
            }
            completion(user)
        }
    }
    
    @MainActor
    func editUser(withUid uid: String, username: String, bio: String, uiImage: UIImage?, completion: @escaping(User) -> Void) async throws {
        do {
            guard uid == Auth.auth().currentUser?.uid else { return } // Only current user can edit their information
            
            guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
            guard let oldUserProfile = try? snapshot.data(as: User.self) else { return }
            
            
            var newUserProfile = User(fullname: oldUserProfile.fullname,
                                      email: oldUserProfile.email,
                                      username: username,
                                      bio: bio,
                                      profileImageUrl: oldUserProfile.profileImageUrl)
            
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
            try await Firestore.firestore().collection("users").document(uid).setData(encodedUser)
            completion(newUserProfile)
        } catch {
            print("DEBUG: Failed to edit user with error \(error.localizedDescription)")
        }
    }
}
