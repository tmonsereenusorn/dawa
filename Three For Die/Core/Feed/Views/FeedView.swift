//
//  FeedView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import Foundation
import SwiftUI

struct FeedView: View{
    @Binding var showLeftMenu: Bool
    @State private var addingEvent: Bool = false
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
//        
//        UIBarButtonItem.appearance().tintColor = UIColor(Color.theme.primaryText)
//    }
    
    var body: some View {
        if let user = contentViewModel.currentUser {
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation{ showLeftMenu.toggle() }
                        } label: {
                            Circle()
                                .frame(width: 32, height: 32)
                        }
                        
                        Spacer()
                        
                        Text("Feed")
                        
                        Spacer()
                        
                        Button {
                            withAnimation{ showLeftMenu.toggle() }
                        } label: {
                            Circle()
                                .frame(width: 32, height: 32)
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
        } else {
            ProgressView("Loading Feed...")
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
