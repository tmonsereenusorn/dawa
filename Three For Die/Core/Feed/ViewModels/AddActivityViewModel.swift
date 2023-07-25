//
//  AddActivityViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation

protocol AddActivityFormProtocol {
    var formIsValid: Bool { get }
}

class AddActivityViewModel: ObservableObject {
    @Published var didUploadActivity = false
    let service = ActivityService()
    
    @MainActor
    func addActivity(title: String, location: String, notes: String, numRequired: Int, category: String) async throws {
        do {
            try await service.uploadActivity(title: title, location: location, notes: notes, numRequired: numRequired, category: category)
            self.didUploadActivity = true
        } catch {
            print("DEBUG: Failed to upload activity with error \(error.localizedDescription)")
            self.didUploadActivity = false
        }
    }
}
