//
//  VerifyEmailView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/28/23.
//

import SwiftUI
import Combine

struct VerifyEmailView: View {
    let timer = Timer.publish(every: 5, on: .main, in: .common)
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = VerifyEmailViewModel()
    @State private var timerCancellable: Cancellable? = nil
    @State private var isSendingEmail = false

    var body: some View {
        VStack {
            Image("dawa_login_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            
            Spacer()
            
            VStack {
                Text("Verify your email")
                    .font(.largeTitle)
                
                Text("A verification link has been sent to \(contentViewModel.currentUser?.email ?? "your email").")
                    .font(.footnote)
            }
            
            VStack {
                Button {
                    isSendingEmail = true
                    Task {
                        try await viewModel.sendVerificationEmail()
                        isSendingEmail = false
                    }
                } label: {
                    HStack {
                        if isSendingEmail {
                            ProgressView()
                        }
                        Text(isSendingEmail ? "Sending..." : "Resend Email")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top, 24)
            }
            
            VStack {
                Button {
                    viewModel.signOut()
                } label: {
                    HStack {
                        Text("Sign out")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top, 24)
            }
            
            Spacer()
        }
        .onAppear {
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
                        stopTimer()
                    }
                }
            }
        }
        .onDisappear {
            // Stop timer if the view is dismissed
            stopTimer()
        }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}


//struct VerifyEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        VerifyEmailView()
//    }
//}


