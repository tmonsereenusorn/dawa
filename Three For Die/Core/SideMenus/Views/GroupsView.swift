//
//  GroupsView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct GroupsView: View {
    @State private var creatingGroup: Bool = false
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var viewModel: GroupsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Groups")
                .font(.title2).bold()
                .padding(.leading)
            Divider()
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.groups) { group in
                        Button {
                            viewModel.currSelectedGroup = group.id!
                            Task {
                                await feedViewModel.fetchActivities(groupId: group.id!)
                            }
                        } label: {
                            GroupRowView(group: group)
                                .foregroundColor(.white)
                                .background(viewModel.currSelectedGroup == group.id ? .gray : .black)
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.fetchUserGroups()
                }
            }
            
            Spacer()
            
            Divider()
            
            Button {
                creatingGroup.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus.app")
                    Text("Create Group")
                    Spacer()
                }
                .foregroundColor(.white)
            }
            .popover(isPresented: $creatingGroup) {
                CreateGroupView()
            }
        }
        .padding(10)
    }
}

//struct LeftSideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftSideMenuView()
//    }
//}
