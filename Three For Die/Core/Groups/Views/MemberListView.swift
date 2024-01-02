//
//  MemberListView.swift
//  Three For Die
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
    @State var members: [User]
    
    private var isCurrentUserAdmin: Bool {
        guard let currentUser = contentViewModel.currentUser else { return false }
        return group.memberList?.contains(where: { $0.id == currentUser.id && ($0.groupPermissions == "Admin" || $0.groupPermissions == "Owner") }) ?? false
    }
    
    init(group: Binding<Groups>) {
        self._group = group
        self._members = State(initialValue: group.wrappedValue.memberList ?? [])
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
                ForEach(members, id: \.id) { member in
                    Menu {
                        NavigationLink {
                            ProfileView(user: member)
                        } label: {
                            Text("View profile")
                        }
                        
                        if isCurrentUserAdmin {
                            Menu("Change permissions") {
                                if member.groupPermissions == "Admin" {
                                    Button {
                                        Task {
                                            try await GroupService.changeGroupPermissions(groupId: group.id, forUserId: member.id, toPermission: "Member")
                                            try await viewModel.refreshGroup(groupId: group.id)
                                            if let newGroup = viewModel.group {
                                                self.group = newGroup
                                                self.members = newGroup.memberList ?? []
                                            }
                                        }
                                    } label: {
                                        Text("Member")
                                    }
                                }
                                
                                if member.groupPermissions == "Member"{
                                    Button {
                                        Task {
                                            try await GroupService.changeGroupPermissions(groupId: group.id, forUserId: member.id, toPermission: "Admin")
                                            try await viewModel.refreshGroup(groupId: group.id)
                                            if let newGroup = viewModel.group {
                                                self.group = newGroup
                                                self.members = newGroup.memberList ?? []
                                            }
                                        }
                                    } label: {
                                        Text("Admin")
                                    }
                                }
                            }
                            
                            if member.groupPermissions != "Owner" {
                                Button(role: .destructive) {
                                    Task {
                                        try await GroupService.leaveGroup(uid: member.id, groupId: group.id)
                                        try await viewModel.refreshGroup(groupId: group.id)
                                        if let newGroup = viewModel.group {
                                            self.group = newGroup
                                            self.members = newGroup.memberList ?? []
                                        }
                                    }
                                } label: {
                                    Text("Remove member")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            CircularProfileImageView(user: member, size: .small)
                            Text(member.username)
                                .foregroundColor(Color.theme.primaryText)
                                .font(.system(size: 16))
                            Spacer()
                            Text(member.groupPermissions ?? "")
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
