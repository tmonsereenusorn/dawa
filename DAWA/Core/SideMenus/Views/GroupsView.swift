//
//  GroupsView.swift
//  DAWA
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
            // Header
            HStack {
                Text("Groups")
                    .font(.title2).bold()
                    .padding(.leading)
                    .foregroundColor(Color.theme.primaryText)
                
                Spacer()
                
                VStack {
                    NavigationLink {
                        GroupSearchView()
                    } label: {
                        HStack {
                            Text("Join Groups")
                                .font(.caption)
                                .foregroundColor(Color.theme.secondaryText)
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.theme.primaryText)
                        }
                    }
                }
            }
            
            // Groups List
            if viewModel.fetchedGroups {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.groups.indices, id: \.self) { index in
                            Button {
                                let group = viewModel.groups[index]
                                viewModel.currSelectedGroup = group
                            } label: {
                                GroupRowView(group: viewModel.groups[index])
                            }
                        }
                    }
                }
                .refreshable {
                    Task {
                        await viewModel.fetchUserGroups()
                    }
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView("Fetching groups...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
            
            VStack {
                Divider()
                
                Button {
                    creatingGroup.toggle()
                } label: {
                    Text("Create Group")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.theme.appTheme)
                        .cornerRadius(10)
                        .font(.body).bold()
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .popover(isPresented: $creatingGroup) {
                    CreateGroupView()
                }
            }
        }
        .padding(10)
        .frame(width: getRect().width - 90)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}

//#Preview {
//    GroupsView()
//}
