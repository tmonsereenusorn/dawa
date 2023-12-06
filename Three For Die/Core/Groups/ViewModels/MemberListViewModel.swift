//
//  MemberListViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 10/30/23.
//

import Foundation

class MemberListViewModel: ObservableObject {
    @Published var group: Groups?
    
    @MainActor
    func refreshGroup(groupId: String) async throws {
        do {
            let newGroup = try await GroupService.fetchGroup(groupId: groupId)
            group = newGroup
        } catch {
            print("DEBUG: Failed to fetch group with error \(error.localizedDescription)")
        }
    }
    
    
}
