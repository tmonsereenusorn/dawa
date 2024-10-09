import SwiftUI

struct GroupInviteRowView: View {
    let groupInvite: GroupInvite
    @StateObject var viewModel = GroupInviteRowViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        if let group = groupInvite.group {
            HStack(spacing: 15) {
                // Group Image
                SquareGroupImageView(group: group, size: .medium)
                
                // Group Details
                VStack(alignment: .leading, spacing: 5) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text("@\(group.handle)")  // Group handle
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Buttons placed side by side
                HStack(spacing: 10) {
                    Button {
                        Task {
                            groupsViewModel.fetchedGroups = false
                            try await viewModel.acceptGroupInvitation(groupInvite: groupInvite)
                            await groupsViewModel.fetchUserGroups()
                        }
                    } label: {
                        Text("Confirm")
                            .bold()
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8) // Add some horizontal padding for better button size
                            .background(Color.theme.appTheme)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        Task {
                            try await viewModel.deleteGroupInvitation(groupInvite: groupInvite)
                        }
                    } label: {
                        Text("Delete")
                            .bold()
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8) // Add some horizontal padding for better button size
                            .background(Color.theme.secondaryBackground)
                            .foregroundColor(Color.theme.primaryText)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color.theme.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            .contentShape(Rectangle())
        }
    }
}
