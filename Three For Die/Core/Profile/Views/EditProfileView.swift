//
//  EditProfileView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/2/23.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State private var username = ""
    @State private var bio = ""
    @Binding var user: User
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = EditProfileViewModel()
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    var body: some View {
        VStack {
            headerView
            
            profileImageInput
            
            usernameInput
            
            bioInput
            
            Spacer()
        }
        .onAppear {
            self.username = user.username
            self.bio = user.bio
        }
        .background(.black)
    }
}

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
                                                 bio: bio)
                    if let updatedUser = contentViewModel.currentUser {
                        self.user = updatedUser
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
    
    var profileImageInput: some View {
        HStack {
            PhotosPicker(selection: $viewModel.selectedItem) {
                ZStack(alignment: .bottomTrailing) {
                    if let image = viewModel.profileImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: ProfileImageSize.xLarge.dimension, height: ProfileImageSize.xLarge.dimension)
                            .clipShape(Circle())
                    } else {
                        CircularProfileImageView(user: user, size: .xLarge)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "camera.circle.fill")
                            .foregroundColor(.black)
                            .frame(width: 18, height: 18)
                    }
                }
            }
        }
    }
    
    var usernameInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Username")
                .foregroundColor(Color(.white))
                .fontWeight(.semibold)
                .font(.footnote)
            HStack(spacing: 0) {
                Text("@")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Enter a new username", text: $username)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    Divider()
                        .background(.white)
                }
            }
            
        }
        .padding()
        .autocapitalization(.none)
    }
    
    var bioInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bio")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .font(.footnote)
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("Enter a new bio", text: $bio, axis: .vertical)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .frame(height: 60, alignment: .top)
                    .padding(5)
                    .fixedSize(horizontal: false, vertical: false)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(.gray), lineWidth: 1)
                    )
                    
            }
        }
        .padding()
        .autocapitalization(.none)
    }
    
}

struct ProfileImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: 180, height: 180)
            .clipShape(Circle())
    }
}

//struct EditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProfileView(user: User.MOCK_USER)
//    }
//}
