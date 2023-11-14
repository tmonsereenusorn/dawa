//
//  InviteService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/7/23.
//

import Foundation
import Firebase

class InviteService {
    
    @MainActor
    static func sendGroupInvitations(toUsers: [User], forGroupId: String) async throws {
        for toUser in toUsers {
            let toUserId = toUser.id
            try await sendGroupInvite(toUid: toUserId, forGroupId: forGroupId)
        }
    }
    
    static func sendGroupInvite(toUid: String, forGroupId: String) async throws {
        do {
            guard let fromUid = Auth.auth().currentUser?.uid else { return }
            
            let invite = GroupInvite(fromUserId: fromUid,
                                     toUserId: toUid,
                                     forGroupId: forGroupId,
                                     status: "Pending")
            
            let encodedInvite = try Firestore.Encoder().encode(invite)
            
            try await FirestoreConstants.UserCollection.document(toUid).collection("group-invites").addDocument(data: encodedInvite)
        } catch {
            print("DEBUG: Failed to send group invite to user id: \(toUid) with error \(error.localizedDescription)")
        }
    }
}
