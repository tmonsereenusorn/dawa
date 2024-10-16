//
//  InboxView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var viewModel: InboxViewModel
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
            
            if viewModel.didCompleteInitialLoad {
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
                            .onAppear {
                                if let activityId = userActivity.activity?.id {
                                    viewModel.markAsRead(activityId: activityId)
                                }
                            }
                    }
                })
                .listStyle(PlainListStyle())
            } else {
                // This will make the progress view take up the entire space
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//
//struct InboxView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityInboxView()
//    }
//}
