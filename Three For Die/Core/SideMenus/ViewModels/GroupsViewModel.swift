//
//  GroupsViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import Foundation

class GroupsViewModel: ObservableObject {
    @Published var groups = [Groups]()
    @Published var currSelectedGroup: String
    let service = GroupService()
    
    init() {
        self.currSelectedGroup = "iYBzqoXOHI3rSwl4y1aW"
        Task {
            await fetchUserGroups()
        }
    }
    
    @MainActor
    func fetchUserGroups() async {
        await service.fetchUserGroups { groups in
            self.groups = groups
        }
    }
}
