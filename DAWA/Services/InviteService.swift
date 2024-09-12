//
//  InviteService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/7/23.
//

import Foundation
import Firebase

class InviteService {
    @Published var documentChanges = [DocumentChange]()
    @Published var hasInvites = false
    static let shared = InviteService()
    private var firestoreListener: ListenerRegistration?
    
    // need to call this thru shared instance to setup the observer
    func observeGroupInvites() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.UserCollection
            .document(uid)
            .collection("group-invites")
            .order(by: "timestamp", descending: true)
        
        self.firestoreListener = query.addSnapshotListener { snapshot, _ in
            self.hasInvites = !(snapshot?.documents.isEmpty ?? true)
            guard let changes = snapshot?.documentChanges else { return }
            
            self.documentChanges = changes
        }
    }
    
    func reset() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
        self.documentChanges.removeAll()
    }
    
    
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
            
            let recipientInvitesSnapshot = try await FirestoreConstants.UserCollection.document(toUid).collection("group-invites").getDocuments()
            
            let recipientInvites = recipientInvitesSnapshot.documents.compactMap({ try? $0.data(as: GroupInvite.self)})
            print(recipientInvites)
            
            if recipientInvites.contains(where: { $0.forGroupId == forGroupId }) {
                print("returning")
                return
            }
            
            let newInviteId = FirestoreConstants.UserCollection.document().documentID
            
            let invite = GroupInvite(fromUserId: fromUid,
                                     toUserId: toUid,
                                     forGroupId: forGroupId,
                                     status: "Pending",
                                     timestamp: Timestamp())
            
            
            
            let encodedInvite = try Firestore.Encoder().encode(invite)
            
            try await FirestoreConstants.UserCollection.document(toUid).collection("group-invites").document(newInviteId).setData(encodedInvite)
            
            try await FirestoreConstants.GroupsCollection.document(forGroupId).collection("outgoing-invites").document(newInviteId).setData(encodedInvite)
        } catch {
            print("DEBUG: Failed to send group invite to user id: \(toUid) with error \(error.localizedDescription)")
        }
    }
    
    static func deleteGroupInvitation(uid: String, groupInviteId: String, groupId: String) async throws {
        do {
            try await FirestoreConstants.UserCollection.document(uid).collection("group-invites").document(groupInviteId).delete()
            try await FirestoreConstants.GroupsCollection.document(groupId).collection("outgoing-invites").document(groupInviteId).delete()
        } catch {
            print("DEBUG: Error deleting group invitation")
        }
    }
}
