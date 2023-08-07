//
//  EventView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import SwiftUI

struct ActivityRowView: View {
    @ObservedObject var viewModel: ActivityRowViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    init(activity: Activity) {
        self.viewModel = ActivityRowViewModel(activity: activity)
    }
    
    var body: some View {
        if let user = viewModel.activity.user {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "person.circle.fill")
                    Text(user.username)
                        .foregroundColor(.black)
                        .font(.system(size: 10))
                    Text(viewModel.activity.timestamp.dateValue().timeAgoDisplay())
                        .foregroundColor(CustomColors.gray_2)
                        .font(.system(size: 10))
                    
                    Spacer()
                    
                    if user.isCurrentUser {
                        Button {
                            Task {
                                try await viewModel.closeActivity()
                                await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup)
                            }
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
                }
                HStack {
                    Text(viewModel.activity.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    if let filterColor = ActivityFilters.color(forLabel: viewModel.activity.category) {
                        Text(viewModel.activity.category)
                            .padding(.vertical, 6) // Adjust vertical padding
                            .padding(.horizontal, 9) // Adjust horizontal padding
                            .foregroundColor(.white)
                            .background(filterColor)
                            .cornerRadius(15)
                            .font(.system(size: 10)).bold()
                    }
                    Spacer()
                }
                HStack {
                    Text(viewModel.activity.notes)
                        .font(.system(size: 10))
                        .foregroundColor(CustomColors.gray_2)
                    Spacer()
                    Image(systemName: "pin")
                        .foregroundColor(CustomColors.gray_2)
                    Text(viewModel.activity.location)
                        .font(.system(size: 10))
                        .foregroundColor(CustomColors.gray_2)
                }
                
                HStack {
                    Spacer()
                    HStack {
                        if viewModel.activity.numRequired <= 5 {
                            ForEach(0..<viewModel.activity.numCurrent, id: \.self) { i in
                                Image(systemName: "circle.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                            }
                            if viewModel.activity.numCurrent < viewModel.activity.numRequired {
                                ForEach(viewModel.activity.numCurrent...(viewModel.activity.numRequired - 1),   id: \.self) { i in
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(CustomColors.gray_1)
                                }
                            }
                        } else {
                            Text("\(viewModel.activity.numCurrent) / \(viewModel.activity.numRequired)")
                        }
                    }
                    Spacer()
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(12)
        }
    }
}

//struct ActivityRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityRowView(activity: Activity.MOCK_ACTIVITY)
//    }
//}
