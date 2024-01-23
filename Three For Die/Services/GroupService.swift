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
    func createGroup(groupName: String, handle: String, completion: @escaping(String) -> Void) async throws {
        do {
            // Check if group handle already exists
            let querySnapshot = try await FirestoreConstants.GroupsCollection
                .whereField("handle", isEqualTo: handle)
                .getDocuments()
            
            guard querySnapshot.documents.isEmpty else {
                throw AppError.groupHandleAlreadyExists
            }
            
            // Upload group to firestore
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let group = Groups(name: groupName,
                               handle: handle,
                               numMembers: 1)
            let encodedGroup = try Firestore.Encoder().encode(group)
            let groupRef = try await FirestoreConstants.GroupsCollection.addDocument(data: encodedGroup)
            
            let groupId = groupRef.documentID
            
            // Add user to group's user member list
            let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
            try await groupMembersRef.document(uid).setData(["permissions":"Owner"])
            
            // Add group to user's groups list
            let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
            try await groupsRef.document(groupId).setData([:])
            
            completion(groupId)
            
        } catch let error as AppError {
            print(error.localizedDescription)
            throw error
        } catch {
            print("DEBUG: Failed to create group with error \(error.localizedDescription)")
        }
    }
    
    static func deleteGroup(groupId: String) async throws -> Bool {
        do {
            let group = try await GroupService.fetchGroup(groupId: groupId)
            
            for member in group.memberList! {
                let memberGroupsRef = FirestoreConstants.UserCollection.document(member.id).collection("user-groups")
                try await memberGroupsRef.document(groupId).delete()
            }
            
            try await FirestoreConstants.GroupsCollection.document(groupId).delete()
            return true
        } catch {
            print("DEBUG: Failed to delete group with error \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    static func joinGroup(uid: String, groupId: String) async throws {
        do {
            let group = try await GroupService.fetchGroup(groupId: groupId)
            
            let isCurrentUserAMember = group.memberList?.contains { $0.id == uid } ?? true
            
            if !isCurrentUserAMember {
                // Add user to group's user member list
                let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
                try await groupMembersRef.document(uid).setData(["permissions":"Member"])
                
                // Add group to user's groups list
                let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
                try await groupsRef.document(groupId).setData([:])
                
                try await FirestoreConstants.GroupsCollection.document(groupId).updateData(["numMembers": FieldValue.increment(Int64(1))])
            } else {
                print("User is already a member")
            }
        } catch {
            print("DEBUG: Failed to join group with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func leaveGroup(uid: String, groupId: String) async throws -> Bool {
        do {
            let group = try await GroupService.fetchGroup(groupId: groupId)
            
            let isCurrentUserAMember = group.memberList?.contains { $0.id == uid } ?? false
            
            if isCurrentUserAMember {
                // Delete user from group's user member list
                let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
                try await groupMembersRef.document(uid).delete()
                
                // Delete group to user's groups list
                let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
                try await groupsRef.document(groupId).delete()
                
                try await FirestoreConstants.GroupsCollection.document(groupId).updateData(["numMembers": FieldValue.increment(Int64(-1))])
                
                return true
            } else {
                print("User is not a member")
                return false
            }
        } catch {
            print("DEBUG: Failed to leave group with error \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    static func fetchUserGroups() async -> [Groups] {
        var groups: [Groups] = []

        guard let uid = Auth.auth().currentUser?.uid else { return groups }
        guard let userGroupsSnapshot = try? await FirestoreConstants.UserCollection.document(uid).collection("user-groups").getDocuments() else { return groups }

        // Create a task group to fetch group data in parallel
        await withTaskGroup(of: Groups?.self) { group in
            for doc in userGroupsSnapshot.documents {
                let groupId = doc.documentID
                group.addTask {
                    // Try to fetch each group concurrently
                    return try? await fetchGroup(groupId: groupId)
                }
            }

            for await groupResult in group {
                if let groupResult = groupResult {
                    groups.append(groupResult)
                }
            }
        }
        
        return groups
    }

    
    @MainActor
    static func editGroup(withGroupId groupId: String, name: String, handle: String, uiImage: UIImage?) async throws {
        do {
            // Check if group handle already exists
            let querySnapshot = try await FirestoreConstants.GroupsCollection
                .whereField("handle", isEqualTo: handle)
                .getDocuments()
            
            if querySnapshot.documents.first(where: { $0.documentID != groupId }) != nil {
                // A different group with the same handle exists
                throw AppError.groupHandleAlreadyExists
            }
            
            // Upload new profile image if provided
            if let image = uiImage {
                if let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .group) {
                    try await FirestoreConstants.GroupsCollection.document(groupId).setData(["name": name, "handle": handle, "groupImageUrl": imageUrl], merge: true)
                } else {
                    print("DEBUG: Failed to upload profile image")
                    return
                }
            } else {
                try await FirestoreConstants.GroupsCollection.document(groupId).setData(["name": name, "handle": handle], merge: true)
            }
        } catch let error as AppError {
            print(error.localizedDescription)
            throw error
        } catch {
            print("DEBUG: Failed to create group with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func fetchGroup(groupId: String) async throws -> Groups {
        let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).getDocument()
        var group = try snapshot.data(as: Groups.self)
        let members = await fetchGroupMembers(groupId: group.id)
        group.memberList = members
        return group
    }
    
    static func fetchGroup(withGroupId groupId: String, completion: @escaping(Groups) -> Void) {
        FirestoreConstants.GroupsCollection.document(groupId).getDocument() { snapshot, _ in
            guard let group = try? snapshot?.data(as: Groups.self) else {
                print("DEBUG: Failed to map group with id: \(groupId)")
                return
            }
            completion(group)
        }
    }
    
    @MainActor
    static func fetchGroupMembers(groupId: String) async -> [User] {
        var users: [User] = []
        
        guard let groupMembersSnapshot = try? await FirestoreConstants.GroupsCollection.document(groupId).collection("members").getDocuments() else { return users }
        
        // Create a task group to fetch user data in parallel
        await withTaskGroup(of: User?.self) { group in
            for doc in groupMembersSnapshot.documents {
                let uid = doc.documentID
                group.addTask {
                    guard let userSnapshot = try? await FirestoreConstants.UserCollection.document(uid).getDocument(),
                          var user = try? userSnapshot.data(as: User.self) else { return nil }
                    user.groupPermissions = doc.get("permissions") as? String
                    return user
                }
            }

            for await user in group {
                if let user = user {
                    users.append(user)
                }
            }
        }
        
        return users
    }
    
    @MainActor
    static func searchForGroups(beginningWith startString: String) async throws -> [Groups] {
        let query = FirestoreConstants.GroupsCollection
            .whereField("handle", isGreaterThanOrEqualTo: startString)
            .whereField("handle", isLessThan: startString + "\u{f8ff}")
            .limit(to: 100)
        
        let snapshot = try await query.getDocuments()
        return mapGroups(fromSnapshot: snapshot)
    }
    
    static func requestToJoinGroup(groupId: String) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let request = MemberRequest(fromUserId: uid, 
                                        toGroupId: groupId,
                                        timestamp: Timestamp())
            
            let encodedRequest = try Firestore.Encoder().encode(request)
            
            try await FirestoreConstants.GroupsCollection.document(groupId).collection("member-requests").addDocument(data: encodedRequest)
        } catch {
            print("DEBUG: Failed to send request to join group")
        }
    }
    
    @MainActor
    static func changeGroupPermissions(groupId: String, forUserId uid: String, toPermission permission: String) async throws -> Bool {
        do {
            try await FirestoreConstants.GroupsCollection.document(groupId).collection("members").document(uid).setData(["permissions": permission], merge: true)
            return true
        } catch {
            print("DEBUG: Failed to change permissions for user ID: \(uid) in group ID: \(groupId)")
            return false
        }
    }
    
    private static func mapGroups(fromSnapshot snapshot: QuerySnapshot) -> [Groups] {
        return snapshot.documents
            .compactMap({ try? $0.data(as: Groups.self) })
    }
}
