import Foundation
import Firebase

class ChatService {
    let activity: Activity
    private let fetchLimit = 50
    private var firestoreListener: ListenerRegistration?
    
    init(activity: Activity) {
        self.activity = activity
    }
    
    // Async stream property for observing messages
    var messagesStream: AsyncStream<[Message]> {
        AsyncStream { continuation in
            guard let currentUid = Auth.auth().currentUser?.uid else {
                continuation.finish()
                return
            }
            let activityId = activity.id
            
            let query = FirestoreConstants.ActivitiesCollection
                .document(activityId)
                .collection("messages")
                .limit(toLast: fetchLimit)
                .order(by: "timestamp", descending: false)
            
            self.firestoreListener = query.addSnapshotListener { snapshot, _ in
                guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
                var messages = changes.compactMap { try? $0.document.data(as: Message.self) }
                
                let group = DispatchGroup()
                for (index, message) in messages.enumerated() where message.fromUserId != currentUid {
                    group.enter()
                    
                    UserService.fetchUser(withUid: message.fromUserId) { user in
                        messages[index].user = user
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    continuation.yield(messages)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.firestoreListener?.remove()
                self?.firestoreListener = nil
            }
        }
    }
    
    // Sending a message
    func sendMessage(type: MessageType) async throws {
        switch type {
        case .text(let messageText):
            try await uploadMessage(messageText)
        case .image(let uIImage):
            let imageUrl = try await ImageUploader.uploadImage(image: uIImage, type: .message)
            try await uploadMessage("Attachment: Image", imageUrl: imageUrl)
        }
    }
    
    // Uploading a message
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
        try await FirestoreConstants.ActivitiesCollection.document(activityId).setData(["recentMessageId": messageId], merge: true)
        
        // Add recent message ID to each participant's activity
        let activityParticipantsSnapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants").getDocuments()
        for doc in activityParticipantsSnapshot.documents {
            let participantId = doc.documentID
            try await FirestoreConstants.UserCollection.document(participantId).collection("user-activities").document(activityId).setData(
                ["recentMessageId": messageId, "timestamp": Timestamp(), "hasRead": false], merge: true)
        }
    }
    
    // Mark message as read
    static func markAsRead(activityId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docRef = Firestore.firestore().collection("users").document(uid).collection("user-activities").document(activityId)
        
        docRef.updateData(["hasRead": true]) { error in
            if let error = error {
                print("Error marking as read: \(error)")
            } else {
                print("Activity marked as read.")
            }
        }
    }
    
    func removeListener() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
}