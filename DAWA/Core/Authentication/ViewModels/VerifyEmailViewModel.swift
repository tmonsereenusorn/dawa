//
//  VerifyEmailViewModel.swift
//  DAWA
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
    
    func refreshUserVerificationStatus() async throws {
        do {
            try await AuthService.shared.refreshUserVerificationStatus()
        } catch {
            print("DEBUG: Refreshing user failed with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signOut() {
        AuthService.shared.signOut()
    }
}
