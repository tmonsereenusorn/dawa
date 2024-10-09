//
//  MemberListView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 10/30/23.
//

import SwiftUI

struct MemberListView: View {
    @StateObject var viewModel = MemberListViewModel()
    @Binding var group: Groups
    @Environment(\.presentationMode) var mode
    @State private var inviteMembers: Bool = false
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    private var isCurrentUserAdmin: Bool {
        guard let currentUser = contentViewModel.currentUser else { return false }
        return group.memberList?.contains(where: { $0.id == currentUser.id && ($0.permissions == "Admin" || $0.permissions == "Owner") }) ?? false
    }
    
    var body: some View {
        VStack() {
            VStack(spacing: 0) {
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
                    
                    Text("Members")
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Button () {
                        inviteMembers.toggle()
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.theme.primaryText)
                    }
                    .popover(isPresented: $inviteMembers) {
                        InviteUsersView(group: $group)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                    .padding(0)
                
            }
            
            List() {
                ForEach(group.memberList ?? [], id: \.id) { member in
                    Menu {
                        NavigationLink {
                            ProfileView(user: member.user!)
                        } label: {
                            Text("View profile")
                        }
                        
                        if isCurrentUserAdmin {
                            Menu("Change permissions") {
                                if member.permissions == "Admin" {
                                    Button {
                                        Task {
                                            if try await GroupService.changeGroupPermissions(groupId: group.id, forUserId: member.id, toPermission: "Member") {
                                                try await viewModel.refreshGroup(groupId: group.id)
                                                if let newGroup = viewModel.group {
                                                    if let index = groupsViewModel.groups.firstIndex(where: { $0.id == group.id }) {
                                                        groupsViewModel.groups[index] = newGroup
                                                    }
                                                    self.group = newGroup
                                                }
                                            }
                                        }
                                    } label: {
                                        Text("Member")
                                    }
                                }
                                
                                if member.permissions == "Member"{
                                    Button {
                                        Task {
                                            if try await GroupService.changeGroupPermissions(groupId: group.id, forUserId: member.id, toPermission: "Admin") {
                                                try await viewModel.refreshGroup(groupId: group.id)
                                                if let newGroup = viewModel.group {
                                                    if let index = groupsViewModel.groups.firstIndex(where: { $0.id == group.id }) {
                                                        groupsViewModel.groups[index] = newGroup
                                                    }
                                                    self.group = newGroup
                                                }
                                            }
                                        }
                                    } label: {
                                        Text("Admin")
                                    }
                                }
                            }
                            
                            if member.permissions != "Owner" {
                                Button(role: .destructive) {
                                    Task {
                                        if try await GroupService.leaveGroup(uid: member.id, groupId: group.id) {
                                            try await viewModel.refreshGroup(groupId: group.id)
                                            if let newGroup = viewModel.group {
                                                if let index = groupsViewModel.groups.firstIndex(where: { $0.id == group.id }) {
                                                    groupsViewModel.groups[index] = newGroup
                                                }
                                                self.group = newGroup
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Remove member")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            CircularProfileImageView(user: member.user!, size: .small)
                            Text(member.user?.username ?? "Username not found")
                                .foregroundColor(Color.theme.primaryText)
                                .font(.system(size: 16))
                            Spacer()
                            Text(member.permissions)
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.system(size: 12))
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
            }
            .listStyle(PlainListStyle())
            .refreshable {
                Task {
                    try await viewModel.refreshGroup(groupId: group.id)
                    if let newGroup = viewModel.group {
                        self.group = newGroup
                    }
                }
            }
            
            
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    MemberListView()
//}
