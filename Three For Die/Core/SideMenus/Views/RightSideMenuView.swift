//
//  RightSideMenuView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/7/23.
//

import SwiftUI

struct RightSideMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if let user = authViewModel.currentUser {
            VStack (alignment: .leading) {
                VStack(alignment: .leading) {
                    Circle()
                        .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullname)
                            .font(.headline)
                        
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                ForEach(RightSideMenuViewModel.allCases, id: \.rawValue) { option in
                    if option == .profile {
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            RightSideMenuRowView(option: option)
                        }
                    } else if option == .logout {
                        Button {
                            authViewModel.signOut()
                        } label: {
                            RightSideMenuRowView(option: option)
                                .foregroundColor(.red)
                        }
                    } else if option == .delete {
                        Button {
                            Task {
                                try await authViewModel.deleteAccount()
                            }
                        } label: {
                            RightSideMenuRowView(option: option)
                                .foregroundColor(.red)
                        }
                    } else {
                        
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct RightSideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        RightSideMenuView()
    }
}
