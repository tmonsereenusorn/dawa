import Foundation
import Firebase

class ChatService {
    let activity: Activity
    private let fetchLimit = 50
    private var firestoreListener: ListenerRegistration?
    
    init(activity: Activity) {
        self.activity = activity
    }
    
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
                for (index, message) in messages.enumerated() where message.fromUserId != currentUid && message.messageType != .system {
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
    
    func sendMessage(messageText: String, type: MessageType, image: UIImage? = nil) async throws {
        var imageUrl: String?
        
        if case .image = type, let uiImage = image {
            imageUrl = try await ImageUploader.uploadImage(image: uiImage, type: .message)
        }
        
        try await ChatService.uploadMessage(toActivityId: activity.id, messageText: messageText, type: type, imageUrl: imageUrl)
    }
    
    static func sendSystemMessage(to activityId: String, messageText: String) async throws {
        try await uploadMessage(toActivityId: activityId, messageText: messageText, type: .system, imageUrl: nil)
    }
    
    private static func uploadMessage(toActivityId activityId: String, messageText: String, type: MessageType, imageUrl: String? = nil) async throws {
        let currentUid = Auth.auth().currentUser?.uid ?? "UNKNOWN"
        
        let messageRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document()
        let message = Message(fromUserId: currentUid,
                              toActivityId: activityId,
                              messageText: messageText,
                              timestamp: Timestamp(),
                              imageUrl: imageUrl,
                              messageType: type)
        
        guard let messageData = try? Firestore.Encoder().encode(message) else {
            throw NSError(domain: "ChatService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"])
        }
        try await messageRef.setData(messageData)
        
        let messageId = messageRef.documentID
        try await FirestoreConstants.ActivitiesCollection.document(activityId).setData(["recentMessageId": messageId], merge: true)
        
        let activityParticipantsSnapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).collection("participants").getDocuments()
        for doc in activityParticipantsSnapshot.documents {
            let participantId = doc.documentID
            try await FirestoreConstants.UserCollection.document(participantId).collection("user-activities").document(activityId).setData(
                ["recentMessageId": messageId, "timestamp": Timestamp(), "hasRead": false], merge: true)
        }
    }
    
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
