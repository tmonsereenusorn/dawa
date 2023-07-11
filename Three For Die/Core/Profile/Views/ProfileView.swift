//
//  ProfileView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/23/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView
            
            actionButtons
            
            userInfoDetails
            
            Spacer()
        }
        .navigationBarHidden(true)
        
//        if let user = viewModel.currentUser {
//            List {
//                Section {
//                    HStack {
//                        Text(user.initials)
//                            .font(.title)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.white)
//                            .frame(width: 72, height: 72)
//                            .background(Color(.systemGray3))
//                            .clipShape(Circle())
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(user.fullname)
//                                .fontWeight(.semibold)
//                                .padding(.top, 4)
//                            Text(user.email)
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//
//                Section("General") {
//                    HStack {
//                        SettingsRowView(imageName: "gear",
//                                        title: "Version",
//                                        tintColor: Color(.systemGray))
//                        Spacer()
//                        Text("1.0.0")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
//
//                Section("Account") {
//                    Button {
//                        viewModel.signOut()
//                    } label: {
//                        SettingsRowView(imageName: "arrow.left.circle.fill",
//                                        title: "Sign Out",
//                                        tintColor: .red)
//                    }
//
//                    Button {
//                        print("Delete Account...")
//                    } label: {
//                        SettingsRowView(imageName: "xmark.circle.fill",
//                                        title: "Delete Account",
//                                        tintColor: .red)
//                    }
//                }
//            }
//        }
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}

extension ProfileView {
    var headerView: some View {
        ZStack(alignment: .bottomLeading) {
            Color(.systemBlue)
                .ignoresSafeArea()
                
            VStack {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(.white)
                        .offset(x: 16, y: 12)
                }
                
                Circle()
                    .frame(width: 72, height: 72)
                .offset(x: 16, y: 24)
            }
        }
        .frame(height: 96)
    }
    
    var actionButtons: some View {
        HStack(spacing: 12) {
            Spacer()
            
            Button {
                
            } label: {
                Text("Edit Profile")
                    .font(.subheadline).bold()
                    .frame(width: 120, height: 32)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
                    .foregroundColor(.black)
            }
        }
        .padding(.trailing)
    }
    
    var userInfoDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(user.fullname)
                .font(.title2).bold()
            
            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Bio here")
                .font(.subheadline)
                .padding(.vertical)
        }
        .padding(.horizontal)
    }
}
