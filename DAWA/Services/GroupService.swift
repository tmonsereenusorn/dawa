//
//  GroupService.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import Foundation
import Firebase

class GroupService {
    
    @MainActor
    static func createGroup(groupName: String, handle: String, uiImage: UIImage?) async throws -> String {
        do {
            // Validate the handle length
            if handle.count > GroupConstants.maxHandleLength { throw AppError.groupHandleTooLong }
            if handle.count < GroupConstants.minHandleLength { throw AppError.groupHandleTooShort }
            
            // Validate the group name length
            if groupName.count > GroupConstants.maxNameLength { throw AppError.groupNameTooLong }
            if groupName.count < GroupConstants.minNameLength { throw AppError.groupNameTooShort }
            
            // Check if the group handle already exists
            let querySnapshot = try await FirestoreConstants.GroupsCollection
                .whereField("handle", isEqualTo: handle)
                .getDocuments()
            
            guard querySnapshot.documents.isEmpty else {
                throw AppError.groupHandleAlreadyExists
            }
            
            // Ensure the user is authenticated
            guard let uid = Auth.auth().currentUser?.uid else { return "" }
            
            // Create the group object
            let group = Groups(name: groupName, handle: handle, numMembers: 1)
            let encodedGroup = try Firestore.Encoder().encode(group)
            
            // Add the group to Firestore
            let groupRef = try await FirestoreConstants.GroupsCollection.addDocument(data: encodedGroup)
            let groupId = groupRef.documentID
            
            // Add the user as the owner in the group's members subcollection
            let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
            try await groupMembersRef.document(uid).setData(["permissions": "Owner"])
            
            // Add the group to the user's groups list
            let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
            try await groupsRef.document(groupId).setData([:])
            
            // If an image is provided, upload it and update the group with the image URL
            if let image = uiImage {
                if let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .group) {
                    // Update the group with the image URL
                    try await FirestoreConstants.GroupsCollection.document(groupId).setData(["groupImageUrl": imageUrl], merge: true)
                } else {
                    print("DEBUG: Failed to upload group image")
                }
            }
            
            return groupId
        } catch let error as AppError {
            print(error.localizedDescription)
            throw error
        } catch {
            print("DEBUG: Failed to create group with error \(error.localizedDescription)")
            throw error
        }
    }
    
    static func deleteGroup(groupId: String) async throws -> Bool {
        do {
            let group = try await GroupService.fetchGroup(groupId: groupId)
            
            for member in group.memberList! {
                let _ = try await leaveGroup(uid: member.id, groupId: groupId)
            }
            
            let outgoingInvites = try await GroupService.fetchOutgoingInvites(groupId: groupId)
            
            for outgoingInvite in outgoingInvites {
                try await InviteService.deleteGroupInvitation(uid: outgoingInvite.toUserId, groupInviteId: outgoingInvite.id, groupId: groupId)
            }
            
            try await FirestoreConstants.GroupsCollection.document(groupId).delete()
            return true
        } catch {
            print("DEBUG: Failed to delete group with error \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    static func joinGroup(uid: String, groupId: String, enableNotifications: Bool = true) async throws {
        do {
            // Fetch the group details to ensure the group exists
            let group = try await GroupService.fetchGroup(groupId: groupId)
            
            // Check if the user is already a member of the group
            let isCurrentUserAMember = group.memberList?.contains { $0.user?.id == uid } ?? false
            
            if !isCurrentUserAMember {
                // Create a GroupMember object with notificationsEnabled set to true
                let newMember = GroupMember(
                    permissions: "Member",
                    notificationsEnabled: enableNotifications
                )
                
                // Add user to group's members list using the GroupMember object
                let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members")
                let encodedMember = try Firestore.Encoder().encode(newMember)
                try await groupMembersRef.document(uid).setData(encodedMember)
                
                // Add group to user's groups list
                let groupsRef = FirestoreConstants.UserCollection.document(uid).collection("user-groups")
                try await groupsRef.document(groupId).setData([:])
                
                // Update the group's number of members
                try await FirestoreConstants.GroupsCollection.document(groupId).updateData([
                    "numMembers": FieldValue.increment(Int64(1))
                ])
                
                // Check if a pending member request exists and delete it
                let memberRequestRef = FirestoreConstants.GroupsCollection.document(groupId).collection("member-requests").whereField("fromUserId", isEqualTo: uid)
                let memberRequestSnapshot = try await memberRequestRef.getDocuments()
                for document in memberRequestSnapshot.documents {
                    try await document.reference.delete()
                }
                
                // Delete the pending request from the user's collection
                let pendingRequestRef = FirestoreConstants.UserCollection.document(uid).collection("pending-requests").document(groupId)
                let pendingRequestSnapshot = try await pendingRequestRef.getDocument()
                if pendingRequestSnapshot.exists {
                    try await pendingRequestRef.delete()
                }
                
                // Check if a group invitation exists and delete it
                let inviteSnapshot = try await FirestoreConstants.UserCollection.document(uid).collection("group-invites").whereField("forGroupId", isEqualTo: groupId).getDocuments()
                for document in inviteSnapshot.documents {
                    // Delete the user invite document
                    try await document.reference.delete()
                    
                    // Delete the corresponding group outgoing invite document
                    let inviteId = document.documentID
                    try await FirestoreConstants.GroupsCollection.document(groupId).collection("outgoing-invites").document(inviteId).delete()
                }
                
            } else {
                print("User is already a member")
            }
        } catch {
            print("DEBUG: Failed to join group with error \(error.localizedDescription)")
            throw error
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
                
                // Delete group from user's groups list
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
        
        return groups.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    
    @MainActor
    static func editGroup(withGroupId groupId: String, name: String, handle: String, uiImage: UIImage?) async throws {
        // Validate group name length
        if name.count > GroupConstants.maxNameLength {
            throw AppError.groupNameTooLong
        } else if name.count < GroupConstants.minNameLength {
            throw AppError.groupNameTooShort
        }

        // Validate group handle length
        if handle.count > GroupConstants.maxHandleLength {
            throw AppError.groupHandleTooLong
        } else if handle.count < GroupConstants.minHandleLength {
            throw AppError.groupHandleTooShort
        }

        // Fetch current group data
        let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).getDocument()
        guard let oldGroup = try? snapshot.data(as: Groups.self) else { return }

        // Check if handle is changed and already exists
        if handle.lowercased() != oldGroup.handle.lowercased() {
            let query = try await FirestoreConstants.GroupsCollection
                .whereField("handle", isEqualTo: handle.lowercased())
                .getDocuments()
            if !query.documents.isEmpty { throw AppError.groupHandleAlreadyExists }
        }

        // Prepare update data
        var updateData: [String: Any] = ["name": name, "handle": handle.lowercased()]
        if let image = uiImage, let imageUrl = try? await ImageUploader.uploadImage(image: image, type: .group) {
            updateData["groupImageUrl"] = imageUrl
        }

        // Update group in Firestore
        try await FirestoreConstants.GroupsCollection.document(groupId).setData(updateData, merge: true)
    }
    
    @MainActor
    static func fetchGroup(groupId: String) async throws -> Groups {
        let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).getDocument()
        var group = try snapshot.data(as: Groups.self)
        let members = try await fetchGroupMembers(groupId: group.id)
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
    
    static func fetchOutgoingInvites(groupId: String) async throws -> [GroupInvite] {
        let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).collection("outgoing-invites").getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: GroupInvite.self)})
    }
    
    @MainActor
    static func fetchGroupMembers(groupId: String) async throws -> [GroupMember] {
        var groupMembers: [GroupMember] = []

        let groupMembersSnapshot = try await FirestoreConstants.GroupsCollection.document(groupId).collection("members").getDocuments()

        await withTaskGroup(of: GroupMember?.self) { group in
            for doc in groupMembersSnapshot.documents {
                group.addTask {
                    if var groupMember = try? doc.data(as: GroupMember.self) {
                        // Fetch the corresponding User object in parallel
                        let userSnapshot = try? await FirestoreConstants.UserCollection.document(groupMember.id).getDocument()
                        if let user = try? userSnapshot?.data(as: User.self) {
                            groupMember.user = user // Attach the User object to GroupMember
                        }
                        return groupMember
                    }
                    return nil
                }
            }

            for await member in group {
                if let member = member {
                    groupMembers.append(member)
                }
            }
        }

        return groupMembers
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
            
            let pendingRequestSnapshot = try await FirestoreConstants.UserCollection.document(uid).collection("pending-requests").document(groupId).getDocument()
            if pendingRequestSnapshot.exists {
                print("DEBUG: User already has a pending request to join group \(groupId)")
                return
            }
            
            let request = MemberRequest(fromUserId: uid,
                                        toGroupId: groupId,
                                        timestamp: Timestamp())
            
            let encodedRequest = try Firestore.Encoder().encode(request)
            
            try await FirestoreConstants.GroupsCollection.document(groupId).collection("member-requests").addDocument(data: encodedRequest)
            
            try await FirestoreConstants.UserCollection.document(uid).collection("pending-requests").document(groupId).setData([:])
            
        } catch {
            print("DEBUG: Failed to send request to join group")
            throw error
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
    
    @MainActor
    static func findGroupByHandle(_ handle: String) async throws -> Groups? {
        do {
            let querySnapshot = try await FirestoreConstants.GroupsCollection
                .whereField("handle", isEqualTo: handle)
                .limit(to: 1)
                .getDocuments()
            
            if let document = querySnapshot.documents.first {
                var group = try document.data(as: Groups.self)
                let members = try await fetchGroupMembers(groupId: group.id)
                group.memberList = members
                return group
            } else {
                return nil
            }
        } catch {
            print("DEBUG: Failed to find group with handle \(handle): \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    static func fetchPendingRequests() async throws -> [String] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        do {
            let querySnapshot = try await FirestoreConstants.UserCollection.document(uid).collection("pending-requests").getDocuments()
            let groupIds = querySnapshot.documents.compactMap { $0.documentID }
            
            return groupIds
        } catch {
            print("Error fetching pending requests: \(error)")
            throw error
        }
    }
    
    @MainActor
    static func fetchMemberRequests(groupId: String) async throws -> [MemberRequest] {
        do {
            let snapshot = try await FirestoreConstants.GroupsCollection.document(groupId).collection("member-requests").getDocuments()
            let requests = snapshot.documents.compactMap { try? $0.data(as: MemberRequest.self) }
            
            var detailedRequests: [MemberRequest] = []
            
            for request in requests {
                if let userSnapshot = try? await FirestoreConstants.UserCollection.document(request.fromUserId).getDocument(),
                   let user = try? userSnapshot.data(as: User.self) {
                    var detailedRequest = request
                    detailedRequest.user = user
                    detailedRequests.append(detailedRequest)
                }
            }
            
            return detailedRequests
        } catch {
            print("Error fetching member requests: \(error)")
            throw error
        }
    }
    
    @MainActor
    static func rejectMemberRequest(requestId: String, groupId: String) async throws {
        do {
            // Fetch the member request to get the user ID
            let requestSnapshot = try await FirestoreConstants.GroupsCollection.document(groupId).collection("member-requests").document(requestId).getDocument()
            guard let request = try? requestSnapshot.data(as: MemberRequest.self) else {
                print("Error: Member request not found")
                return
            }

            let uid = request.fromUserId
            
            // Delete the pending request from the group's member-requests collection
            try await requestSnapshot.reference.delete()
            
            // Delete the pending request from the user's pending-requests collection
            let pendingRequestRef = FirestoreConstants.UserCollection.document(uid).collection("pending-requests").document(groupId)
            let pendingRequestSnapshot = try await pendingRequestRef.getDocument()
            if pendingRequestSnapshot.exists {
                try await pendingRequestRef.delete()
            }
            
            print("Member request rejected successfully")
        } catch {
            print("Error rejecting member request: \(error)")
            throw error
        }
    }
    
    @MainActor
    static func toggleNotifications(for uid: String, groupId: String) async throws {
        let groupMembersRef = FirestoreConstants.GroupsCollection.document(groupId).collection("members").document(uid)
        
        do {
            let document = try await groupMembersRef.getDocument()
            
            guard let groupMember = try? document.data(as: GroupMember.self) else {
                throw AppError.groupMemberNotFound
            }
            
            // Toggle the notificationsEnabled field
            let newNotificationsEnabled = !(groupMember.notificationsEnabled ?? false)
            
            // Update the group member with the new notificationsEnabled value
            try await groupMembersRef.updateData(["notificationsEnabled": newNotificationsEnabled])
        } catch {
            print("Error toggling notifications for user \(uid) in group \(groupId): \(error.localizedDescription)")
            throw error
        }
    }
    
    private static func mapGroups(fromSnapshot snapshot: QuerySnapshot) -> [Groups] {
        return snapshot.documents
            .compactMap({ try? $0.data(as: Groups.self) })
    }
}
