//
//  RightSideMenuView.swift
//  DAWA
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
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundColor(Color.theme.primaryText)
                    }
                }
                .padding()
                
                ForEach(RightSideMenuRow.allCases, id: \.rawValue) { option in
                    if option == .profile {
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            RightSideMenuRowView(option: option, color: Color.theme.primaryText)
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
            .frame(width: getRect().width - 90)
            .frame(maxHeight: .infinity)
            .background(
                Color.theme.background
                    .opacity(0.04)
                    .ignoresSafeArea(.container, edges: .vertical)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//
//struct RightSideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        RightSideMenuView()
//    }
//}
