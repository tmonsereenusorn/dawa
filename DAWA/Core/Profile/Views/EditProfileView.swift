import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State private var username = ""
    @State private var bio = ""
    @Binding var user: User
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = EditProfileViewModel()
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    @State private var usernameError: String?
    @State private var bioError: String?
    
    var body: some View {
        ZStack {
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
            .blur(radius: viewModel.errorMessage != nil ? 5 : 0)
            .disabled(viewModel.errorMessage != nil)
            
            // Error view overlay if there is an error message
            if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    viewModel.errorMessage = nil // Dismiss error message
                }
                .zIndex(1) // Ensure the error message is shown above other content
            }
        }
    }
}

extension EditProfileView {
    var headerView: some View {
        HStack {
            Button { mode.wrappedValue.dismiss() } label: { Text("Cancel").font(.caption).foregroundColor(Color.theme.secondaryText) }
            Spacer()
            Text("Edit Profile").foregroundColor(Color.theme.primaryText).font(.headline)
            Spacer()
            Button {
                Task {
                    try await viewModel.editUser(withUid: self.user.id, username: username, bio: bio)
                    if let updatedUser = contentViewModel.currentUser {
                        self.user = updatedUser
                    }
                }
            } label: { Text("Save").font(.caption).foregroundColor(Color.theme.secondaryText) }
        }
        .padding(.vertical, 10)
        .onReceive(viewModel.$didEditProfile) { success in if success { mode.wrappedValue.dismiss() } }
    }

    var profileImageInput: some View {
        PhotosPicker(selection: $viewModel.selectedItem) {
            ZStack(alignment: .bottomTrailing) {
                if let image = viewModel.profileImage {
                    image.resizable().modifier(ProfileImageModifier())
                } else {
                    CircularProfileImageView(user: user, size: .xLarge)
                }
                
                ZStack {
                    Circle().fill(Color.theme.background).frame(width: 24, height: 24)
                    Image(systemName: "camera.circle.fill").foregroundColor(Color.theme.primaryText).frame(width: 18, height: 18)
                }
            }
        }
        .padding(.vertical)
    }

    var usernameInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Username")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            HStack {
                Text("@").font(.system(size: 20)).foregroundColor(Color.theme.primaryText)
                
                TextField("Enter a new username", text: $username)
                    .modifier(TextFieldModifier())
                    .autocapitalization(.none)
                    .onChange(of: username) { newValue in
                        self.username = newValue.filter { !$0.isWhitespace } // Remove all whitespace characters
                        if newValue.count > ProfileConstants.maxUsernameLength {
                            self.usernameError = "Username cannot exceed \(ProfileConstants.maxUsernameLength) characters."
                        } else if newValue.count < ProfileConstants.minUsernameLength {
                            self.usernameError = "Username must contain at least \(ProfileConstants.minUsernameLength) characters."
                        } else {
                            self.usernameError = nil // Clear the error if the input is valid
                        }
                    }
            }
            
            // Show error message if username is too long
            if let usernameError = usernameError {
                Text(usernameError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
    }

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
                .onChange(of: bio) { newValue in
                    if newValue.count <= ProfileConstants.maxBioLength {
                        self.bioError = nil // Clear the error if the input is valid
                    } else {
                        self.bioError = "Bio cannot exceed \(ProfileConstants.maxBioLength) characters."
                    }
                }

            // Show error message if bio is too long
            if let bioError = bioError {
                Text(bioError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
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
