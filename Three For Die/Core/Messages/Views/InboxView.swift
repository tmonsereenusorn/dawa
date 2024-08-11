//
//  InboxView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct InboxView: View {
    @StateObject var viewModel = InboxViewModel()
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
                    
                    Text("Inbox")
                    
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
            
            List {
                ForEach(viewModel.userActivities, id: \.self) { userActivity in
                    ZStack {
                        NavigationLink(value: userActivity) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        
                        InboxRowView(userActivity: userActivity)
                    }
                }
                .listRowInsets(EdgeInsets())
                .padding(.vertical)
                .padding(.trailing, 8)
                .padding(.leading, 20)
            }
            .navigationDestination(for: UserActivity.self, destination: { userActivity in
                if let activity = userActivity.activity {
                    ChatView(activity: activity)
                        .onDisappear {
                            if let activityId = userActivity.activity?.id {
                                ChatService.markAsRead(activityId: activityId)
                            }
                        }
                }
            })
            .listStyle(PlainListStyle())
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .overlay { if !viewModel.didCompleteInitialLoad { ProgressView() } }
            .background(Color.theme.background)
        }
    }
}
//
//struct InboxView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityInboxView()
//    }
//}
