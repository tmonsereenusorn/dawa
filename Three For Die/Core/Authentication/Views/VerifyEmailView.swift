//
//  VerifyEmailView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/28/23.
//

import SwiftUI

struct VerifyEmailView: View {
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = VerifyEmailViewModel()
    
    var body: some View {
        VStack {
            // Logo (Placeholder title for now)
            Text("3 For Die")
                .font(.largeTitle)
            
            Spacer()
            
            VStack {
                Text("Verify your email")
                    .font(.largeTitle)
                
                Text("A verification link has been sent to \(contentViewModel.currentUser?.email ?? "your email").")
                    .font(.footnote)
            }
            
            VStack {
                Button {
                    Task { try await viewModel.sendVerificationEmail() }
                } label: {
                    HStack {
                        Text("Resend Email")
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
        .task {
            do {
                try await viewModel.sendVerificationEmail()
            } catch {
                print("Failed to send verification email")
            }
        }
        .onReceive(timer) { time in
            Task {
                try await viewModel.refreshUser()
            }
        }
    }
}

//struct VerifyEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        VerifyEmailView()
//    }
//}


