//
//  EditProfileViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/2/23.
//

import Foundation
import SwiftUI
import PhotosUI

class EditProfileViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    
    @Published var profileImage: Image?
    
    @Published var didEditProfile = false
    private let userService = UserService()
    
    @MainActor
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        self.profileImage = Image(uiImage: uiImage)
    }
    
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