//
//  SignUpViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/8/23.
//

import Foundation
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    @Published var showAlert = false
    @Published var authError: AuthError?
    
    @MainActor
    func createUser() async throws {
        do {
            try await AuthService.shared.createUser(withEmail: email, password: password, username: username)
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            self.showAlert = true
            self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
        }
    }
}

extension SignUpViewModel: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
    }
}
