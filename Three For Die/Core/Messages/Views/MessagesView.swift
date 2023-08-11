//
//  ActivitiesView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/30/23.
//

import SwiftUI
import SlidingTabView

struct MessagesView: View {
    @ObservedObject var viewModel = MessagesViewModel()
    
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            SlidingTabView(selection: $selectedIndex, tabs: ["Activities", "Events"], animation: .easeInOut)
            Spacer()
            if selectedIndex == 0 {
                InboxView()
            } else {
                Text("Events")
            }
            Spacer()
//            ScrollView() {
//                LazyVStack(spacing: 16) {
//                    ForEach(viewModel.userActivities) { activity in
//                        ActivityRowView(activity: activity)
//                    }
//                }
//                .padding(.horizontal, 18)
//            }
//            .refreshable {
//                Task {
//                    await viewModel.fetchUserActivities()
//                }
//            }
        }
    }
}
//
//struct MessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessagesView()
//    }
//}
