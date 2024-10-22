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
    @State private var isExpanded = false
    
    init(group: Groups) {
        self._group = State(initialValue: group)
    }
    
    private var isCurrentUserOwner: Bool {
        guard let currentUser = contentViewModel.currentUser else { return false }
        return group.memberList?.contains(where: { $0.id == currentUser.id && ($0.permissions == "Owner") }) ?? false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SquareGroupImageView(group: group, size: .medium)
                
                Text(group.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(Color.theme.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color.theme.primaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding()
            .background {
                if (groupsViewModel.currSelectedGroup?.id == group.id) {
                    Color.theme.secondaryText
                }
                else if (isExpanded) {
                    Color.theme.background
                } else {
                    Color.clear
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    NavigationLink {
                        GroupView(group: $group)
                    } label: {
                        Text("View Group")
                            .foregroundColor(Color.theme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    if isCurrentUserOwner {
                        Button {
                            Task {
                                if try await GroupService.deleteGroup(groupId: group.id) {
                                    await groupsViewModel.fetchUserGroups()
                                }
                            }
                        } label: {
                            Text("Delete group")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        }
                    } else {
                        Button {
                            Task {
                                if try await viewModel.leaveGroup(groupId: group.id) {
                                    await groupsViewModel.fetchUserGroups()
                                }
                            }
                        } label: {
                            Text("Leave group")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.theme.background)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(groupsViewModel.currSelectedGroup?.id == group.id ? Color.theme.secondaryText : Color.clear )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .animation(.easeInOut, value: isExpanded)
    }
}

//#Preview {
//    GroupRowView(group: Groups.MOCK_GROUP)
//}
