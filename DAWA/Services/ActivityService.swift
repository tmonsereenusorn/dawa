//
//  ActivityService.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase

class ActivityService {
    
    @MainActor
    func uploadActivity(groupId: String, title: String, location: String, notes: String, numRequired: Int, category: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Validation checks for title, location, and participants
        guard title.count >= ActivityConstants.minTitleLength else { throw AppError.titleTooShort }
        guard title.count <= ActivityConstants.maxTitleLength else { throw AppError.titleTooLong }
        guard location.count >= ActivityConstants.minLocationLength else { throw AppError.locationTooShort }
        guard location.count <= ActivityConstants.maxLocationLength else { throw AppError.locationTooLong }
        guard numRequired == -1 || numRequired >= ActivityConstants.minParticipants else { throw AppError.participantsTooFew }
        guard numRequired <= ActivityConstants.maxParticipants else { throw AppError.participantsTooMany }
        guard notes.count <= ActivityConstants.maxActivityDetails else { throw AppError.activityDetailsTooLong }
        
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
        let userActivity = UserActivity(hasRead: false,
                                        timestamp: Timestamp(date: Date()))
        let encodedUserActivity = try Firestore.Encoder().encode(userActivity)
        let userActivitiesRef = FirestoreConstants.UserCollection.document(uid).collection("user-activities")
        try await userActivitiesRef.document(activityId).setData(encodedUserActivity)
        
        // Add user to activity's participants list
        let activityParticipantsRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants")
        try await activityParticipantsRef.document(uid).setData([:])
    }
    
    static func closeActivity(activity: Activity) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard uid == activity.userId else { return } // Only host can close activity
        let activityId = activity.id
        try await FirestoreConstants.ActivitiesCollection.document(activityId).updateData(["status": "Closed"])
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
    static func fetchActivity(activityId: String) async throws -> Activity {
        let snapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).getDocument()
        guard snapshot.exists else { throw AppError.activityNotFound }
        var activity = try snapshot.data(as: Activity.self)

        // Fetch the group associated with the activity
        activity.group = try await GroupService.fetchGroup(groupId: activity.groupId)

        // Fetch the host (user) associated with the activity
        activity.host = try await UserService.fetchUser(uid: activity.userId)

        return activity
    }
    
    @MainActor
    static func joinActivity(activityId: String) async throws {
        let activity = try await ActivityService.fetchActivity(activityId: activityId)
        
        // Check if activity is valid to join
        guard activity.numRequired == 0 || activity.numCurrent < activity.numRequired else { throw AppError.activityFull }
        guard activity.status != "Closed" else { throw AppError.activityClosed }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard uid != activity.userId else { return } // Host of activity is already in activity

        // Update activity by incrementing numCurrent
        try await FirestoreConstants.ActivitiesCollection.document(activityId).updateData(["numCurrent": FieldValue.increment(Int64(1))])

        // Update user's activities subcollection by adding activity ID to it
        let userActivity = UserActivity(hasRead: false, timestamp: Timestamp(date: Date()))
        let encodedUserActivity = try Firestore.Encoder().encode(userActivity)
        let userActivitiesRef = FirestoreConstants.UserCollection.document(uid).collection("user-activities")
        try await userActivitiesRef.document(activityId).setData(encodedUserActivity)
        
        // Fetch all current participants in the activity
        let activityParticipantsRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants")
        let activityParticipantsSnapshot = try await activityParticipantsRef.getDocuments()
        let participantIds = activityParticipantsSnapshot.documents.map { $0.documentID }
        
        // Send notifications to all current participants
        let joinNotification = ActivityJoinNotification(activityId: activityId, joinedByUserId: uid)
        try await NotificationService.shared.sendNotification(notification: joinNotification, to: participantIds)

        // Add the new user to the participants subcollection
        try await activityParticipantsRef.document(uid).setData([:])
        
        // Send a system message
        let user = try await UserService.fetchUser(uid: uid)
        let systemMessage = "\(user.username) has joined the activity."
        try await ChatService.sendSystemMessage(to: activityId, messageText: systemMessage)
    }

    @MainActor
    static func leaveActivity(activity: Activity) async throws {
        do {
            guard activity.numCurrent > 0 else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard uid != activity.userId else { return } // Host of activity cannot leave
            let activityId = activity.id
            
            // Update activity by decrementing numCurrent
            try await FirestoreConstants.ActivitiesCollection.document(activityId).updateData(["numCurrent": FieldValue.increment(Int64(-1))])
            
            // Update user's activities subcollection by removing activity ID from it
            let userActivitiesRef = FirestoreConstants.UserCollection.document(uid).collection("user-activities")
            try await userActivitiesRef.document(activityId).delete()
            
            // Remove the user from the participants subcollection
            let activityParticipantsRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants")
            try await activityParticipantsRef.document(uid).delete()
            
            // Fetch all remaining participants in the activity
            let activityParticipantsSnapshot = try await activityParticipantsRef.getDocuments()
            let participantIds = activityParticipantsSnapshot.documents.map { $0.documentID }
            
            // Send notifications to all remaining participants
            let leaveNotification = ActivityLeaveNotification(activityId: activityId, leftByUserId: uid)
            try await NotificationService.shared.sendNotification(notification: leaveNotification, to: participantIds)
            
            // Send a system message
            let user = try await UserService.fetchUser(uid: uid)
            let systemMessage = "\(user.username) has left the activity."
            try await ChatService.sendSystemMessage(to: activityId, messageText: systemMessage)
            
        } catch {
            print("DEBUG: Failed to leave activity with error \(error.localizedDescription)")
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
    func fetchUserActivities(completion: @escaping([Activity]) -> Void) async {
        var activities: [Activity] = []
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userActivitiesSnapshot = try? await FirestoreConstants.UserCollection.document(uid).collection("user-activities").getDocuments() else { return }
        for doc in userActivitiesSnapshot.documents {
            let activityId = doc.documentID
            guard let activitySnapshot = try? await FirestoreConstants.ActivitiesCollection.document(activityId).getDocument() else { continue }
            guard let activity = try? activitySnapshot.data(as: Activity.self) else { continue }
            activities.append(activity)
        }
        completion(activities)
    }
    
    @MainActor
    static func fetchActivityParticipants(activity: Activity) async throws -> [User] {
        var users: [User] = []
        
        let activityId = activity.id
        let activityParticipantsSnapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants").getDocuments()
        
        for doc in activityParticipantsSnapshot.documents {
            let uid = doc.documentID
            let userSnapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
            let user = try userSnapshot.data(as: User.self)
            users.append(user)
        }
        
        return users
    }
}
