import SwiftUI

struct RightSideMenuView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = RightSideMenuViewModel()

    // State variables for confirmation dialogs
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        if let user = contentViewModel.currentUser {
            VStack(alignment: .leading) {
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
                            showLogoutConfirmation = true
                        } label: {
                            RightSideMenuRowView(option: option, color: .red)
                        }
                    } else if option == .delete {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            RightSideMenuRowView(option: option, color: .red)
                        }
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
            // Logout confirmation dialog
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    viewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
            // Delete account confirmation dialog
            .confirmationDialog("Are you sure you want to delete your account? This action is irreversible.", isPresented: $showDeleteConfirmation) {
                Button("Delete Account", role: .destructive) {
                    Task {
                        try await viewModel.deleteAccount()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
