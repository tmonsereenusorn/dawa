//
//  ProfileView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/23/23.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var mode
    private let user: User
    @State private var editingProfile: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView

            userProfile

            userInfoDetails

            Spacer()
        }
        .navigationBarHidden(true)
        .background(.black)
        .popover(isPresented: $editingProfile) {
            EditProfileView(user: self.user)
        }
        
//        if let user = viewModel.currentUser {
//            List {
//                Section {
//                    HStack {
//                        Text("hi")
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
//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(user: User.MOCK_USER)
//    }
//}

extension ProfileView {
//    var headerView: some View {
//            ZStack(alignment: .bottomLeading) {
//                Color(.systemBlue)
//                    .ignoresSafeArea()
//
//                VStack {
//                    Button {
//
//                    } label: {
//                        Image(systemName: "arrow.left")
//                            .resizable()
//                            .frame(width: 20, height: 16)
//                            .foregroundColor(.white)
//                            .offset(x: 16, y: 12)
//                    }
//
//                    Circle()
//                        .frame(width: 72, height: 72)
//                    .offset(x: 16, y: 24)
//                }
//            }
//            .frame(height: 96)
//        }
    
    var headerView: some View {
        HStack(alignment: .top) {
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20, height: 16)
                    .foregroundColor(.white)
                    .offset(x: 16, y: 12)
            }
            
            Spacer()
            
            Button {
                editingProfile.toggle()
            } label: {
                Text("Edit Profile")
                    .font(.subheadline).bold()
                    .frame(width: 120, height: 32)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
                    .foregroundColor(.white)
            }
        }
        .padding(10)
    }
    
    var userProfile: some View {
        HStack {
            Spacer()
            
            VStack {
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                Text("@\(user.username)")
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    var userInfoDetails: some View {
        VStack {
            Text("About")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Bio here")
                .font(.caption)
                .padding(.vertical, 4)
                .foregroundColor(.white)
        }
        .padding(12)
        
    }
}
