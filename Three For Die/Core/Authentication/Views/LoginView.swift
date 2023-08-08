//
//  LoginView.swift
//  Three For Die
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
                // Logo (Placeholder title for now)
                Text("3 For Die")
                    .font(.largeTitle)
                
                // Form fields
                VStack(spacing: 24) {
                    InputView(text: $viewModel.email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $viewModel.password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Login button
                Button {
                    if viewModel.formIsValid {
                        Task { try await viewModel.login() }
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!viewModel.formIsValid)
                .opacity(viewModel.formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                // Sign Up Button
                NavigationLink {
                    SignUpView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                }
            }
        }
        
    }
}

//struct Previews_LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
