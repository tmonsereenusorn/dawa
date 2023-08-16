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
            ScrollView {
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
                }
                .listStyle(PlainListStyle())
                .frame(height: UIScreen.main.bounds.height - 120)
            }
            .navigationDestination(for: UserActivity.self, destination: { userActivity in
                if let activity = userActivity.activity {
                    ChatView(activity: activity)
                }
            })
        }
    }
}
//
//struct InboxView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityInboxView()
//    }
//}
