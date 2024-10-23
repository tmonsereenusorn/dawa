//
//  AddActivityViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation

protocol AddActivityFormProtocol {
    var formIsValid: Bool { get }
}

class AddActivityViewModel: ObservableObject {
    @Published var didUploadActivity = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    let service = ActivityService()
    
    @MainActor
    func addActivity(groupId: String, title: String, location: String, notes: String, numRequired: Int, category: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await service.uploadActivity(groupId: groupId, title: title, location: location, notes: notes, numRequired: numRequired, category: category)
            self.didUploadActivity = true
        } catch let error as AppError {
            self.errorMessage = error.localizedDescription
            self.didUploadActivity = false
        } catch {
            self.errorMessage = "An unknown error occurred. Please try again."
            self.didUploadActivity = false
        }
    }
}
