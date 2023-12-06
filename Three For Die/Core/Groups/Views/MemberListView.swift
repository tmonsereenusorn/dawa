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
    
    private var isCurrentUserAdmin: Bool {
        guard let currentUser = contentViewModel.currentUser else { return false }
        return group.memberList?.contains(where: { $0.id == currentUser.id && ($0.groupPermissions == "Admin" || $0.groupPermissions == "Owner") }) ?? false
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
            
            if var members = group.memberList {
                List() {
                    ForEach(members) { member in
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
                                            }
                                            if let index = members.firstIndex(where: { $0.id == member.id }) {
                                                members[index].groupPermissions = "Member"
                                                self.group.memberList = members // Update the entire list
                                            }
                                        } label: {
                                            Text("Member")
                                        }
                                    }
                                    
                                    if member.groupPermissions == "Member"{
                                        Button {
                                            Task {
                                                try await GroupService.changeGroupPermissions(groupId: group.id, forUserId: member.id, toPermission: "Admin")
                                            }
                                            if let index = members.firstIndex(where: { $0.id == member.id }) {
                                                members[index].groupPermissions = "Admin"
                                                self.group.memberList = members // Update the entire list
                                            }
                                        } label: {
                                            Text("Admin")
                                        }
                                    }
                                }
                                
                                Button(role: .destructive) {
                                    
                                } label: {
                                    Text("Remove member")
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
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    MemberListView()
//}
