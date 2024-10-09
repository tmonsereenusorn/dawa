import SwiftUI

class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    
    var isValidEmail: Bool {
        return !email.isEmpty && email.contains("@")
    }
    
    @MainActor
    func sendPasswordReset() async throws {
        try await AuthService.shared.sendPasswordReset(toEmail: email)
    }
}
