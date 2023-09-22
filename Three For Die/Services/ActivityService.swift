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
            let activityRef = try await FirestoreConstants.ActivitiesCollection.addDocument(data: encodedActivity)
            
            // Add activity to user's activity list
            let activityId = activityRef.documentID
            let userActivitiesRef = FirestoreConstants.UserCollection.document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).setData(["timestamp": Timestamp()])
            
            // Add user to activity's participants list
            let activityParticipantsRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants")
            try await activityParticipantsRef.document(uid).setData([:])
            
        } catch {
            print("DEBUG: Failed to upload activity with error \(error.localizedDescription)")
        }
    }
    
    static func closeActivity(activity: Activity) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard uid == activity.userId else { return } // Only host can close activity
            let activityId = activity.id
            try await FirestoreConstants.ActivitiesCollection.document(activityId).updateData(["status": "Closed"])
        } catch {
            print("DEBUG: Failed to close activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func fetchActivities(groupId: String) async throws -> [Activity] {
        let snapshot = try await FirestoreConstants.ActivitiesCollection
                                                            .whereField("status", isEqualTo: "Open")
                                                            .whereField("groupId", isEqualTo: groupId)
                                                            .order(by: "timestamp", descending: true)
                                                            .limit(to: 100)
                                                            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Activity.self)})
    }
    
    @MainActor
    static func fetchActivity(activityId: String) async throws -> Activity? {
        do {
            let snapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).getDocument()
            return try snapshot.data(as: Activity.self)
        } catch {
            print("DEBUG: Failed to fetch activity with error \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchActivity(withActivityId activityId: String, completion: @escaping(Activity) -> Void) {
        FirestoreConstants.ActivitiesCollection.document(activityId).getDocument() { snapshot, _ in
            guard let activity = try? snapshot?.data(as: Activity.self) else {
                print("DEBUG: Failed to map activity")
                return
            }
            completion(activity)
        }
    }
    
    @MainActor
    static func joinActivity(activityId: String, completion: @escaping() -> Void) async throws {
        do {
            guard var activity = try await ActivityService.fetchActivity(activityId: activityId) else { return }
            guard activity.numCurrent < activity.numRequired else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard uid != activity.userId else { return } // Host of activity is already in activity
            
            // Update activity by incrementing numCurrent
            activity.numCurrent += 1
            try await FirestoreConstants.ActivitiesCollection.document(activityId).updateData(["numCurrent": activity.numCurrent])
            
            // Update user's activities subcollection by adding activity ID to it
            let userActivitiesRef = FirestoreConstants.UserCollection.document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).setData(["timestamp": Timestamp()])
            
            // Update activity's participants subcollection by adding user ID to it
            let activityParticipantsRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants")
            try await activityParticipantsRef.document(uid).setData([:])
            
            completion()
        } catch {
            print("DEBUG: Failed to join activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func checkIfUserJoinedActivity(activityId: String) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        guard let snapshot = try? await FirestoreConstants.UserCollection.document(uid)
                                                      .collection("user-activities").document(activityId)
                                                      .getDocument() else { return false }
        
        return snapshot.exists
    }
    
    @MainActor
    static func leaveActivity(activity: Activity, completion: @escaping() -> Void) async throws {
        do {
            guard activity.numCurrent > 0 else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard uid != activity.userId else { return } // Host of activity cannot leave
            let activityId = activity.id
            
            // Update activity by decrementing numCurrent
            try await FirestoreConstants.ActivitiesCollection.document(activityId).updateData(["numCurrent": activity.numCurrent - 1])
            
            // Update user's activities subcollection by removing activity ID from it
            let userActivitiesRef = FirestoreConstants.UserCollection.document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).delete()
            
            // Update activity's participants subcollection by removing user ID from it
            let activityParticipantsRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants")
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
        guard let userActivitiesSnapshot = try? await FirestoreConstants.UserCollection.document(uid).collection("user-activities").getDocuments() else { return }
        for doc in userActivitiesSnapshot.documents {
            let activityId = doc.documentID
            guard let activitySnapshot = try? await FirestoreConstants.ActivitiesCollection.document(activityId).getDocument() else { return }
            guard let activity = try? activitySnapshot.data(as: Activity.self) else { return }
            activities.append(activity)
        }
        completion(activities)
    }
    
    @MainActor
    static func fetchActivityParticipants(activity: Activity, completion: @escaping([User]) -> Void) async {
        var users: [User] = []
        
        let activityId = activity.id
        guard let activityParticipantsSnapshot = try? await FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants").getDocuments() else { return }
        
        for doc in activityParticipantsSnapshot.documents {
            let uid = doc.documentID
            guard let userSnapshot = try? await FirestoreConstants.UserCollection.document(uid).getDocument() else { return }
            guard let user = try? userSnapshot.data(as: User.self) else { return }
            users.append(user)
        }
        completion(users)
    }
}
