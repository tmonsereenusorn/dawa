//
//  RightSideMenuView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/7/23.
//

import SwiftUI

struct RightSideMenuView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = RightSideMenuViewModel()
    
    var body: some View {
        if let user = contentViewModel.currentUser {
            VStack (alignment: .leading) {
                VStack(alignment: .leading) {
                    CircularProfileImageView(user: user, size: .medium)
                        .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullname)
                            .font(.headline)
                        
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                ForEach(RightSideMenuRow.allCases, id: \.rawValue) { option in
                    if option == .profile {
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            RightSideMenuRowView(option: option, color: .white)
                        }
                    } else if option == .logout {
                        Button {
                            viewModel.signOut()
                        } label: {
                            RightSideMenuRowView(option: option, color: .red)
                        }
                    } else if option == .delete {
                        Button {
                            Task {
                                try await viewModel.deleteAccount()
                            }
                        } label: {
                            RightSideMenuRowView(option: option, color: .red)
                        }
                    } else {
                        
                    }
                }
                
                Spacer()
            }
        }
    }
}
//
//struct RightSideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        RightSideMenuView()
//    }
//}
