//
//  ActivitiesView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/30/23.
//

import SwiftUI

struct MessagesView: View {
    @ObservedObject var viewModel = MessagesViewModel()
    
    var body: some View {
        VStack {
            ScrollView() {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.userActivities) { activity in
                        ActivityRowView(activity: activity)
                    }
                }
                .padding(.horizontal, 18)
            }
            .refreshable {
                Task {
                    await viewModel.fetchUserActivities()
                }
            }
        }
    }
}

//struct ActivitiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitiesView()
//    }
//}
