//
//  LeftSideMenuViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import Foundation

class LeftSideMenuViewModel: ObservableObject {
    @Published var groups = [Groups]()
    let service = GroupService()
    
    init() {
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
