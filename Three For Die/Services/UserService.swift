//
//  UserService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/6/23.
//

import Firebase
import FirebaseFirestoreSwift


struct UserService {
    
    @MainActor
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) async {
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        guard let user = try? snapshot.data(as: User.self) else { return }
        completion(user)
    }
    
    @MainActor
    func signIn(withEmail email: String, password: String, completion: @escaping(FirebaseAuth.User) -> Void) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            completion(result.user)
        } catch {
            print("DEBUG: Failed to log in user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping(FirebaseAuth.User) -> Void) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(fullname: fullname,
                            email: email,
                            username: username,
                            bio: "",
                            profileImageUrl: nil)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            completion(result.user)
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func editUser(withUid uid: String, username: String, bio: String, completion: @escaping() -> Void) async throws {
        do {
            guard uid == Auth.auth().currentUser?.uid else { return } // Only current user can edit their information
            guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
            guard let oldUserProfile = try? snapshot.data(as: User.self) else { return }
            
            let newUserProfile = User(fullname: oldUserProfile.fullname,
                                      email: oldUserProfile.email,
                                      username: username,
                                      bio: bio)
            let encodedUser = try Firestore.Encoder().encode(newUserProfile)
            try await Firestore.firestore().collection("users").document(uid).setData(encodedUser)
            completion()
        } catch {
            print("DEBUG: Failed to edit user with error \(error.localizedDescription)")
        }
    }
}
