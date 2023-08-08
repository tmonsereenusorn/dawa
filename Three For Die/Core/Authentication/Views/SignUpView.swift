//
//  SignUpView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/20/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // Logo (Placeholder title for now)
            Text("3 For Die")
                .font(.largeTitle)
            
            // Form fields
            VStack(spacing: 24) {
                InputView(text: $viewModel.email,
                          title: "Email Address",
                          placeholder: "name@example.com")
                .autocapitalization(.none)
                
                InputView(text: $viewModel.username,
                          title: "Username",
                          placeholder: "Enter your username")
                .autocapitalization(.none)
                
                InputView(text: $viewModel.fullname,
                          title: "Full Name",
                          placeholder: "Enter your name")
                
                InputView(text: $viewModel.password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                InputView(text: $viewModel.confirmPassword,
                          title: "Confirm Password",
                          placeholder: "Confirm your password",
                          isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Sign Up button
            Button {
                if viewModel.formIsValid {
                    Task { try await viewModel.createUser() }
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top, 24)
            .disabled(!viewModel.formIsValid)
            .opacity(viewModel.formIsValid ? 1.0 : 0.5)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Log in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
            }

        }
    }
}
