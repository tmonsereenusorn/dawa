//
//  GroupInvite.swift
//  Three For Die
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
    
    var id: String {
        return inviteId ?? NSUUID().uuidString
    }
}
