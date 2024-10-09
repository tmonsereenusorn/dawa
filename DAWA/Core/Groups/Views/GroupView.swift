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
    
    private var currentUserGroupMember: GroupMember? {
        guard let currentUser = contentViewModel.currentUser else { return nil }
        return group.memberList?.first(where: { $0.user?.id == currentUser.id })
    }

    private var isCurrentUserAdmin: Bool {
        return currentUserGroupMember?.isAdmin ?? false
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Navigation bar and notifications toggle
            HStack {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(Color.theme.primaryText)
                }
                
                Spacer()

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
                }
            }
            .padding(.bottom, 20)
            
            // Group Information
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
            .padding(.bottom, 20)

            // Admin Action Bar with consistent buttons
            if isCurrentUserAdmin {
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.editingGroup.toggle()
                    }) {
                        Text("Edit Group")
                            .font(.subheadline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                            .foregroundColor(Color.theme.primaryText)
                            .shadow(radius: 2)
                    }
                    
                    Button(action: {
                        viewModel.showMemberRequests.toggle()
                    }) {
                        Text("Member Requests")
                            .font(.subheadline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                            .foregroundColor(Color.theme.primaryText)
                            .shadow(radius: 2)
                    }
                }
                .frame(maxWidth: .infinity)  // Ensure buttons span the entire width
                .padding(.horizontal, 16)    // Padding on sides
                .padding(.vertical, 10)
            }

            Spacer()
            
        }
        .padding()
        .navigationBarHidden(true)
        .popover(isPresented: $viewModel.editingGroup) {
            EditGroupView(group: $group)
        }
        .sheet(isPresented: $viewModel.showMemberRequests) {
            MemberRequestsView(group: $group)
        }
        .onAppear {
            if let groupMember = currentUserGroupMember {
                viewModel.notificationsEnabled = groupMember.notificationsEnabled ?? false
            }
        }
    }
}
