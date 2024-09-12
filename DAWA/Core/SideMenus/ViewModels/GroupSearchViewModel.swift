//
//  GroupSearchViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 11/26/23.
//

import Foundation

class GroupSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var groups = [Groups]()
    
    func searchForGroups() async throws {
        let fetchedGroups = try await GroupService.searchForGroups(beginningWith: searchText.lowercased())
            
        // Switch to the main thread to update the published property
        await MainActor.run {
            self.groups = fetchedGroups
        }
    }
}
