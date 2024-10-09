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
        VStack(spacing: 20) {
            headerView
            
            profileImageInput
            
            usernameInput
            
            bioInput
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            self.username = user.username
            self.bio = user.bio
        }
        .background(Color.theme.background)
    }
}

extension EditProfileView {
    // Header with cancel and save buttons
    var headerView: some View {
        HStack {
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
            
            Spacer()
            
            Text("Edit Profile")
                .foregroundColor(Color.theme.primaryText)
                .font(.headline)
            
            Spacer()
            
            Button {
                Task {
                    try await viewModel.editUser(withUid: self.user.id, username: username, bio: bio)
                    if let updatedUser = contentViewModel.currentUser {
                        self.user = updatedUser
                    }
                }
            } label: {
                Text("Save")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
        }
        .padding(.vertical, 10)
        .onReceive(viewModel.$didEditProfile) { success in
            if success {
                mode.wrappedValue.dismiss()
            }
        }
    }
    
    // Profile image picker with PhotosPicker
    var profileImageInput: some View {
        PhotosPicker(selection: $viewModel.selectedItem) {
            ZStack(alignment: .bottomTrailing) {
                if let image = viewModel.profileImage {
                    image
                        .resizable()
                        .modifier(ProfileImageModifier())
                } else {
                    CircularProfileImageView(user: user, size: .xLarge)
                }
                
                ZStack {
                    Circle()
                        .fill(Color.theme.background)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "camera.circle.fill")
                        .foregroundColor(Color.theme.primaryText)
                        .frame(width: 18, height: 18)
                }
            }
        }
        .padding(.vertical)
    }
    
    // Username input field
    var usernameInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Username")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            HStack {
                Text("@")
                    .font(.system(size: 20))
                    .foregroundColor(Color.theme.primaryText)
                
                TextField("Enter a new username", text: $username)
                    .modifier(TextFieldModifier())
                    .autocapitalization(.none)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // Bio input field
    var bioInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bio")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            TextField("Enter a new bio", text: $bio, axis: .vertical)
                .frame(minHeight: 80, maxHeight: 150, alignment: .top)
                .modifier(TextFieldModifier())
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
    }
}

// Profile image view modifier for consistent size and style
struct ProfileImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: 150, height: 150)
            .clipShape(Circle())
    }
}
