//
//  EditProfileView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/2/23.
//

import SwiftUI

struct EditProfileView: View {
    @State private var username = ""
    @Binding var user: User
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel = EditProfileViewModel()
    
    var body: some View {
        VStack {
            headerView
            
            userProfileView
            
            Spacer()
        }
        .onAppear {
            self.username = user.username
        }
        .background(.black)
    }
}

//struct EditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProfileView(user: User.MOCK_USER)
//    }
//}

extension EditProfileView {
    var headerView: some View {
        HStack(alignment: .bottom) {
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .font(.caption)
            }
            
            Spacer()
            
            Text("Edit Profile")
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
            
            Button {
                Task {
                    try await viewModel.editUser(withUid: self.user.id,
                                                 username: username,
                                                 bio: "Sample bio") {
                        user.username = username
                    }
                }
            } label: {
                Text("Save")
                    .font(.caption)
            }
        }
        .onReceive(viewModel.$didEditProfile) { success in
            if success {
                mode.wrappedValue.dismiss()
            }
        }
        .padding(10)
    }
    
    var userProfileView: some View {
        HStack {
            Spacer()
            
            VStack {
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .foregroundColor(Color(.white))
                        .fontWeight(.semibold)
                        .font(.footnote)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Enter a new username", text: $username)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(.white)
                    }
                }
                .padding()
                .autocapitalization(.none)
            }
            
            Spacer()
        }
    }
    
}
