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
        
        // Fetch participants outside the transaction
        let participantsSnapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId)
            .collection("participants")
            .getDocuments()
        
        // Start Firestore Transaction for atomicity
        try await Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            // Step 1: Create the message document
            let messageRef = FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document()
            let message = Message(fromUserId: currentUid,
                                  toActivityId: activityId,
                                  messageText: messageText,
                                  timestamp: Timestamp(),
                                  imageUrl: imageUrl,
                                  messageType: type)
            
            guard let messageData = try? Firestore.Encoder().encode(message) else {
                errorPointer?.pointee = NSError(domain: "ChatService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"])
                return nil
            }
            
            // Set the message document atomically
            transaction.setData(messageData, forDocument: messageRef)
            
            let messageId = messageRef.documentID
            
            // Step 2: Update the recentMessageId field in the activity document
            let activityRef = FirestoreConstants.ActivitiesCollection.document(activityId)
            transaction.updateData(["recentMessageId": messageId], forDocument: activityRef)
            
            // Step 3: Update the recentMessageId and set hasRead = false for all participants except the sender
            for document in participantsSnapshot.documents {
                let participantId = document.documentID
                if participantId != currentUid {
                    let participantActivityRef = FirestoreConstants.UserCollection.document(participantId).collection("user-activities").document(activityId)
                    transaction.updateData(["recentMessageId": messageId, "timestamp": Timestamp(), "hasRead": false], forDocument: participantActivityRef)
                }
            }
            
            return nil
        })
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
