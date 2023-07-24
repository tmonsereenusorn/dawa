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
    
    @MainActor
    func fetchActivities(completion: @escaping([Activity]) -> Void) async {
        guard let snapshot = try? await Firestore.firestore().collection("activities").order(by: "timestamp", descending: true).getDocuments() else { return }
        var activities: [Activity] = []
        for document in snapshot.documents {
            guard let activity = try? document.data(as: Activity.self) else { return }
            activities.append(activity)
        }
        completion(activities)
    }
    
    @MainActor
    func joinActivity(activity: Activity, completion: @escaping() -> Void) async throws {
        do {
            guard activity.numCurrent < activity.numRequired else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let activityId = activity.id else { return }
            let userActivitiesRef = Firestore.firestore().collection("users").document(uid).collection("user-activities")
            
            try await Firestore.firestore().collection("activities").document(activityId).updateData(["numCurrent": activity.numCurrent + 1])
            try await userActivitiesRef.document(activityId).setData([:])
            completion()
        } catch {
            print("DEBUG: Failed to join activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func checkIfUserJoinedActivity(activity: Activity, completion: @escaping(Bool) -> Void) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let activityId = activity.id else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid)
                                                      .collection("user-activities").document(activityId)
                                                      .getDocument() else { return }
        
        completion(snapshot.exists)
    }
    
    @MainActor
    func leaveActivity(activity: Activity, completion: @escaping() -> Void) async throws {
        do {
            guard activity.numCurrent > 0 else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let activityId = activity.id else { return }
            let userActivitiesRef = Firestore.firestore().collection("users").document(uid).collection("user-activities")
            
            try await Firestore.firestore().collection("activities").document(activityId).updateData(["numCurrent": activity.numCurrent - 1])
            try await userActivitiesRef.document(activityId).delete()
            completion()
        } catch {
            print("DEBUG: Failed to join activity with error \(error.localizedDescription)")
        }
    }
}
