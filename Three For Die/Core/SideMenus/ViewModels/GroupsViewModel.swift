//
//  GroupsViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import Foundation

class GroupsViewModel: ObservableObject {
    @Published var groups = [Groups]()
    @Published var currSelectedGroup: Groups?
    @Published var fetchedGroups = false
    
    init() {
        Task {
            try await fetchCurrentGroup(groupId: "iYBzqoXOHI3rSwl4y1aW")
            await fetchUserGroups()
        }
    }
    
    @MainActor
    func fetchUserGroups() async {
        fetchedGroups = false
        self.groups = await GroupService.fetchUserGroups()
        fetchedGroups = true
    }
    
    @MainActor
    func fetchCurrentGroup(groupId: String) async throws {
        self.currSelectedGroup = try await GroupService.fetchGroup(groupId: groupId)
    }
}
