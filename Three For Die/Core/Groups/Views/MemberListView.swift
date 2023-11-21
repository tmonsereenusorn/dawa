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
    
    var body: some View {
        VStack(spacing: 10) {
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
            }
            
            if let members = group.memberList {
                ScrollView() {
                    LazyVStack(spacing: 16) {
                        ForEach(members) { member in
                            NavigationLink {
                                ProfileView(user: member)
                            } label: {
                                HStack {
                                    CircularProfileImageView(user: member, size: .medium)
                                    Text(member.username)
                                        .foregroundColor(Color.theme.primaryText)
                                        .font(.system(size: 16))
                                    Spacer()
                                    Text(member.groupPermissions ?? "")
                                        .foregroundColor(Color.theme.secondaryText)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                }
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
        .background(Color.theme.background)
    }
}

//#Preview {
//    MemberListView()
//}
