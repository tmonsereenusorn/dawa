//
//  EventView.swift
//  DAWA
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
        if let hostUser = viewModel.activity.host {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    CircularProfileImageView(user: hostUser, size: .xxxSmall)
                    Text(hostUser.username)
                        .foregroundColor(Color.theme.primaryText)
                        .font(.system(size: 12))
                    Text(viewModel.activity.timestamp.dateValue().timeAgoDisplay())
                        .foregroundColor(Color.theme.secondaryText)
                        .font(.system(size: 10))
                    
                    Spacer()
                    
                }
                HStack {
                    Text(viewModel.activity.title)
                        .font(.system(size: 18))
                        .foregroundColor(Color.theme.primaryText)
                        .fontWeight(.semibold)
                    if let filterColor = ActivityFilters.color(forLabel: viewModel.activity.category) {
                        Text(viewModel.activity.category)
                            .padding(.vertical, 4) // Adjust vertical padding
                            .padding(.horizontal, 6) // Adjust horizontal padding
                            .foregroundColor(.white)
                            .background(filterColor)
                            .cornerRadius(15)
                            .font(.system(size: 8)).bold()
                    }
                    Spacer()
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.secondaryText)
                    Text(viewModel.activity.location)
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.secondaryText)
                    Spacer()
                    HStack {
                        if viewModel.activity.numRequired == 0 {
                            Text("Participants: \(viewModel.activity.numCurrent) / ∞")
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.system(size: 12))
                        } else {
                            Text("Participants: \(viewModel.activity.numCurrent) / \(viewModel.activity.numRequired)")
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
            .padding()
            .background(Color.theme.tertiaryBackground)
            .cornerRadius(12)
            .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 3)
        }
    }
}

//struct ActivityRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityRowView(activity: Activity.MOCK_ACTIVITY)
//    }
//}
