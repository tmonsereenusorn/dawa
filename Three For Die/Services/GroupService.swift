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
            let group = Groups(name: groupName)
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
    static func fetchUserGroups(completion: @escaping([Groups]) -> Void) async {
        var groups: [Groups] = []
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userGroupsSnapshot = try? await FirestoreConstants.UserCollection.document(uid).collection("user-groups").getDocuments() else { return }
        for doc in userGroupsSnapshot.documents {
            let groupId = doc.documentID
            guard let groupSnapshot = try? await FirestoreConstants.GroupsCollection.document(groupId).getDocument() else { return }
            guard let group = try? groupSnapshot.data(as: Groups.self) else { return }
            groups.append(group)
        }
        completion(groups)
    }
    
    @MainActor
    static func editGroup(withGroupId groupId: String, name: String, uiImage: UIImage?) async throws {
        do {
            guard let snapshot = try? await FirestoreConstants.GroupsCollection.document(groupId).getDocument() else { return }
            
            // Upload new profile image if provided
            if let image = uiImage {
                if let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .group) {
                    print("Uploading new image")
                    try await FirestoreConstants.GroupsCollection.document(groupId).setData(["name": name, "groupImageUrl": imageUrl], merge: true)
                } else {
                    print("DEBUG: Failed to upload profile image")
                    return
                }
            } else {
                print("Not uploading new image")
                try await FirestoreConstants.GroupsCollection.document(groupId).setData(["name": name], merge: true)
            }
        } catch {
            print("DEBUG: Failed to edit user with error \(error.localizedDescription)")
        }
    }
    
    static func fetchGroup(groupId: String) async throws -> Groups {
        let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).getDocument()
        return try snapshot.data(as: Groups.self)
    }
}
