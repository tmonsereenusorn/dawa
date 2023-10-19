//
//  ChatService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/29/23.
//

import Foundation
import Firebase

class ChatService {
    let activity: Activity
    private let fetchLimit = 50
    
    private var firestoreListener: ListenerRegistration?
    
    init(activity: Activity) {
        self.activity = activity
    }
    
    func observeMessages(completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let activityId = activity.id
        
        let query = FirestoreConstants.ActivitiesCollection
            .document(activityId)
            .collection("messages")
            .limit(toLast: fetchLimit)
            .order(by: "timestamp", descending: false)
        
        self.firestoreListener = query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var messages = changes.compactMap{ try? $0.document.data(as: Message.self) }
            
            let group = DispatchGroup()
            for (index, message) in messages.enumerated() where message.fromUserId != currentUid {
                group.enter()
                
                UserService.fetchUser(withUid: message.fromUserId) { user in
                    messages[index].user = user
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(messages)
            }
        }
    }
    
    func sendMessage(type: MessageType) async throws {
        switch type {
        case .text(let messageText):
            try await uploadMessage(messageText)
        case .image(let uIImage):
            let imageUrl = try await ImageUploader.uploadImage(image: uIImage, type: .message)
            try await uploadMessage("Attachment: Image", imageUrl: imageUrl)
        }
    }
    
    private func uploadMessage(_ messageText: String, imageUrl: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let activityId = activity.id
        
        // Add message to activity's messages subcollection
        let messageRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document()
        let message = Message(fromUserId: currentUid,
                              toActivityId: activityId,
                              messageText: messageText,
                              timestamp: Timestamp(),
                              imageUrl: imageUrl)
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        try await messageRef.setData(messageData)
        
        // Add recent message ID to activity
        let messageId = messageRef.documentID
        try? await FirestoreConstants.ActivitiesCollection.document(activityId).setData(["recentMessageId": messageId], merge: true)
        
        // Add recent message ID to each participant's activity
        guard let activityParticipantsSnapshot = try? await FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants").getDocuments() else { return }
        for doc in activityParticipantsSnapshot.documents {
            let participantId = doc.documentID
            try await FirestoreConstants.UserCollection.document(participantId).collection("user-activities").document(activityId).setData(
                ["recentMessageId": messageId, "timestamp": Timestamp()], merge: true)
        }
    }
    
    func removeListener() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
}
