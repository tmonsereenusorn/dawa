//
//  ContentView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/20/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if let userSession = viewModel.userSession {
                if userSession.isEmailVerified {
                    FeedView()
                } else {
                    VerifyEmailView()
                }
            } else {
                LoginView()
            }
        }
    }
}
