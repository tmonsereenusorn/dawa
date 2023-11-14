//
//  InviteUsersView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/7/23.
//

import SwiftUI

struct InviteUsersView: View {
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel: InviteUsersViewModel
    @Binding var group: Groups
    
    init(group: Binding<Groups>) {
        _group = group
        _viewModel = StateObject(wrappedValue: InviteUsersViewModel(groupMembers: group.wrappedValue.memberList ?? []))
    }
    
    private var usernamesToInvite: String {
        viewModel.usersToInvite.map { $0.username }.joined(separator: ", ")
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
                
                Spacer()
                
                Text("Invite New Members")
                    .foregroundColor(Color.theme.primaryText)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    Task {
                        try await viewModel.sendInvites(forGroupId: group.id)
                    }
                } label: {
                    Text("Send")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            .onReceive(viewModel.$didInviteUsers) { success in
                if success {
                    mode.wrappedValue.dismiss()
                }
            }
            .padding(10)
            
            HStack(spacing: 0) {
                Text("Send invites to: ")
                    .foregroundColor(Color.theme.primaryText)
                
                Text(usernamesToInvite)
                    .foregroundColor(Color.theme.secondaryText)
                
                Spacer()
            }
            .padding()
            
            TextField("Search for username", text: $viewModel.searchText)
                .frame(height: 44)
                .padding(.leading)
                .background(Color(.systemGroupedBackground))
                .onChange(of: viewModel.searchText) { newValue in
                    Task {
                        do {
                            try await viewModel.searchForUsers()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            
            LazyVStack {
                ForEach(viewModel.users) { user in
                    VStack {
                        Button {
                            viewModel.toggleUserSelection(user: user)
                        } label: {
                            HStack {
                                CircularProfileImageView(user: user, size: .small)

                                Text(user.username)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Spacer()
                                
                                if viewModel.usersToInvite.contains(user) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.green)
                                        .padding(.horizontal)
                                }
                            }
                            
                        }
                        
                        Divider()
                            .padding(.leading, 40)
                    }
                    .padding(.leading)
                }
            }
            
            Spacer()
        }
    }
}

//#Preview {
//    InviteMembersView()
//}
