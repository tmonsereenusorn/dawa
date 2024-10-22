import Foundation
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    func createUser(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AuthService.shared.createUser(withEmail: email, password: password, username: username)
        } catch let error as AppError {
            self.errorMessage = error.localizedDescription
        } catch let error as NSError {
            let authErrorCode = AuthErrorCode.Code(rawValue: error.code)
            let authError = AuthError(authErrorCode: authErrorCode ?? .userNotFound) // Convert to custom AuthError
            self.errorMessage = authError.description
        } catch {
            self.errorMessage = "An unknown error occurred. Please try again."
        }
    }
}
