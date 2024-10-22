//
//  GroupInvite.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 11/7/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct GroupInvite: Identifiable, Codable, Hashable {
    @DocumentID var inviteId: String?
    
    let fromUserId: String
    let toUserId: String
    let forGroupId: String
    var status: String
    let timestamp: Timestamp
    
    var group: Groups?
    
    var id: String {
        return inviteId ?? NSUUID().uuidString
    }
}
