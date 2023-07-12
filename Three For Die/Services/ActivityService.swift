//
//  ActivityService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase

struct ActivityService {
    
    func uploadActivity(title: String, location: String, notes: String, numRequired: Int, category: String) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let activity = Activity(userId: uid,
                                    title: title,
                                    notes: notes,
                                    location: location,
                                    numRequired: numRequired,
                                    category: category,
                                    timestamp: Timestamp(date: Date()),
                                    numCurrent: 0)
            let encodedActivity = try Firestore.Encoder().encode(activity)
            let _ = try await Firestore.firestore().collection("activities").addDocument(data: encodedActivity)
        } catch {
            print("DEBUG: Failed to upload activity with error \(error.localizedDescription)")
        }
    }
    
    func fetchActivities(completion: @escaping([Activity]) -> Void) async {
        
        guard let snapshot = try? await Firestore.firestore().collection("activities").getDocuments() else { return }
        var activities: [Activity] = []
        for document in snapshot.documents {
            guard let activity = try? document.data(as: Activity.self) else { return }
            activities.append(activity)
        }
        completion(activities)
    }
}
