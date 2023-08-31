//
//  FeedView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import Foundation
import SwiftUI

struct FeedView: View{
    @State private var addingEvent: Bool = false
    @State private var searchText = ""
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var viewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
//    init() {
//        let newNavBarAppearance = customNavBarAppearance()
//
//        let appearance = UINavigationBar.appearance()
//        appearance.scrollEdgeAppearance = newNavBarAppearance
//        appearance.compactAppearance = newNavBarAppearance
//        appearance.standardAppearance = newNavBarAppearance
//    }
    
    var body: some View {
        if let user = contentViewModel.currentUser {
            ZStack(alignment: .bottomTrailing) {
                List {
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
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
                .listStyle(PlainListStyle())
                .refreshable {
                    Task {
                        try await viewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup)
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
                        .foregroundColor(CustomColors.cardinal_red)
                }
                .background(Color.theme.primaryText)
                .clipShape(Circle())
                .padding()
                .popover(isPresented: $addingEvent) {
                    AddActivityView(user: user)
                }
            }
        }
    }
}

func customNavBarAppearance() -> UINavigationBarAppearance {
    let customNavBarAppearance = UINavigationBarAppearance()
    
    // Apply a red background.
    customNavBarAppearance.configureWithOpaqueBackground()
    customNavBarAppearance.backgroundColor = UIColor(Color.theme.background)
    
    // Apply white colored normal and large titles.
    customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.primaryText)]
    customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.primaryText)]


    // Apply white color to all the nav bar buttons.
    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.primaryText)]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.primaryText)]
    customNavBarAppearance.buttonAppearance = barButtonItemAppearance
    customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
    customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
    
    return customNavBarAppearance
}

//struct FeedViews_Preview: PreviewProvider {
//    static var previews: some View {
//        FeedView()
//    }
//}
