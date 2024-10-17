//
//  NotificationsView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var viewModel: NotificationsViewModel
    @Binding var showLeftMenu: Bool
    @Binding var showRightMenu: Bool
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @StateObject var groupInvitesViewModel = GroupInvitesViewModel()

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        withAnimation{ showLeftMenu.toggle() }
                    } label: {
                        SquareGroupImageView(group: groupsViewModel.currSelectedGroup, size: .xSmall)
                    }

                    Spacer()

                    Text("Notifications")

                    Spacer()

                    Button {
                        withAnimation{ showRightMenu.toggle() }
                    } label: {
                        CircularProfileImageView(user: viewModel.user, size: .xSmall)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()
            }

            NavigationLink {
                GroupInvitesView(viewModel: groupInvitesViewModel)
                    .navigationBarBackButtonHidden()
            } label: {
                HStack {
                    Image(systemName: "envelope.badge") // Leading icon for consistency
                        .foregroundColor(Color.theme.appTheme)
                        .font(.title2)
                    
                    Text("Group Invitations")
                        .foregroundColor(Color.theme.primaryText)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Badge for pending invites
                    if groupInvitesViewModel.pendingInvitesCount > 0 {
                        Text("\(groupInvitesViewModel.pendingInvitesCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.red)) // More noticeable badge
                            .padding(.trailing, 5)
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.theme.secondaryText)
                }
                .padding()
                .background(Color(.systemGray6)) // Card-style background
                .cornerRadius(10) // Rounded corners for a modern look
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
            }
            .padding(.horizontal)
            .padding(.vertical, 5) // Adjust the spacing around the element

            Divider()

            if !viewModel.initialLoad {
                // List of Notifications
                List(viewModel.notifications, id: \.id) { notification in
                    if let activity = notification.activity {
                        NavigationLink(destination: ActivityView (activity: activity)) {
                            NotificationRowView(notification: notification)
                        }
                        .listRowInsets(EdgeInsets()) // Remove List padding
                    } else {
                        NotificationRowView(notification: notification)
                            .listRowInsets(EdgeInsets()) // Remove List padding
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                ProgressView()
            }

            Spacer()
        }
        .onDisappear {
            Task {
                await viewModel.markAllNotificationsAsRead()
            }
        }
    }
}
