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
    @Published var groupId: String?
    @Published var didCreateGroup = false
    @Published var showGroupHandleErrorMessage = false
    let service = GroupService()
    
    @MainActor
    func createGroup(name: String, handle: String) async throws {
        do {
            self.groupId = try await GroupService.createGroup(groupName: name, handle: handle.lowercased())
            self.didCreateGroup = true
        } catch AppError.groupHandleAlreadyExists {
            showGroupHandleErrorMessage = true
            print("Group handle already exists. Please choose a different handle.")
        } catch {
            print("DEBUG: Failed to create group with error \(error.localizedDescription)")
            self.didCreateGroup = false
        }
    }
}
