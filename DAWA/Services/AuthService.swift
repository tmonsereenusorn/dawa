import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

class AuthService {
    @Published var userSession: FirebaseAuth.User?
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task { try await loadUserData() }
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        try await loadUserData()
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, username: String) async throws {
        // Validate username
        if username.count > ProfileConstants.maxUsernameLength { throw AppError.usernameTooLong }
        if username.count < ProfileConstants.minUsernameLength { throw AppError.usernameTooShort }
        
        // Validate password
        if password.count > ProfileConstants.maxPasswordLength { throw AppError.passwordTooLong }
        if password.count < ProfileConstants.minPasswordLength { throw AppError.passwordTooShort }
        
        // Validate Stanford email
        if !email.hasSuffix("@stanford.edu") { throw AppError.notStanfordEmail }
        
        // Check if the username already exists
        let querySnapshot = try await Firestore.firestore()
            .collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()
        
        if !querySnapshot.isEmpty {
            throw AppError.usernameAlreadyExists
        }
        
        // Create user, will throw NSError if fails
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = result.user
        
        // Upload user data to Firestore
        try await uploadUserData(email: email, username: username, id: result.user.uid)
        try await loadUserData()
    }
    
    @MainActor
    func signOut() throws {
        try Auth.auth().signOut()
        self.userSession = nil
        UserService.shared.currentUser = nil
        InboxService.shared.reset()
        InviteService.shared.reset()
    }
    
    @MainActor
    func deleteAccount() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection("users").document(uid).delete()
        try await Auth.auth().currentUser?.delete()
        self.userSession = nil
        UserService.shared.currentUser = nil
    }
    
    @MainActor
    func sendVerificationEmail() async throws {
        try await self.userSession?.sendEmailVerification()
    }
    
    @MainActor
    func refreshUserVerificationStatus() async throws {
        try await self.userSession?.reload()
        
        // If user has verified email, add user to Stanford group
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            let stanfordGroup = try await GroupService.findGroupByHandle("stanford")
            
            if stanfordGroup == nil {
                let _ = try await GroupService.createGroup(groupName: "Stanford University", handle: "stanford", uiImage: nil)
            } else {
                try await GroupService.joinGroup(uid: user.uid, groupId: stanfordGroup!.id, enableNotifications: false)
            }
        }
        
        self.userSession = Auth.auth().currentUser
    }
    
    @MainActor
    func sendPasswordReset(toEmail email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // Private functions
    
    @MainActor
    private func uploadUserData(email: String, username: String, id: String) async throws {
        let user = User(email: email,
                        username: username,
                        bio: "",
                        profileImageUrl: nil)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
    }
    
    @MainActor
    private func loadUserData() async throws {
        try await UserService.shared.fetchCurrentUser()
    }
}
