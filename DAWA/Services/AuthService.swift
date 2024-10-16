//
//  AuthService.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/8/23.
//

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
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await loadUserData()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await uploadUserData(email: email, username: username, id: result.user.uid)
            try await loadUserData()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            UserService.shared.currentUser = nil
            InboxService.shared.reset()
            InviteService.shared.reset()
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteAccount() async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            try await Firestore.firestore().collection("users").document(uid).delete()
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            UserService.shared.currentUser = nil
        } catch {
            print("DEBUG: Failed to delete user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func sendVerificationEmail() async throws {
        do {
            try await self.userSession?.sendEmailVerification()
        } catch {
            print("DEBUG: Sending email failed with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func refreshUserVerificationStatus() async throws {
        do {
            try await self.userSession?.reload()
            
            // If user has verified email, add user to Stanford group
            if let user = Auth.auth().currentUser, user.isEmailVerified {
                let stanfordGroup = try await GroupService.findGroupByHandle("stanford")
                
                if stanfordGroup == nil {
                    let _ = try await GroupService.createGroup(groupName: "Stanford University", handle: "stanford")
                } else {
                    try await GroupService.joinGroup(uid: user.uid, groupId: stanfordGroup!.id, enableNotifications: false)
                }
            }
            
            self.userSession = Auth.auth().currentUser
        } catch {
            print("DEBUG: Error refreshing user: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func sendPasswordReset(toEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("DEBUG: Password reset email sent to \(email)")
        } catch {
            print("DEBUG: Failed to send password reset email with error \(error.localizedDescription)")
            throw error
        }
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
