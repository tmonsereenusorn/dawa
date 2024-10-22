//
//  Message.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/12/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum MessageType: String, Codable {
    case text
    case image
    case system
}

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var messageId: String?
    let fromUserId: String
    let toActivityId: String
    let messageText: String
    let timestamp: Timestamp
    var imageUrl: String?
    let messageType: MessageType
    
    var user: User?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    var isFromCurrentUser: Bool {
        return fromUserId == Auth.auth().currentUser?.uid
    }
    
    var isImageMessage: Bool {
        return messageType == .image
    }
    
    var isSystemMessage: Bool {
        return messageType == .system
    }
}
