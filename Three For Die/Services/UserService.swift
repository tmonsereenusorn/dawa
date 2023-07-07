//
//  UserService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/6/23.
//

import Firebase
import FirebaseFirestoreSwift

@MainActor
struct UserService {
    
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) async {
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        guard let user = try? snapshot.data(as: User.self) else { return }
        print("fetched user data with username: \(user.username)")
        completion(user)
    }
}
