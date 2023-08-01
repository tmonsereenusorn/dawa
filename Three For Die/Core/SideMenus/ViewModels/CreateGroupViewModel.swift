//
//  CreateGroupViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation

protocol CreateGroupFormProtocol {
    var formIsValid: Bool { get }
}

class CreateGroupViewModel: ObservableObject {
    @Published var didCreateGroup = false
    let service = GroupService()
    
    @MainActor
    func createGroup(name: String, completion: @escaping(String) -> Void) async throws {
        do {
            try await service.createGroup(groupName: name) { groupId in
                self.didCreateGroup = true
                completion(groupId)
            }
        } catch {
            print("DEBUG: Failed to create group with error \(error.localizedDescription)")
            self.didCreateGroup = false
        }
    }
}
