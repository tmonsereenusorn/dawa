//
//  Message.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/12/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum MessageType {
    case text(String)
    case image(UIImage)
}

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var messageId: String?
    let fromUserId: String
    let toActivityId: String
    let messageText: String
    let timestamp: Timestamp
    var imageUrl: String?
    
    var user: User?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    var isFromCurrentUser: Bool {
        return fromUserId == Auth.auth().currentUser?.uid
    }
    
    var isImageMessage: Bool {
        return imageUrl != nil
    }
}
