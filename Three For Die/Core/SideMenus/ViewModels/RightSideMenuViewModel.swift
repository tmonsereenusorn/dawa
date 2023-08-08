//
//  RightSideMenuViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/8/23.
//

import Foundation

class RightSideMenuViewModel: ObservableObject {
    
    @MainActor
    func signOut() {
        AuthService.shared.signOut()
    }
    
    @MainActor
    func deleteAccount() async throws {
        do {
            try await AuthService.shared.deleteAccount()
        } catch {
            print("DEBUG: Failed to delete user with error \(error.localizedDescription)")
        }
    }
}
