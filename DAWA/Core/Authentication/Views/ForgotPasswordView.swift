import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    
    @State private var isLoading = false
    @State private var isButtonDisabled = false
    @State private var remainingTime = 30
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            VStack {
                // DAWA logo
                Image("dawa_login_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 60)
                    .padding(.bottom, 16)
                
                Text("Forgot Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                // Email input field
                TextField("Enter your email address", text: $viewModel.email)
                    .autocapitalization(.none)
                    .modifier(TextFieldModifier())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                // Send password reset button
                Button {
                    sendPasswordReset()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isButtonDisabled ? "Wait \(remainingTime)s" : "Send Password Reset")
                            .modifier(ButtonModifier())
                    }
                }
                .frame(maxWidth: 180)
                .padding(.horizontal, 16)
                .disabled(isButtonDisabled || !viewModel.isValidEmail)
                .opacity(isButtonDisabled || !viewModel.isValidEmail ? 0.5 : 1.0)
                
                Spacer()
            }
            .padding()
            .background(Color.theme.background)
        }
    }
    
    // Function to send password reset and start the timer
    private func sendPasswordReset() {
        isLoading = true
        Task {
            do {
                try await viewModel.sendPasswordReset()
                isLoading = false
                startTimer()  // Start the timer after a successful reset
            } catch {
                isLoading = false
                print("Failed to send password reset")
            }
        }
    }
    
    // Timer logic
    private func startTimer() {
        isButtonDisabled = true
        remainingTime = 30  // Reset timer to 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            remainingTime -= 1
            if remainingTime <= 0 {
                timer?.invalidate()
                isButtonDisabled = false
            }
        }
    }
}

