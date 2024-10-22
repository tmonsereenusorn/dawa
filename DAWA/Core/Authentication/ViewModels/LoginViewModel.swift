import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AuthService.shared.login(withEmail: email, password: password)
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
