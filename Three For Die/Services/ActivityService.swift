//
//  ActivityService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase

class ActivityService {
    
    @MainActor
    func uploadActivity(groupId: String, title: String, location: String, notes: String, numRequired: Int, category: String) async throws {
        do {
            // Upload activity to firestore
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let activity = Activity(userId: uid,
                                    groupId: groupId,
                                    title: title,
                                    notes: notes,
                                    location: location,
                                    numRequired: numRequired + 1,
                                    category: category,
                                    timestamp: Timestamp(date: Date()),
                                    numCurrent: 1,
                                    status: "Open")
            let encodedActivity = try Firestore.Encoder().encode(activity)
            let activityRef = try await Firestore.firestore().collection("activities").addDocument(data: encodedActivity)
            
            // Add activity to user's activity list
            let activityId = activityRef.documentID
            let userActivitiesRef = Firestore.firestore().collection("users").document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).setData([:])
            
            // Add user to activity's participants list
            let activityParticipantsRef = Firestore.firestore().collection("activities").document(activityId).collection("participants")
            try await activityParticipantsRef.document(uid).setData([:])
            
        } catch {
            print("DEBUG: Failed to upload activity with error \(error.localizedDescription)")
        }
    }
    
    func closeActivity(activity: Activity) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard uid == activity.userId else { return } // Only host can close activity
            guard let activityId = activity.id else { return }
            try await Firestore.firestore().collection("activities").document(activityId).updateData(["status": "Closed"])
        } catch {
            print("DEBUG: Failed to close activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchActivities(groupId: String, completion: @escaping([Activity]) -> Void) async {
        guard let snapshot = try? await Firestore.firestore().collection("activities")
                                                            .whereField("status", isEqualTo: "Open")
                                                            .whereField("groupId", isEqualTo: groupId)
                                                            .order(by: "timestamp", descending: true)
                                                            .limit(to: 100)
                                                            .getDocuments() else { return }
        var activities: [Activity] = []
        for document in snapshot.documents {
            guard let activity = try? document.data(as: Activity.self) else { return }
            activities.append(activity)
        }
        completion(activities)
    }
    
    @MainActor
    static func fetchActivity(activity: Activity) async throws -> Activity? {
        do {
            guard let activityId = activity.id else { return nil }
            let snapshot = try await Firestore.firestore().collection("activities").document(activityId).getDocument()
            return try snapshot.data(as: Activity.self)
        } catch {
            print("DEBUG: Failed to fetch activity with error \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func joinActivity(activity: Activity, completion: @escaping() -> Void) async throws {
        do {
            guard activity.numCurrent < activity.numRequired else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard uid != activity.userId else { return } // Host of activity is already in activity
            guard let activityId = activity.id else { return }
            
            // Update activity by incrementing numCurrent
            try await Firestore.firestore().collection("activities").document(activityId).updateData(["numCurrent": activity.numCurrent + 1])
            
            // Update user's activities subcollection by adding activity ID to it
            let userActivitiesRef = Firestore.firestore().collection("users").document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).setData([:])
            
            // Update activity's participants subcollection by adding user ID to it
            let activityParticipantsRef = Firestore.firestore().collection("activities").document(activityId).collection("participants")
            try await activityParticipantsRef.document(uid).setData([:])
            
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
            guard uid != activity.userId else { return } // Host of activity cannot leave
            guard let activityId = activity.id else { return }
            
            // Update activity by decrementing numCurrent
            try await Firestore.firestore().collection("activities").document(activityId).updateData(["numCurrent": activity.numCurrent - 1])
            
            // Update user's activities subcollection by removing activity ID from it
            let userActivitiesRef = Firestore.firestore().collection("users").document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).delete()
            
            // Update activity's participants subcollection by removing user ID from it
            let activityParticipantsRef = Firestore.firestore().collection("activities").document(activityId).collection("participants")
            try await activityParticipantsRef.document(uid).delete()
            
            completion()
        } catch {
            print("DEBUG: Failed to leave activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchUserActivities(completion: @escaping([Activity]) -> Void) async {
        var activities: [Activity] = []
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userActivitiesSnapshot = try? await Firestore.firestore().collection("users").document(uid).collection("user-activities").getDocuments() else { return }
        for doc in userActivitiesSnapshot.documents {
            let activityId = doc.documentID
            guard let activitySnapshot = try? await Firestore.firestore().collection("activities").document(activityId).getDocument() else { return }
            guard let activity = try? activitySnapshot.data(as: Activity.self) else { return }
            activities.append(activity)
        }
        completion(activities)
    }
    
    @MainActor
    func fetchActivityParticipants(activity: Activity, completion: @escaping([User]) -> Void) async {
        var users: [User] = []
        
        guard let activityId = activity.id else { return }
        guard let activityParticipantsSnapshot = try? await Firestore.firestore().collection("activities").document(activityId).collection("participants").getDocuments() else { return }
        
        for doc in activityParticipantsSnapshot.documents {
            let uid = doc.documentID
            guard let userSnapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
            guard let user = try? userSnapshot.data(as: User.self) else { return }
            users.append(user)
        }
        completion(users)
    }
}
