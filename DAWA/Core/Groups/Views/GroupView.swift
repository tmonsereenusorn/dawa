import SwiftUI

struct GroupView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.presentationMode) var mode
    @Binding var group: Groups
    
    @StateObject private var viewModel: GroupViewModel
    
    init(group: Binding<Groups>) {
        self._group = group
        self._viewModel = StateObject(wrappedValue: GroupViewModel(group: group.wrappedValue))
    }
    
    // Extract logic for the current user from the contentViewModel
    private var currentUserGroupMember: GroupMember? {
        guard let currentUser = contentViewModel.currentUser else { return nil }
        return group.memberList?.first(where: { $0.user?.id == currentUser.id })
    }

    // Determine if the current user is an admin
    private var isCurrentUserAdmin: Bool {
        return currentUserGroupMember?.isAdmin ?? false
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(Color.theme.primaryText)
                        .offset(x: 16, y: 12)
                }
                
                Spacer()
                
                // Notifications Toggle
                if let groupMember = currentUserGroupMember {
                    Button {
                        Task {
                            await viewModel.toggleNotifications(for: groupMember)
                        }
                    } label: {
                        Image(systemName: viewModel.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.theme.primaryText)
                    }
                    .padding()
                }
                
                if isCurrentUserAdmin {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.editingGroup.toggle()
                        } label: {
                            Text("Edit Group")
                                .font(.subheadline).bold()
                                .frame(width: 120, height: 32)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
                                .foregroundColor(Color.theme.primaryText)
                        }

                        Button {
                            viewModel.showMemberRequests.toggle()
                        } label: {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color.theme.primaryText)
                                .padding()
                                .background(Color.theme.secondaryBackground)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    SquareGroupImageView(group: group, size: .xLarge)
                    
                    Text(group.name)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text("@\(group.handle)")
                        .foregroundColor(Color.theme.secondaryText)
                    
                    NavigationLink {
                        MemberListView(group: $group)
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(group.numMembers)")
                                .foregroundColor(.primary)
                            
                            if group.numMembers == 1 {
                                Text("member")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("members")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                }
                Spacer()
            }
            
            Spacer()
            
        }
        .padding()
        .navigationBarHidden(true)
        .background(Color.theme.background)
        .popover(isPresented: $viewModel.editingGroup) {
            EditGroupView(group: $group)
        }
        .sheet(isPresented: $viewModel.showMemberRequests) {
            MemberRequestsView(group: $group)
        }
        .onAppear {
            // Initialize the notificationsEnabled state based on the current user's settings
            if let groupMember = currentUserGroupMember {
                viewModel.notificationsEnabled = groupMember.notificationsEnabled ?? false
            }
        }
    }
}
