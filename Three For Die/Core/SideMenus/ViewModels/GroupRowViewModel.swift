//
//  GroupRowViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 1/4/24.
//

import Foundation
import Firebase

class GroupRowViewModel: ObservableObject {
    
    func leaveGroup(groupId: String) async throws -> Bool {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return false }
            return try await GroupService.leaveGroup(uid: uid, groupId: groupId)
        } catch {
            return false
        }
        
    }
}
