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

    @State private var navigateToGroupInvites: Bool = false  // For controlling navigation

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        withAnimation { showLeftMenu.toggle() }
                    } label: {
                        SquareGroupImageView(group: groupsViewModel.currSelectedGroup, size: .xSmall)
                    }

                    Spacer()

                    Text("Notifications")
                        .font(.headline)

                    Spacer()

                    Button {
                        withAnimation { showRightMenu.toggle() }
                    } label: {
                        CircularProfileImageView(user: viewModel.user, size: .xSmall)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()
            }

            // Group Invitations Row
            Button {
                navigateToGroupInvites = true // Manually navigate when button is clicked
            } label: {
                HStack {
                    Image(systemName: "envelope.badge")
                        .foregroundColor(Color.theme.appTheme)
                        .font(.title2)

                    Text("Group Invitations")
                        .foregroundColor(Color.theme.primaryText)
                        .font(.body)
                        .fontWeight(.medium)

                    Spacer()

                    if groupInvitesViewModel.pendingInvitesCount > 0 {
                        Text("\(groupInvitesViewModel.pendingInvitesCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.red))
                            .padding(.trailing, 5)
                    }

                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.theme.secondaryText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.vertical, 5)

            Divider()

            // List of Notifications
            List(viewModel.notifications, id: \.id) { notification in
                if let activity = notification.activity {
                    NavigationLink(value: activity) {
                        NotificationRowView(notification: notification)
                    }
                    .listRowInsets(EdgeInsets()) // Remove List padding
                } else {
                    NotificationRowView(notification: notification)
                        .listRowInsets(EdgeInsets()) // Remove List padding
                }
            }
            .listStyle(PlainListStyle())

            Spacer()
        }
        .navigationDestination(isPresented: $navigateToGroupInvites) {
            GroupInvitesView(viewModel: groupInvitesViewModel)
        }
        // Listen for changes in PushNotificationHandler and manually trigger navigation
        .onAppear {
            PushNotificationHandler.shared.$tappedGroupInviteId.sink { inviteId in
                if let _ = inviteId {
                    navigateToGroupInvites = true
                    PushNotificationHandler.shared.tappedGroupInviteId = nil
                }
            }.store(in: &viewModel.cancellables) // You need to manage cancellables to avoid memory leaks
        }
        .onDisappear {
            Task {
                await viewModel.markAllNotificationsAsRead()
            }
        }
    }
}
