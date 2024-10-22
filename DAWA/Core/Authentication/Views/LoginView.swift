import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                    }
                
                VStack {
                    Spacer()
                    
                    Image("dawa_login_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding()
                    
                    // Form fields
                    VStack {
                        TextField("Enter your email address", text: $email)
                            .autocapitalization(.none)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 24)
                        
                        SecureField("Enter your password", text: $password)
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
                        if formIsValid {
                            Task { try await viewModel.login(withEmail: email, password: password) }
                        }
                    } label: {
                        Text("Login")
                            .modifier(ButtonModifier())
                    }
                    .disabled(!formIsValid || viewModel.isLoading)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    
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
                .blur(radius: (viewModel.isLoading || viewModel.errorMessage != nil) ? 5.0 : 0)
                
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                // Error view overlay if there is an error message
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        viewModel.errorMessage = nil // Dismiss error message
                    }
                    .zIndex(1) // Ensure the error message is shown above other content
                }
            }
            
        }
    }
}

// View Extension for form validation
extension LoginView {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}
