//
//  GroupRowView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct GroupRowView: View {
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = GroupRowViewModel()
    @State var group: Groups
    
    init(group: Groups) {
        self._group = State(initialValue: group)
    }
    
    private var isCurrentUserOwner: Bool {
        guard let currentUser = contentViewModel.currentUser else { return false }
        return group.memberList?.contains(where: { $0.id == currentUser.id && ($0.groupPermissions == "Owner") }) ?? false
    }
    
    var body: some View {
        HStack {
            SquareGroupImageView(group: group, size: .medium)
            
            Text(group.name)
                
            Spacer()
            
            Menu {
                NavigationLink {
                    GroupView(group: $group)
                } label: {
                    Text("View Group")
                }
                
                if isCurrentUserOwner {
                    Button(role: .destructive) {
                        Task {
                            if try await GroupService.deleteGroup(groupId: group.id) {
                                await groupsViewModel.fetchUserGroups()
                            }
                        }
                    } label: {
                        Text("Delete group")
                    }
                } else {
                    Button(role: .destructive) {
                        Task {
                            if try await viewModel.leaveGroup(groupId: group.id) {
                                await groupsViewModel.fetchUserGroups()
                            }
                        }
                    } label: {
                        Text("Leave group")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            
        }
        .foregroundColor(Color.theme.primaryText)
        .padding()
        .background(groupsViewModel.currSelectedGroup?.id == group.id ? Color.theme.secondaryText : Color.theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

//#Preview {
//    GroupRowView(group: Groups.MOCK_GROUP)
//}
