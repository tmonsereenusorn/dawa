//
//  EventView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import SwiftUI

struct ActivityRowView: View {
    @ObservedObject var viewModel: ActivityRowViewModel
    @ObservedObject var feedViewModel = FeedViewModel()
    
    init(activity: Activity) {
        self.viewModel = ActivityRowViewModel(activity: activity)
    }
    
    var body: some View {
        if let user = viewModel.activity.user {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.black)
                    Text(user.username)
                        .foregroundColor(.black)
                    Text("2m")
                        .foregroundColor(CustomColors.gray_2)
                    
                    Spacer()
                    
                    if user.isCurrentUser {
                        Button {
                            Task {
                                try await viewModel.closeActivity()
                                await feedViewModel.fetchActivities()
                            }
                        } label: {
                            Text("Close activity")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .foregroundColor(.white)
                                .background(.red)
                                .cornerRadius(15)
                                .font(.caption).bold()
                        }
                    } else {
                        if viewModel.activity.didJoin ?? false { // If user already joined activity
                            Button {
                                Task {
                                    try await viewModel.leaveActivity()
                                }
                            } label: {
                                Text("Leave activity")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(.white)
                                    .background(.red)
                                    .cornerRadius(15)
                                    .font(.caption).bold()
                            }
                        } else {
                            Button {
                                Task {
                                    try await viewModel.joinActivity()
                                }
                            } label: {
                                Text("Join Activity")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(.white)
                                    .background(.green)
                                    .cornerRadius(15)
                                    .font(.caption).bold()
                            }
                        }
                    }
                }
                HStack {
                    Text(viewModel.activity.title)
                        .font(.title)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    if let filterColor = ActivityFilters.color(forLabel: viewModel.activity.category) {
                        Text(viewModel.activity.category)
                            .padding(.vertical, 8) // Adjust vertical padding
                            .padding(.horizontal, 12) // Adjust horizontal padding
                            .foregroundColor(.white)
                            .background(filterColor)
                            .cornerRadius(15)
                            .font(.caption).bold()
                    }
                    Spacer()
                    Image(systemName: "pin")
                        .foregroundColor(.black)
                    Text(viewModel.activity.location)
                        .foregroundColor(.black)
                }
                HStack {
                    Text(viewModel.activity.notes)
                        .font(.body)
                        .foregroundColor(CustomColors.gray_2)
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
