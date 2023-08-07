//
//  ProfileView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/23/23.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var mode
    @State private var user: User
    @State private var editingProfile: Bool = false
    
    init(user: User) {
        _user = State(initialValue: user)
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
            EditProfileView(user: $user)
        }
    }
}

extension ProfileView {
    
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
                CircularProfileImageView(user: user, size: .xLarge)
                
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

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(user: User.MOCK_USER)
//    }
//}
