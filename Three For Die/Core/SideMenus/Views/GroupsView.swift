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
            HStack {
                Text("Groups")
                    .font(.title2).bold()
                    .padding(.leading)
                    .foregroundColor(Color.theme.primaryText)
                
                Spacer()
                
                NavigationLink {
                    GroupSearchView()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color.theme.primaryText)
                }
            }
            
            Divider()
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.groups.indices, id: \.self) { index in
                        Button {
                            let group = viewModel.groups[index]
                            viewModel.currSelectedGroup = group
                            Task {
                                try await feedViewModel.fetchActivities(groupId: group.id)
                            }
                        } label: {
                            GroupRowView(group: $viewModel.groups[index])
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
                .foregroundColor(Color.theme.primaryText)
            }
            .popover(isPresented: $creatingGroup) {
                CreateGroupView()
            }
        }
        .padding(10)
        .frame(width: getRect().width - 90)
        .frame(maxHeight: .infinity)
        .background(
            Color.theme.background
                .ignoresSafeArea(.container, edges: .vertical)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
//
//#Preview {
//    GroupsView()
//}
