import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var usernameError: String?
    @State private var passwordError: String?
    @State private var emailError: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
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
                    // Email Input with Stanford Domain Validation
                    VStack(spacing: 2) {
                        TextField("Enter your email address", text: $email)
                            .autocapitalization(.none)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 24)
                            .onChange(of: email) { newValue in
                                if !newValue.hasSuffix("@stanford.edu") {
                                    self.emailError = "You must sign up with a Stanford email (@stanford.edu)"
                                } else {
                                    self.emailError = nil // Clear the error if the input is valid
                                }
                            }
                        
                        // Display validation error if present
                        if let emailError = emailError {
                            Text(emailError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 24)
                        }
                    }
                    
                    // Username Input with Validation
                    VStack(spacing: 2) {
                        TextField("Choose a username", text: $username)
                            .autocapitalization(.none)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 24)
                            .onChange(of: username) { newValue in
                                if newValue.count > ProfileConstants.maxUsernameLength {
                                    self.usernameError = "Username cannot exceed \(ProfileConstants.maxUsernameLength) characters."
                                } else if newValue.count < ProfileConstants.minUsernameLength {
                                    self.usernameError = "Username must contain at least \(ProfileConstants.minUsernameLength) characters."
                                } else {
                                    self.usernameError = nil // Clear the error if the input is valid
                                }
                            }
                        
                        // Display validation error if present
                        if let usernameError = usernameError {
                            Text(usernameError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 24)
                        }
                    }
                    
                    // Password Input with Validation
                    VStack(spacing: 2) {
                        SecureField("Create a password", text: $password)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 24)
                            .onChange(of: password) { newValue in
                                if newValue.count > ProfileConstants.maxPasswordLength {
                                    self.passwordError = "Password cannot exceed \(ProfileConstants.maxPasswordLength) characters."
                                } else if newValue.count < ProfileConstants.minPasswordLength {
                                    self.passwordError = "Password must contain at least \(ProfileConstants.minPasswordLength) characters."
                                } else {
                                    self.passwordError = nil // Clear the error if the input is valid
                                }
                            }
                        
                        // Display validation error if present
                        if let passwordError = passwordError {
                            Text(passwordError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 24)
                        }
                    }
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .modifier(TextFieldModifier())
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 10)
                .blur(radius: (viewModel.isLoading || viewModel.errorMessage != nil) ? 5.0 : 0)
                
                // Sign Up button
                Button {
                    if formIsValid {
                        Task {
                            try await viewModel.createUser(email: email, password: password, username: username)
                        }
                    }
                } label: {
                    Text("Sign Up")
                        .modifier(ButtonModifier())
                }
                .disabled(!formIsValid || viewModel.isLoading)
                .opacity((!formIsValid || viewModel.isLoading) ? 0.5 : 1.0)
                
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

// View Extension for form validation
extension SignUpView {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.hasSuffix("@stanford.edu") // Check for Stanford email
        && password.count >= ProfileConstants.minPasswordLength
        && password.count <= ProfileConstants.maxPasswordLength
        && confirmPassword == password
        && username.count >= ProfileConstants.minUsernameLength
        && username.count <= ProfileConstants.maxUsernameLength
    }
}
