//
//  ActivityService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase

struct ActivityService {
    
    func uploadActivity(title: String, location: String, notes: String, numRequired: String, category: String) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let activity = Activity(userId: uid, title: title, notes: notes, location: location, numRequired: numRequired, category: category, numCurrent: "0")
            let encodedActivity = try Firestore.Encoder().encode(activity)
            let _ = try await Firestore.firestore().collection("activities").addDocument(data: encodedActivity)
        } catch {
            print("DEBUG: Failed to upload activity with error \(error.localizedDescription)")
        }
    }
}
