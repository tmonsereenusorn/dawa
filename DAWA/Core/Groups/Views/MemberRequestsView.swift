//
//  MemberRequestsView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 09/30/24.
//

import SwiftUI

struct MemberRequestsView: View {
    @StateObject var viewModel = MemberRequestsViewModel()
    @Binding var group: Groups
    @Environment(\.presentationMode) var mode

    var body: some View {
        VStack {
            // Header
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
                
                Text("Join Requests")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Placeholder for alignment
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20, height: 16)
                    .foregroundColor(Color.clear)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider()
            
            // List of member requests
            if viewModel.requests.isEmpty {
                Text("No pending requests")
                    .foregroundColor(Color.theme.secondaryText)
                    .padding()
            } else {
                List(viewModel.requests) { request in
                    HStack {
                        CircularProfileImageView(user: request.user, size: .small)
                        
                        Text(request.user!.username)
                            .foregroundColor(Color.theme.primaryText)
                            .font(.system(size: 16))
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            // Accept button
                            Button {
                                Task {
                                    do {
                                        try await viewModel.acceptRequest(userId: request.fromUserId, groupId: group.id)
                                        await viewModel.fetchRequests(groupId: group.id)
                                    } catch {
                                        print("Error accepting request: \(error)")
                                    }
                                }
                            } label: {
                                Image(systemName: "checkmark.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.green)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Reject button
                            Button {
                                Task {
                                    do {
                                        try await viewModel.rejectRequest(requestId: request.id, groupId: group.id)
                                        await viewModel.fetchRequests(groupId: group.id)
                                    } catch {
                                        print("Error rejecting request: \(error)")
                                    }
                                }
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchRequests(groupId: group.id)
            }
        }
        .padding()
        .background(Color.theme.background)
    }
}
