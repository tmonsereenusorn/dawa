//
//  SignUpView.swift
//  DAWA
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
            Spacer()
            
            Image("dawa_login_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            
            // Form fields
            VStack {
                TextField("Enter your email address", text: $viewModel.email)
                    .autocapitalization(.none)
                    .modifier(TextFieldModifier())
                    .padding(.horizontal, 24)
                
                TextField("Choose a username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .modifier(TextFieldModifier())
                    .padding(.horizontal, 24)
                
                SecureField("Create a password", text: $viewModel.password)
                    .modifier(TextFieldModifier())
                    .padding(.horizontal, 24)
                
                SecureField("Confirm your password", text: $viewModel.confirmPassword)
                    .modifier(TextFieldModifier())
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 10)
            
            // Sign Up button
            Button {
                if viewModel.formIsValid {
                    Task { try await viewModel.createUser() }
                }
            } label: {
                Text("Sign Up")
                    .modifier(ButtonModifier())
            }
            
            Spacer()
            
            Divider()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                        .foregroundColor(Color.theme.secondaryText)
                    
                    Text("Log In")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.primaryText)
                }
                .font(.footnote)
            }
            .padding(.vertical, 16)

        }
        .background(Color.theme.background)
    }
}
