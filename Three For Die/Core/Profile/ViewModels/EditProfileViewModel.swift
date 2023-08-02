//
//  EditProfileViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/2/23.
//

import Foundation

class EditProfileViewModel: ObservableObject {
    @Published var didEditProfile = false
    private let userService = UserService()
    
    @MainActor
    func editUser(withUid uid: String, username: String, bio: String, completion: @escaping() -> Void) async throws {
        do {
            try await userService.editUser(withUid: uid, username: username, bio: bio) {
                self.didEditProfile = true
                completion()
            }
        } catch {
            print("DEBUG: Failed to edit user with error \(error.localizedDescription)")
            self.didEditProfile = false
        }
    }
}
