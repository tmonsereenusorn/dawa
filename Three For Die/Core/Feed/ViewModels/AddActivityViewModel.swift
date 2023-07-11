//
//  AddActivityViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation

class AddActivityViewModel: ObservableObject {
    let service = ActivityService()
    
    func addActivity(title: String, location: String, notes: String, numRequired: String, category: String) async throws {
        do {
            try await service.uploadActivity(title: title, location: location, notes: notes, numRequired: numRequired, category: category)
        } catch {
            print("DEBUG: Failed to upload activity with error \(error.localizedDescription)")
        }
    }
}
