//
//  FeedView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import Foundation
import SwiftUI

struct FeedView: View{
    @Binding var showLeftMenu: Bool
    @Binding var showRightMenu: Bool
    @State private var addingEvent: Bool = false
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var viewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        if let user = contentViewModel.currentUser {
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation{ showLeftMenu.toggle() }
                        } label: {
                            SquareGroupImageView(group: groupsViewModel.currSelectedGroup, size: .xSmall)
                        }
                        
                        Spacer()
                        
                        Text("Activity Feed")
                        
                        Spacer()
                        
                        Button {
                            withAnimation{ showRightMenu.toggle() }
                        } label: {
                            CircularProfileImageView(user: user, size: .xSmall)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    Divider()
                }
                
                ZStack(alignment: .bottomTrailing) {
                    List {
                        SearchBar(text: $viewModel.searchText)
                        
                        ForEach(viewModel.filteredActivities) { activity in
                            ZStack {
                                NavigationLink(value: activity) {
                                    EmptyView()
                                }
                                .opacity(0.0)
                                
                                ActivityRowView(activity: activity)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        Task {
                            try await viewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                        }
                    }
                    .navigationDestination(for: Activity.self, destination: { activity in
                        ActivityView(activity: activity)
                    })
                    
                    
                    Button () {
                        addingEvent.toggle()
                    } label: {
                        Image (systemName: "plus.circle.fill")
                            .resizable ()
                            .renderingMode(.template)
                            .frame (width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                    .background(Color.theme.background)
                    .clipShape(Circle())
                    .padding()
                    .popover(isPresented: $addingEvent) {
                        AddActivityView(user: user)
                    }
                }
            }
            .onChange(of: groupsViewModel.currSelectedGroup?.id) { newGroupId in
                if let groupId = newGroupId {
                    Task {
                        try? await viewModel.fetchActivities(groupId: groupId)
                    }
                }
            }
        } else {
            ProgressView("Loading Feed...")
        }
    }
}

//struct FeedViews_Preview: PreviewProvider {
//    static var previews: some View {
//        FeedView()
//    }
//}
