//
//  GroupService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import Foundation
import Firebase

class GroupService {
    
    @MainActor
    func createGroup(groupName: String, completion: @escaping(String) -> Void) async throws {
        do {
            // Upload group to firestore
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let group = Groups(name: groupName,
                                numMembers: 1)
            let encodedGroup = try Firestore.Encoder().encode(group)
            let groupRef = try await FirestoreConstants.GroupsCollection.addDocument(data: encodedGroup)
            
            let groupId = groupRef.documentID
            
            // Add user to group's user member list
            let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
            try await groupMembersRef.document(uid).setData([:])
            
            // Add group to user's groups list
            let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
            try await groupsRef.document(groupId).setData([:])
            
            completion(groupId)
            
        } catch {
            print("DEBUG: Failed to create group with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func joinGroup(uid: String, groupId: String) async throws {
        do {
            var group = try await GroupService.fetchGroup(groupId: groupId)
            
            let isCurrentUserAMember = group.memberList?.contains { $0.id == uid } ?? true
            
            if !isCurrentUserAMember {
                try await FirestoreConstants.GroupsCollection.document(groupId).updateData(["numMembers": FieldValue.increment(Int64(1))])
                
                // Add user to group's user member list
                let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
                try await groupMembersRef.document(uid).setData([:])
                
                // Add group to user's groups list
                let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
                try await groupsRef.document(groupId).setData([:])
            } else {
                print("User is already a member")
            }
        } catch {
            print("DEBUG: Failed to join group with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func fetchUserGroups(completion: @escaping([Groups]) -> Void) async {
        var groups: [Groups] = []
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userGroupsSnapshot = try? await FirestoreConstants.UserCollection.document(uid).collection("user-groups").getDocuments() else { return }
        for doc in userGroupsSnapshot.documents {
            let groupId = doc.documentID
            guard let group = try? await fetchGroup(groupId: groupId) else { continue }
            groups.append(group)
        }
        completion(groups)
    }
    
    @MainActor
    static func editGroup(withGroupId groupId: String, name: String, uiImage: UIImage?) async throws {
        do {
            // Upload new profile image if provided
            if let image = uiImage {
                if let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .group) {
                    try await FirestoreConstants.GroupsCollection.document(groupId).setData(["name": name, "groupImageUrl": imageUrl], merge: true)
                } else {
                    print("DEBUG: Failed to upload profile image")
                    return
                }
            } else {
                try await FirestoreConstants.GroupsCollection.document(groupId).setData(["name": name], merge: true)
            }
        } catch {
            print("DEBUG: Failed to edit user with error \(error.localizedDescription)")
        }
    }
    
    static func fetchGroup(groupId: String) async throws -> Groups {
        let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).getDocument()
        var group = try snapshot.data(as: Groups.self)
        let members = await fetchGroupMembers(groupId: group.id)
        group.memberList = members
        return group
    }
    
    static func fetchGroupForInvite(withGroupId groupId: String, completion: @escaping(Groups) -> Void) {
        FirestoreConstants.GroupsCollection.document(groupId).getDocument() { snapshot, _ in
            guard let group = try? snapshot?.data(as: Groups.self) else {
                print("DEBUG: Failed to map group")
                return
            }
            completion(group)
        }
    }
    
    @MainActor
    static func fetchGroupMembers(groupId: String) async -> [User] {
        var users: [User] = []
        
        guard let groupMembersSnapshot = try? await FirestoreConstants.GroupsCollection.document(groupId).collection("members").getDocuments() else { return users }
        
        for doc in groupMembersSnapshot.documents {
            let uid = doc.documentID
            guard let userSnapshot = try? await FirestoreConstants.UserCollection.document(uid).getDocument() else { continue }
            guard let user = try? userSnapshot.data(as: User.self) else { continue }
            users.append(user)
        }
        return users
    }
}
