//
//  CreateGroupViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation
import SwiftUI
import PhotosUI

protocol CreateGroupFormProtocol {
    var formIsValid: Bool { get }
}

class CreateGroupViewModel: ObservableObject {
    @Published var groupId: String?
    @Published var didCreateGroup = false
    @Published var showGroupHandleErrorMessage = false
    @Published var errorMessage: String?
    
    // Properties for handling image selection
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    
    @Published var groupImage: Image?
    private var groupUIImage: UIImage?

    let service = GroupService()
    
    @MainActor
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        self.groupUIImage = uiImage
        self.groupImage = Image(uiImage: uiImage)
    }
    
    @MainActor
    func createGroup(name: String, handle: String) async throws {
        do {
            self.groupId = try await GroupService.createGroup(groupName: name, handle: handle.lowercased(), uiImage: groupUIImage)
            self.didCreateGroup = true
        } catch let error as AppError {
            self.errorMessage = error.localizedDescription
            self.didCreateGroup = false
        } catch {
            self.errorMessage = "An unexpected error occurred. Please try again."
            self.didCreateGroup = false
        }
    }
}
