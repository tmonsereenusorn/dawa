import SwiftUI
import Combine

struct VerifyEmailView: View {
    let timer = Timer.publish(every: 5, on: .main, in: .common)
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = VerifyEmailViewModel()
    @State private var timerCancellable: Cancellable? = nil
    @State private var isSendingEmail = false
    
    @State private var isButtonDisabled = false
    @State private var remainingTime = 30  // Countdown timer starts at 30 seconds
    @State private var resendTimer: Timer?

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()  // Push content down from the top
                
                // DAWA logo
                Image("dawa_login_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 16)
                
                Text("Verify Your Email")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                Text("A verification link has been sent to \(contentViewModel.currentUser?.email ?? "your email").")
                    .font(.footnote)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                // Resend email button with timer
                Button {
                    sendVerificationEmail()
                } label: {
                    HStack {
                        if isSendingEmail {
                            ProgressView()
                        } else {
                            Text(isButtonDisabled ? "Wait \(remainingTime)s" : "Resend Email")
                                .modifier(ButtonModifier())
                        }
                    }
                    .frame(maxWidth: 180)
                    .padding(.horizontal, 16)
                }
                .disabled(isButtonDisabled || isSendingEmail)
                .opacity(isButtonDisabled || isSendingEmail ? 0.5 : 1.0)

                // Sign out button
                Button {
                    viewModel.signOut()
                } label: {
                    Text("Sign Out")
                        .modifier(ButtonModifier())
                        .frame(maxWidth: 180)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 16)

                Spacer()  // Push content upwards from the bottom
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.theme.background)
            .ignoresSafeArea()
        }
        .onAppear {
            startResendTimer()
            isSendingEmail = true
            Task {
                try await viewModel.sendVerificationEmail()
                isSendingEmail = false
            }
            
            timerCancellable = timer.autoconnect().sink { _ in
                Task {
                    try await viewModel.refreshUserVerificationStatus()
                    
                    // Check if the user's email is verified
                    if let userSession = contentViewModel.userSession, userSession.isEmailVerified {
                        // Stop the timer when email is verified
                        stopResendTimer()
                        stopTimer()
                    }
                }
            }
        }
        .onDisappear {
            // Stop timers if the view is dismissed
            stopResendTimer()
            stopTimer()
        }
    }
    
    // Function to send verification email and start timer
    private func sendVerificationEmail() {
        isSendingEmail = true
        Task {
            do {
                try await viewModel.sendVerificationEmail()
                isSendingEmail = false
                startResendTimer()  // Start the resend timer after sending the email
            } catch {
                isSendingEmail = false
                print("Failed to send verification email")
            }
        }
    }

    // Timer logic for resending email
    private func startResendTimer() {
        isButtonDisabled = true
        remainingTime = 30  // Reset timer to 30 seconds
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            remainingTime -= 1
            if remainingTime <= 0 {
                resendTimer?.invalidate()
                isButtonDisabled = false
            }
        }
    }
    
    // Stop the resend timer
    private func stopResendTimer() {
        resendTimer?.invalidate()
        resendTimer = nil
    }

    // Stop the email verification timer
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
