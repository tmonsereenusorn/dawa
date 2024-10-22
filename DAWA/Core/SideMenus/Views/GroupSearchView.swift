//
//  GroupSearchView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 11/26/23.
//

import SwiftUI

struct GroupSearchView: View {
    @StateObject var viewModel = GroupSearchViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        VStack {
            TextField("Search for group handle", text: $viewModel.searchText)
                .frame(height: 44)
                .padding(.leading)
                .background(Color(.systemGroupedBackground))
                .onChange(of: viewModel.searchText) { newValue in
                    Task {
                        do {
                            try await viewModel.searchForGroups()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            
            LazyVStack {
                ForEach(viewModel.groups) { group in
                    VStack {
                        HStack {
                            SquareGroupImageView(group: group, size: .small)

                            VStack(alignment: .leading) {
                                Text(group.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.primaryText)
                                
                                Text("@\(group.handle)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.secondaryText)
                            }
                            
                            Spacer()
                            
                            if groupsViewModel.groups.contains(where: { $0.id == group.id }) {
                                // User is already a member
                                Text("Joined")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.green)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else if viewModel.pendingRequests.contains(group.id) {
                                // User has already sent a request to join
                                Text("Request Sent")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.orange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else {
                                // User can request to join
                                Button("Request to Join") {
                                    Task {
                                        do {
                                            try await GroupService.requestToJoinGroup(groupId: group.id)
                                            // Update pending requests list after sending a request
                                            await viewModel.fetchPendingRequests()
                                        } catch {
                                            print("Error: \(error)")
                                        }
                                    }
                                }
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.theme.appTheme)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
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
        .navigationTitle("Search for Groups")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background)
    }
}

//#Preview {
//    GroupSearchView()
//}
