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
    @Published var pendingRequests = [String]() // Store group IDs of pending requests
    
    init() {
        Task {
            await fetchPendingRequests()
        }
    }
    
    func searchForGroups() async throws {
        let fetchedGroups = try await GroupService.searchForGroups(beginningWith: searchText.lowercased())
            
        // Switch to the main thread to update the published property
        await MainActor.run {
            self.groups = fetchedGroups
        }
    }
    
    func fetchPendingRequests() async {
        do {
            let fetchedPendingRequests = try await GroupService.fetchPendingRequests()
            // Switch to the main thread to update the published property
            await MainActor.run {
                self.pendingRequests = fetchedPendingRequests
            }
        } catch {
            print("Error fetching pending requests: \(error)")
        }
    }
}
