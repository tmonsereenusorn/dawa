//
//  EditGroupViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 10/21/23.
//

import Foundation
import SwiftUI
import PhotosUI

class EditGroupViewModel: ObservableObject {
    @Published var group: Groups?
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    
    @Published var groupImage: Image?
    private var groupUIImage: UIImage?
    
    @Published var didEditGroup = false
    @Published var showGroupHandleErrorMessage = false
    
    @MainActor
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        self.groupUIImage = uiImage
        self.groupImage = Image(uiImage: uiImage)
    }
    
    @MainActor
    func editGroup(withGroupId groupId: String, name: String, handle: String) async throws {
        do {
            try await GroupService.editGroup(withGroupId: groupId, name: name, handle: handle.lowercased(), uiImage: groupUIImage ?? nil)
            self.group = try await GroupService.fetchGroup(groupId: groupId)
            self.didEditGroup = true
        } catch AppError.groupHandleAlreadyExists {
            self.showGroupHandleErrorMessage = true
            self.didEditGroup = false
            print("Group handle already exists. Please choose a different handle.")
        } catch {
            print("DEBUG: Failed to edit group with error \(error.localizedDescription)")
            self.didEditGroup = false
        }
    }
}
