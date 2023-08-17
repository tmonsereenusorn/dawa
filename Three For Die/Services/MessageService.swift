//
//  MessageService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/12/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct MessageService {
    
    static func sendMessage(_ messageText: String, toActivity activity: Activity) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let activityId = activity.id
        
        // Add message to activity's messages subcollection
        let messageRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document()
        let message = Message(fromUserId: currentUid,
                              toActivityId: activityId,
                              messageText: messageText,
                              timestamp: Timestamp())
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        try await messageRef.setData(messageData)
        
        // Add recent message ID to activity
        let messageId = messageRef.documentID
        try? await FirestoreConstants.ActivitiesCollection.document(activityId).setData(["recentMessageId": messageId], merge: true)
        
        // Add recent message ID to each participant's activity
        guard let activityParticipantsSnapshot = try? await FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants").getDocuments() else { return }
        for doc in activityParticipantsSnapshot.documents {
            let participantId = doc.documentID
            try await FirestoreConstants.UserCollection.document(participantId).collection("user-activities").document(activityId).setData(["recentMessageId": messageId], merge: true)
        }
    }
    
    static func observeMessages(activityId: String, completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added}) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
            
            for (index, message) in messages.enumerated() where message.fromUserId != currentUid {
                print("Got message: \(message.messageText)")
                UserService.fetchUser(withUid: message.fromUserId) { user in
                    messages[index].user = user
                }
            }
            
            completion(messages)
        }
    }
    
    @MainActor
    static func fetchMessage(withMessageId messageId: String, activityId: String) async throws -> Message? {
        do {
            let snapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document(messageId).getDocument()
            return try snapshot.data(as: Message.self)
        } catch {
            print("DEBUG: Failed to fetch message with error \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchMessage(withMessageId messageId: String, activityId: String, completion: @escaping(Message) -> Void) {
        FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document(messageId).getDocument() { snapshot, _ in
            guard let message = try? snapshot?.data(as: Message.self) else {
                print("DEBUG: Failed to map message")
                return
            }
            completion(message)
        }
    }
}
