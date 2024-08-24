//
//  NotificationsView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    @Binding var showLeftMenu: Bool
    @Binding var showRightMenu: Bool
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
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
                GroupInvitesView()
                    .navigationBarBackButtonHidden()
            } label: {
                HStack {
                    Text("Group Invitations")
                        .foregroundColor(Color.theme.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.theme.secondaryText)
                    
                }
                .padding()
            }
            
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
            viewModel.markAllNotificationsAsRead()
        }
    }
}

//#Preview {
//    NotificationsView(showLeftMenu: Binding<false>, showRightMenu: Binding<false>)
//}
