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
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    init() {
        let newNavBarAppearance = customNavBarAppearance()
        
        let appearance = UINavigationBar.appearance()
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
    }
    
    var body: some View {
        if let user = authViewModel.currentUser {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    SearchBar(text: $searchText)
                        .padding()
                    
                    ScrollView() {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.activities) { activity in
                                ActivityRowView(activity: activity)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .refreshable {
                        Task {
                            await viewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup)
                        }
                    }
                }
                Button () {
                    addingEvent.toggle ()
                } label: {
                    Image (systemName: "plus.circle.fill")
                        .resizable ()
                        .renderingMode(.template)
                        .frame (width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                        .foregroundColor(CustomColors.cardinal_red)
                }
                .background(.white)
                .clipShape(Circle())
                .padding()
                .popover(isPresented: $addingEvent) {
                    AddActivityView(user: user)
                }
            }
            .background(.black)
        }
    }
}

func customNavBarAppearance() -> UINavigationBarAppearance {
    let customNavBarAppearance = UINavigationBarAppearance()
    
    // Apply a red background.
    customNavBarAppearance.configureWithOpaqueBackground()
    customNavBarAppearance.backgroundColor = UIColor(CustomColors.cardinal_red)
    
    // Apply white colored normal and large titles.
    customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]


    // Apply white color to all the nav bar buttons.
    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
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