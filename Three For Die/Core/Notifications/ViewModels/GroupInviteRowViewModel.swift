//
//  GroupInviteRowViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import Foundation
import Firebase

class GroupInviteRowViewModel: ObservableObject {
    
    func acceptGroupInvitation(groupInvite: GroupInvite) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            try await GroupService.joinGroup(uid: uid, groupId: groupInvite.forGroupId)
            try await deleteGroupInvitation(groupInvite: groupInvite)
        } catch {
            print("DEBUG: Error accepting group invitation")
        }
    }
    
    func deleteGroupInvitation(groupInvite: GroupInvite) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            try await InviteService.deleteGroupInvitation(uid: uid, groupInviteId: groupInvite.id, groupId: groupInvite.forGroupId)
        } catch {
            print("DEBUG: Error deleting group invitation")
        }
    }
}
