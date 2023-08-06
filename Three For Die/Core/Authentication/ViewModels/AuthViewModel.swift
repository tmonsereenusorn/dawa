//
//  AuthViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/26/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    private let userService = UserService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
    @MainActor
    func signIn(withEmail email: String, password: String) async throws {
        do {
            try await userService.signIn(withEmail: email, password: password) { userSession in
                self.userSession = userSession
            }
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, fullname: String, username: String) async throws {
        do {
            try await userService.createUser(withEmail: email, password: password, fullname: fullname, username: username) { userSession in
                self.userSession = userSession
            }
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteAccount() async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            try await Firestore.firestore().collection("users").document(uid).delete()
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to delete user with error \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        await userService.fetchUser(withUid: uid) { user in
            self.currentUser = user
        }
    }
    
    func sendVerificationEmail() async throws {
        do {
            try await self.userSession?.sendEmailVerification()
        } catch {
            print("DEBUG: Sending email failed with error \(error.localizedDescription)")
        }
    }
    
    func refreshUser() async throws {
        do {
            try await self.userSession?.reload()
            self.userSession = Auth.auth().currentUser
        } catch {
            print("DEBUG: Error refreshing user: \(error.localizedDescription)")
        }
    }
}
