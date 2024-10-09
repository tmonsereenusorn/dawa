//
//  LoginView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 6/21/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
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
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .modifier(TextFieldModifier())
                        .padding(.horizontal, 24)
                    
                    NavigationLink {
                        ForgotPasswordView()
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.top)
                            .padding(.trailing, 28)
                            .foregroundColor(Color.theme.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // Login button
                Button {
                    if viewModel.formIsValid {
                        Task { try await viewModel.login() }
                    }
                } label: {
                    Text("Login")
                        .modifier(ButtonModifier())
                }
                .disabled(!viewModel.formIsValid)
                .opacity(viewModel.formIsValid ? 1.0 : 0.5)
                
                Spacer()
                
                Divider()
                
                // Sign Up Button
                NavigationLink {
                    SignUpView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Text("Sign Up")
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
}

//struct Previews_LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
