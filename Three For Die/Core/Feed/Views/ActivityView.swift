//
//  ActivityView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/9/23.
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.presentationMode) var mode
    @State private var editingActivity: Bool = false
    @ObservedObject var viewModel: ActivityViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    init(activity: Activity) {
        self.viewModel = ActivityViewModel(activity: activity)
    }
    
    var body: some View {
        if let user = viewModel.activity.user {
            VStack(alignment: .leading, spacing: 12) {
                // Header and buttons
                HStack(alignment: .top) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 16)
                            .foregroundColor(Color.theme.primaryText)
                            .offset(x: 16, y: 12)
                    }
                    
                    Spacer()
                    
                    if user.isCurrentUser {
                        Button {
                            Task {
                                try await viewModel.closeActivity()
                                try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                            }
                            mode.wrappedValue.dismiss()
                        } label: {
                            Text("Close activity")
                                .padding(.vertical, 6)
                                .padding(.horizontal, 9)
                                .foregroundColor(.white)
                                .background(.red)
                                .cornerRadius(15)
                                .font(.system(size: 10)).bold()
                        }
                    } else {
                        if viewModel.activity.didJoin ?? false { // If user already joined activity
                            Button {
                                Task {
                                    try await viewModel.leaveActivity()
                                    try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                                }
                            } label: {
                                Text("Leave activity")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 9)
                                    .foregroundColor(.white)
                                    .background(.red)
                                    .cornerRadius(15)
                                    .font(.system(size: 10)).bold()
                            }
                        } else {
                            Button {
                                Task {
                                    try await viewModel.joinActivity()
                                    try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                                }
                            } label: {
                                Text("Join Activity")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 9)
                                    .foregroundColor(.white)
                                    .background(.green)
                                    .cornerRadius(15)
                                    .font(.system(size: 10)).bold()
                            }
                        }
                    }
//                    Button {
//                        editingActivity.toggle()
//                    } label: {
//                        Text("Edit Activity")
//                            .font(.subheadline).bold()
//                            .frame(width: 120, height: 32)
//                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
//                            .foregroundColor(.white)
//                    }
                }
                
                // Main Activity Content
                HStack{
                    Spacer()
                    Text(viewModel.activity.title)
                        .foregroundColor(Color.theme.primaryText)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Text("Location: \(viewModel.activity.location)")
                    .foregroundColor(Color.theme.primaryText)
                
                Text("Details: \(viewModel.activity.notes)")
                    .foregroundColor(Color.theme.primaryText)
                
                Divider()
                    .background(Color.theme.secondaryText)
                
                // Activity Participants
                Text("Participants (\(viewModel.activity.numCurrent) / \(viewModel.activity.numRequired))")
                    .foregroundColor(Color.theme.primaryText)
                
                ScrollView() {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.participants) { participant in
                            HStack {
                                CircularProfileImageView(user: participant, size: .xxSmall)
                                Text(participant.username)
                                    .foregroundColor(Color.theme.primaryText)
                                    .font(.system(size: 12))
                                Spacer()
                                if participant.id == viewModel.activity.userId {
                                    Text("Host")
                                        .foregroundColor(Color.theme.secondaryText)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .refreshable {
                    Task {
                        await viewModel.fetchActivityParticipants()
                        try await viewModel.refreshActivity()
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
            .background(Color.theme.background)
        }
    }
}
//
//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView()
//    }
//}
