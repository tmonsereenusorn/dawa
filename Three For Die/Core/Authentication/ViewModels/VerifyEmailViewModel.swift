//
//  VerifyEmailViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/8/23.
//

import Foundation

class VerifyEmailViewModel: ObservableObject {
    
    func sendVerificationEmail() async throws {
        do {
            try await AuthService.shared.sendVerificationEmail()
        } catch {
            print("DEBUG: Sending email failed with error \(error.localizedDescription)")
        }
    }
    
    func refreshUser() async throws {
        do {
            try await AuthService.shared.refreshUser()
        } catch {
            print("DEBUG: Refreshing user failed with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signOut() {
        AuthService.shared.signOut()
    }
}
