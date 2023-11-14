//
//  InviteUsersViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/7/23.
//

import Foundation

class InviteUsersViewModel: ObservableObject {
    @Published var usersToInvite = [User]()
    @Published var didInviteUsers = false
    
    @Published var users = [User]()
    @Published var searchText = ""
    
    var groupMembers: [User]
    
    init(groupMembers: [User]) {
        self.groupMembers = groupMembers
    }
    
    func searchForUsers() async throws {
        let fetchedUsers = try await UserService.searchForUsers(beginningWith: searchText.lowercased())
            
        // Switch to the main thread to update the published property
        await MainActor.run {
            self.users = fetchedUsers.filter { user in
                !groupMembers.contains(where: { $0.id == user.id })
            }
        }
    }
    
    @MainActor
    func toggleUserSelection(user: User) {
        if let index = usersToInvite.firstIndex(of: user) {
            usersToInvite.remove(at: index)
        } else {
            usersToInvite.append(user)
        }
    }
    
    @MainActor
    func sendInvites(forGroupId: String) async throws {
        do {
            try await InviteService.sendGroupInvitations(toUsers: usersToInvite, forGroupId: forGroupId)
            didInviteUsers = true
        } catch {
            print("DEBUG: Failed to send group invitations")
        }
    }
}
