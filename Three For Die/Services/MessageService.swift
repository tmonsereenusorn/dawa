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
    
    static func sendMessage(_ messageText: String, toActivity activity: Activity) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let activityId = activity.id
        
        let message = Message(fromUserId: currentUid,
                              toActivityId: activityId,
                              messageText: messageText,
                              timestamp: Timestamp())
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        Firestore.firestore().collection("activities").document(activityId).collection("messages").addDocument(data: messageData)
    }
    
    static func observeMessages(activityId: String, completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore().collection("activities").document(activityId).collection("messages").order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added}) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
            
            for (index, message) in messages.enumerated() where message.fromId != currentUid {
                let messageUser = UserService.fetchUser(withUid: message.fromId) { user in
                    messages[index].user = messageUser
                }
            }
            
            completion(messages)
        }
    }
}
