//
//  EditProfileViewModel.swift
//  DAWA
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
    private var profileUIImage: UIImage?
    
    @Published var didEditProfile = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    @MainActor
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        self.profileUIImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    @MainActor
    func editUser(withUid uid: String, username: String, bio: String) async throws {
        isLoading = true
        defer { isLoading = false }
        do {
            try await UserService.shared.editUser(withUid: uid, username: username, bio: bio, uiImage: profileUIImage ?? nil)
            self.didEditProfile = true
        } catch let error as AppError {
            self.errorMessage = error.localizedDescription
            self.didEditProfile = false
        } catch {
            self.errorMessage = "An unexpected error occurred. Please try again."
            self.didEditProfile = false
        }
    }
}
