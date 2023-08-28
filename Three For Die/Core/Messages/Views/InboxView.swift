//
//  InboxView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct InboxView: View {
    @StateObject var viewModel = InboxViewModel()
    
    var body: some View {
        NavigationStack {
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
